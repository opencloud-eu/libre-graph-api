import "@typespec/http";
import "@typespec/openapi";
import "@typespec/json-schema";

import "./common.models.tsp";

using Http;
using OpenAPI;


namespace LibreGraph;

// =============================================================================
// Group entity
// =============================================================================

@friendlyName("group")
model groupModel {
  @extension("readOnly", true)
  @doc("Read-only.")
  id?: string;

  @doc("An optional description for the group. Returned by default.")
  description?: string;

  @doc("The display name for the group. This property is required when a group is created and cannot be cleared during updates. Returned by default. Supports $search and $orderBy.")
  displayName?: string;

  @doc("Specifies the group types. In MS Graph a group can have multiple types, so this is an array. In libreGraph the possible group types deviate from the MS Graph. The only group type that we currently support is \"ReadOnly\", which is set for groups that cannot be modified on the current instance.")
  groupTypes?: string[];

  @doc("Users and groups that are members of this group. HTTP Methods: GET (supported for all groups), Nullable. Supports $expand.")
  members?: userResource[];

  @minItems(1)
  @maxItems(20)
  @doc("A list of member references to the members to be added. Up to 20 members can be added with a single request")
  `members@odata.bind`?: string[];
}

// =============================================================================
// Shared query parameters / response shapes
// =============================================================================

model GroupIdPath {
  @path
  @extension("x-ms-docs-key-type", "group")
  @doc("key: id or name of group")
  `group-id`: string;
}

@doc("Retrieved entities")
model GroupsRetrieved {
  @statusCode _: 200;
  @body body: groupsResponse;
}

alias groupsResponse = PaginatedCollection<groupModel, "CollectionOfGroup">;

@doc("Created entity")
model GroupCreated {
  @statusCode _: 201;
  @body body: groupModel;
}

@doc("Retrieved entity")
model GroupRetrieved {
  @statusCode _: 200;
  @body body: groupModel;
}

@doc("Retrieved group members")
model GroupMembersRetrieved {
  @statusCode _: 200;
  @body body: groupMembersResponse;
}

alias groupMembersResponse = Collection<userResource, "CollectionOfUsers">;

@friendlyName("MemberReference")
model memberReference {
  `@odata.id`?: string;
}

// =============================================================================
// Operations
// =============================================================================

@route("/v1.0/groups")
namespace Groups {

  @summary("Get entities from groups")
  @operationId("ListGroups")
  @tag("groups")
  @extension(
    "x-ms-pageable",
    #{ nextLinkName: "@odata.nextLink", operationName: "listMore" }
  )
  @extension("x-ms-docs-operation-type", "operation")
  @get
  op listGroups(
    ...SearchParam,

    @TypeSpec.JsonSchema.uniqueItems
    @query(#{ explode: false })
    @doc("Order items by property values")
    `$orderby`?: ("displayName" | "displayName desc")[],

    @TypeSpec.JsonSchema.uniqueItems
    @query(#{ explode: false })
    @doc("Select properties to be returned")
    `$select`?: ("id" | "description" | "displayName" | "mail" | "members")[],

    @TypeSpec.JsonSchema.uniqueItems
    @query(#{ explode: false })
    @doc("Expand related entities")
    `$expand`?: "members"[],
  ): GroupsRetrieved | OdataError;

  @summary("Add new entity to groups")
  @operationId("CreateGroup")
  @tag("groups")
  @extension("x-ms-docs-operation-type", "operation")
  @post
  op createGroup(
    @doc("New entity")
    @body
    body: groupModel,
  ): GroupCreated | OdataError;
}

@route("/v1.0/groups/{group-id}")
namespace Group {

  @summary("Get entity from groups by key")
  @operationId("GetGroup")
  @tag("group")
  @extension("x-ms-docs-operation-type", "operation")
  @get
  op getGroup(
    ...GroupIdPath,

    @TypeSpec.JsonSchema.uniqueItems
    @query(#{ explode: false })
    @doc("Select properties to be returned")
    `$select`?: ("id" | "description" | "displayName" | "members")[],

    @TypeSpec.JsonSchema.uniqueItems
    @query(#{ explode: false })
    @doc("Expand related entities")
    `$expand`?: "members"[],
  ): GroupRetrieved | OdataError;

  @summary("Update entity in groups")
  @operationId("UpdateGroup")
  @opExample(
    #{
      parameters: #{
        `group-id`: "00000000-0000-0000-0000-000000000000",
        body: #{displayName: "GroupName"},
      },
    },
    #{ title: "update name" }
  )
  @opExample(
    #{
      parameters: #{
        `group-id`: "00000000-0000-0000-0000-000000000000",
        body: #{
          `members@odata.bind`: #[
            "https://localhost:9200/graph/v1.0/users/4c510ada-c86b-4815-8820-42cdf82c3d51",
            "https://localhost:9200/graph/v1.0/users/c54b0588-7157-4521-bb52-c1c8ca84ea71",
          ],
        },
      },
    },
    #{ title: "add multiple members" }
  )
  @tag("group")
  @extension("x-ms-docs-operation-type", "operation")
  @patch
  op updateGroup(
    ...GroupIdPath,
    @doc("New property values")
    @body
    body: groupModel,
  ): NoContentSuccess | OdataError;

  @summary("Delete entity from groups")
  @operationId("DeleteGroup")
  @tag("group")
  @extension("x-ms-docs-operation-type", "operation")
  @delete
  op deleteGroup(
    ...GroupIdPath,

    @header("If-Match")
    @doc("ETag")
    ifMatch?: string,
  ): NoContentSuccess | OdataError;
}

@route("/v1.0/groups/{group-id}/members")
namespace GroupMembers {

  @summary("Get a list of the group's direct members")
  @operationId("ListMembers")
  @opExample(
    #{
      parameters: #{`group-id`: "00000000-0000-0000-0000-000000000000"},
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "90eedea1-dea1-90ee-a1de-ee90a1deee90",
              onPremisesSamAccountName: "max.mustermann",
              displayName: "Max Mustermann",
              mail: "max.musterman@example.org",
            },
          ],
        },
      },
    },
    #{ title: "ListMembers_default_resp" }
  )
  @tag("group")
  @get
  op listMembers(
    @path
    @doc("key: id or name of group")
    `group-id`: string,
  ): GroupMembersRetrieved | OdataError;
}

@route("/v1.0/groups/{group-id}/members/$ref")
namespace GroupMembersRef {

  @summary("Add a member to a group")
  @operationId("AddMember")
  @tag("group")
  @extension("x-ms-docs-operation-type", "operation")
  @post
  op addMember(
    ...GroupIdPath,
    @doc("Object to be added as member")
    @body
    body: memberReference,
  ): NoContentSuccess | OdataError;
}

@route("/v1.0/groups/{group-id}/members/{directory-object-id}/$ref")
namespace GroupMemberRef {

  @summary("Delete member from a group")
  @operationId("DeleteMember")
  @tag("group")
  @extension("x-ms-docs-operation-type", "operation")
  @delete
  op deleteMember(
    ...GroupIdPath,

    @path
    @doc("key: id of group member to remove")
    `directory-object-id`: string,

    @header("If-Match")
    @doc("ETag")
    ifMatch?: string,
  ): NoContentSuccess | OdataError;
}
