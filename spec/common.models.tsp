import "@typespec/http";
import "@typespec/openapi";

using Http;
using OpenAPI;

namespace LibreGraph;

// Cross-cutting building blocks every domain reaches for. Anything that
// belongs to a specific entity (users, groups, drives, …) lives in that
// entity's own file.

// -----------------------------------------------------------------------------
// OData error response
// -----------------------------------------------------------------------------

@friendlyName("odata.error.detail")
model OdataErrorDetail {
  code: string;
  message: string;
  target?: string;
}

@friendlyName("odata.error.main")
model OdataErrorMain {
  code: string;
  message: string;
  target?: string;
  details?: OdataErrorDetail[];

  @doc("The structure of this object is service-specific")
  innererror?: {};
}

@friendlyName("odata.error")
@error
model OdataError {
  error: OdataErrorMain;
}

// -----------------------------------------------------------------------------
// Generic success status with no body
// -----------------------------------------------------------------------------

@doc("Success")
model NoContentSuccess {
  @statusCode _: 204;
}

// -----------------------------------------------------------------------------
// Generic OData query parameters. Named so they emit as
// `#/components/parameters/{count,top}` and can be spread into any list
// operation that needs them.
// -----------------------------------------------------------------------------

@friendlyName("count")
model CountParam {
  @query
  @doc("Include count of items")
  `$count`?: boolean;
}

@friendlyName("top")
model TopParam {
  @query
  @doc("Show only the first n items")
  @minValue(0)
  `$top`?: integer;
}

@friendlyName("search")
model SearchParam {
  @query
  @doc("Search items by search phrases")
  `$search`?: string;
}
