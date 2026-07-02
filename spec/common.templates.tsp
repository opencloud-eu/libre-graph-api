import "@typespec/http";
import "@typespec/openapi";

import "./common.models.tsp";

using Http;
using OpenAPI;

namespace LibreGraph;

//
// Generic response shape templates. Pass the body model and the
// human-readable response description as type arguments instead of
// declaring a fresh `{ @statusCode, @body, @doc }` model per operation:
//
//   op getInvitation is LibreGraphOps.getResource<
//     ...InvitationIdPath,
//     Retrieved<invitation, "Retrieved invitation">
//   >;
//
// The `TDoc` argument is the OpenAPI response `description`. `@doc` above
// the `op is …` declaration binds to the operation description instead,
// so the response wording has to live on the template instantiation.
//
@doc(TDoc)
model Retrieved<TBody, TDoc extends valueof string = "OK"> {
  @statusCode _: 200;
  @body body: TBody;
}

@doc(TDoc)
model Created<TBody, TDoc extends valueof string = "Created"> {
  @statusCode _: 201;
  @body body: TBody;
}

@doc(TDoc)
model NoContent<TDoc extends valueof string = "No Content"> {
  @statusCode _: 204;
}

@doc(TDoc)
model Accepted<TDoc extends valueof string = "Accepted"> {
  @statusCode _: 202;
}

//
// OData collection shapes. Every `value?: T[]` list response in this spec
// emits as `#/components/schemas/<Name>` so callers can reference it by a
// stable short name (the friendlyName) instead of an inline object schema.
// Pass the element type and the desired schema name explicitly:
//
//   alias drivesResponse = PaginatedCollection<driveResource, "CollectionOfDrives">;
//   alias tagsResponse   = Collection<string, "CollectionOfTags">;
//
// `Name` is `valueof string` so it survives into the OpenAPI schema key.
//

@friendlyName(Name)
model Collection<T, Name extends valueof string> {
  value?: T[];
}

@friendlyName(Name)
model PaginatedCollection<T, Name extends valueof string> {
  value?: T[];

  `@odata.nextLink`?: string;
}

@friendlyName(Name)
model PaginatedCollectionWithMaxItems<
  T,
  Name extends valueof string,
  MaxItems extends valueof int32
> {
  @maxItems(MaxItems)
  value?: T[];

  `@odata.nextLink`?: string;
}

//
// Operation templates shared across the libre-graph-api domain files.
//
// Each call site supplies its own @route, @summary, @doc, @operationId
// and @tag and inherits the HTTP verb, the
// `x-ms-docs-operation-type: operation` extension and the canonical
// response shape from the matching template:
//
//   @route("/v1.0/users/{user-id}")
//   namespace User {
//     @summary("Get entity from users by key")
//     @operationId("GetUser")
//     @tag("user")
//     op getUser is LibreGraphOps.getResource<UserIdPath, UserRetrieved>;
//   }
//
// Body descriptions (the requestBody-level `description` field, distinct
// from the schema's own `@doc`) are passed in as the trailing
// `valueof string` template argument on every template that takes a
// body, so each call site can keep its precise wording without giving
// up the rest of the template.
//
// Comments use `//` rather than JSDoc `/** */` so they stay internal —
// JSDoc on a template declaration would otherwise be hoisted to every
// inheriting operation as the OpenAPI `description`.
//
interface LibreGraphOps {
  // GET a single resource by id (and optional select/expand query).
  @get
  @extension("x-ms-docs-operation-type", "operation")
  getResource<TPath, TResponse, TQuery = {}>(
    ...TPath,
    ...TQuery,
  ): TResponse | OdataError;

  // GET a collection.
  @get
  @extension("x-ms-docs-operation-type", "operation")
  listCollection<TResponse, TQuery = {}>(
    ...TQuery,
  ): TResponse | OdataError;

  // POST a new resource.
  @post
  @extension("x-ms-docs-operation-type", "operation")
  createResource<
    TBody,
    TResponse,
    TPath = {},
    TBodyDoc extends valueof string = "New entity"
  >(
    ...TPath,
    @doc(TBodyDoc)
    @body
    body: TBody,
  ): TResponse | OdataError;

  // PATCH an existing resource.
  @patch
  @extension("x-ms-docs-operation-type", "operation")
  updateResource<
    TPath,
    TBody,
    TResponse,
    TBodyDoc extends valueof string = "New property values"
  >(
    ...TPath,
    @doc(TBodyDoc)
    @body
    body: TBody,
  ): TResponse | OdataError;

  // DELETE a resource. Returns 204. Accepts the standard `If-Match` ETag header.
  @delete
  @extension("x-ms-docs-operation-type", "operation")
  deleteResource<TPath, TError = OdataError>(
    ...TPath,

    @header("If-Match")
    @doc("ETag")
    ifMatch?: string,
  ): NoContentSuccess | TError;

  // DELETE a resource that does not advertise an `If-Match` header.
  @delete
  @extension("x-ms-docs-operation-type", "operation")
  deleteResourceWithoutEtag<TPath, TError = OdataError>(
    ...TPath,
  ): NoContentSuccess | TError;

  // POST an `@odata.id` reference body to attach a related entity.
  @post
  @extension("x-ms-docs-operation-type", "operation")
  addRef<TPath, TBody, TBodyDoc extends valueof string = "Object to be added as member">(
    ...TPath,
    @doc(TBodyDoc)
    @body
    body: TBody,
  ): NoContentSuccess | OdataError;

  // DELETE an `@odata.id` reference between entities.
  @delete
  @extension("x-ms-docs-operation-type", "operation")
  deleteRef<TPath>(
    ...TPath,
  ): NoContentSuccess | OdataError;
}
