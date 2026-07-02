import "@typespec/http";
import "@typespec/openapi";

import "./common.models.tsp";

using Http;
using OpenAPI;

namespace LibreGraph;

@friendlyName("appRole")
model appRoleModel {
  @doc("Specifies whether this app role can be assigned to users and groups (by setting to ['User']), to other application's (by setting to ['Application'], or both (by setting to ['User', 'Application']). App roles supporting assignment to other applications' service principals are also known as application permissions. The 'Application' value is only supported for app roles defined on application entities.")
  allowedMemberTypes?: string[];

  @doc("The description for the app role. This is displayed when the app role is being assigned and, if the app role functions as an application permission, during  consent experiences.")
  description?: string | null;

  @doc("Display name for the permission that appears in the app role assignment and consent experiences.")
  displayName?: string | null;

  @doc("Unique role identifier inside the appRoles collection. When creating a new app role, a new GUID identifier must be provided.")
  @pattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")
  @format("uuid")
  id: string;
}

model application {
  @extension("readOnly", true)
  @doc("The unique identifier for the object. 12345678-9abc-def0-1234-56789abcde. The value of the ID property is often, but not exclusively, in the form of a GUID. The value should be treated as an opaque identifier and not based in being a GUID. Null values are not allowed. Read-only.")
  id: string;

  @doc("The collection of roles defined for the application. With app role assignments, these roles can be assigned to users, groups, or service principals associated with other applications. Not nullable.")
  appRoles?: appRoleModel[] | null;

  @doc("The display name for the application.")
  displayName?: string | null;
}

@doc("Retrieved entities")
model ApplicationsRetrieved {
  @statusCode _: 200;
  @body body: applicationsResponse;
}

alias applicationsResponse = Collection<application, "CollectionOfApplications">;

@doc("OK")
model ApplicationRetrieved {
  @statusCode _: 200;
  @body body: application;
}

@route("/v1.0/applications")
namespace Applications {

  @summary("Get all applications")
  @operationId("ListApplications")
  @tag("applications")
  @get
  op listApplications(): ApplicationsRetrieved | OdataError;
}

@route("/v1.0/applications/{application-id}")
namespace Application {

  @summary("Get application by id")
  @operationId("GetApplication")
  @tag("applications")
  @get
  op getApplication(
    @path
    @doc("key: id of application")
    `application-id`: string,
  ): ApplicationRetrieved | OdataError;
}
