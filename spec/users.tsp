import "@typespec/http";
import "@typespec/openapi";
import "@typespec/json-schema";

import "./common.models.tsp";

using Http;
using OpenAPI;


namespace LibreGraph;

// =============================================================================
// User entity
// =============================================================================

@doc("Represents an identity used to sign in to a user account")
model objectIdentity {
  @doc("domain of the Provider issuing the identity")
  issuer?: string;

  @doc("The unique id assigned by the issuer to the account")
  issuerAssignedId?: string;
}

@doc("Password Profile associated with a user")
model passwordProfile {
  @doc("If true the user is required to change their password upon the next login")
  forceChangePasswordNextSignIn?: boolean = false;

  // `@extension("writeOnly", true)` emits the JSON Schema `writeOnly`
  // flag directly. The idiomatic TypeSpec equivalent
  // `@visibility(Lifecycle.Create, Lifecycle.Update)` would also work
  // semantically but triggers Read/Update variant generation for every
  // model that transitively references `passwordProfile`
  // (`userBase`, `educationUser`, …); the resulting auto-variant for
  // `userResource` then collides with `userBase`'s
  // `@friendlyName("userUpdate")` and the build fails with
  // `duplicate-type-name: 'userUpdate'`.
  @doc("The user's password")
  @extension("writeOnly", true)
  password?: string;
}

@doc("Provides the last successful sign-in attempt for a user")
model signInActivity {
  @doc("The date and time of the last successful sign-in for the user.")
  lastSuccessfulSignInDateTime?: utcDateTime;
}

@doc("Represents the users language setting, ISO-639-1 Code")
scalar language extends string;

model appRoleAssignment {
  @extension("readOnly", true)
  @doc("The unique identifier for the object. 12345678-9abc-def0-1234-56789abcde. The value of the ID property is often, but not exclusively, in the form of a GUID. The value should be treated as an opaque identifier and not based in being a GUID. Null values are not allowed. Read-only.")
  id?: string;

  @extension("pattern", "^[0-9]{4,}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])[Tt]([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]([.][0-9]{1,12})?([Zz]|[+-][0-9][0-9]:[0-9][0-9])$")
  deletedDateTime?: utcDateTime;

  @doc("The identifier (id) for the app role which is assigned to the user. Required on create.")
  @pattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")
  @format("uuid")
  appRoleId: string;

  @extension("pattern", "^[0-9]{4,}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])T([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]([.][0-9]{1,12})?(Z|[+-][0-9][0-9]:[0-9][0-9])$")
  @doc("The time when the app role assignment was created. The Timestamp type represents date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z. Read-only.")
  createdDateTime?: utcDateTime | null;

  @doc("The display name of the user, group, or service principal that was granted the app role assignment. Read-only.")
  principalDisplayName?: string | null;

  @doc("The unique identifier (id) for the user, security group, or service principal being granted the app role. Security groups with dynamic memberships are supported. Required on create.")
  @pattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")
  @format("uuid")
  principalId: string | null;

  @doc("The type of the assigned principal. This can either be User, Group, or ServicePrincipal. Read-only.")
  principalType?: string | null;

  @doc("The display name of the resource app's service principal to which the assignment is made.")
  resourceDisplayName?: string | null;

  @doc("The unique identifier (id) for the resource service principal for which the assignment is made. Required on create.")
  @pattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")
  @format("uuid")
  resourceId: string | null;
}

@friendlyName("userUpdate")
@doc("Represents updates to an Active Directory user object.")
model userBase {
  @extension("readOnly", true)
  @doc("Read-only.")
  id?: string;

  @doc("Set to \"true\" when the account is enabled.")
  accountEnabled?: boolean;

  @extension("readOnly", true)
  @doc("The apps and app roles which this user has been assigned.")
  appRoleAssignments?: appRoleAssignment[];

  @doc("The name displayed in the address book for the user. This value is usually the combination of the user's first name, middle initial, and last name. This property is required when a user is created and it cannot be cleared during updates. Returned by default. Supports $orderby.")
  displayName?: string;

  @extension("readOnly", true)
  @doc("A collection of drives available for this user. Read-only.")
  @maxItems(100)
  drives?: driveResource[];

  @extension("readOnly", true)
  @doc("The personal drive of this user. Read-only.")
  drive?: driveResource;

  @doc("Identities associated with this account.")
  identities?: objectIdentity[];

  @doc("The SMTP address for the user, for example, 'jeff@contoso.opencloud.com'. Returned by default.")
  mail?: string;

  @extension("readOnly", true)
  @doc("Groups that this user is a member of. HTTP Methods: GET (supported for all groups). Read-only. Nullable. Supports $expand.")
  memberOf?: groupModel[];

  @doc("Contains the on-premises SAM account name synchronized from the on-premises directory.")
  onPremisesSamAccountName?: string;

  passwordProfile?: passwordProfile;

  @doc("The user's surname (family name or last name). Returned by default.")
  surname?: string;

  @doc("The user's givenName. Returned by default.")
  givenName?: string;

  @extension("readOnly", true)
  @doc("The user`s type. This can be either \"Member\" for regular user, \"Guest\" for guest users or \"Federated\" for users imported from a federated instance.")
  userType?: string;

  preferredLanguage?: language;

  @extension("readOnly", true)
  signInActivity?: signInActivity;
}

@friendlyName("user")
@doc("Represents an Active Directory user object.")
model userResource extends userBase {
  @doc("The name displayed in the address book for the user. This value is usually the combination of the user's first name, middle initial, and last name. This property is required when a user is created and it cannot be cleared during updates. Returned by default. Supports $orderby.")
  displayName: string;

  @doc("Contains the on-premises SAM account name synchronized from the on-premises directory.")
  onPremisesSamAccountName: string;
}

// =============================================================================
// Shared parameters / response shapes
// =============================================================================

@friendlyName("usersFilter")
model UsersFilter {
  @query
  @doc("Filter users by property values and relationship attributes")
  `$filter`?: string;
}

model UserIdPath {
  @path
  @extension("x-ms-docs-key-type", "user")
  @doc("key: id or name of user")
  `user-id`: string;
}

@doc("Retrieved entities")
model UsersRetrieved {
  @statusCode _: 200;
  @body body: usersResponse;
}

alias usersResponse = PaginatedCollection<userResource, "CollectionOfUser">;

@doc("Created entity")
model UserCreated {
  @statusCode _: 201;
  @body body: userResource;
}

@doc("Retrieved entity")
model UserRetrieved {
  @statusCode _: 200;
  @body body: userResource;
}

@doc("Retrieved appRoleAssignments")
model AppRoleAssignmentsRetrieved {
  @statusCode _: 200;
  @body body: appRoleAssignmentsResponse;
}

alias appRoleAssignmentsResponse = PaginatedCollectionWithMaxItems<appRoleAssignment, "CollectionOfAppRoleAssignments", 100>;

@doc("Created new app role assignment.")
model AppRoleAssignmentCreated {
  @statusCode _: 200;
  @body body: appRoleAssignment;
}

@doc("Retrieved photo")
model UserPhotoRetrieved {
  @statusCode _: 200;
  @header contentType: "image/jpeg";
  @body body: bytes;
}

model exportPersonalDataRequest {
  @doc("the path where the file should be created in the users personal space")
  storageLocation?: string;
}

@doc("success")
model ExportPersonalDataAccepted {
  @statusCode _: 202;
}

// =============================================================================
// /v1.0/users
// =============================================================================

@route("/v1.0/users")
namespace Users {

  @summary("Get entities from users")
  @operationId("ListUsers")
  @tag("users")
  @extension(
    "x-ms-pageable",
    #{ nextLinkName: "@odata.nextLink", operationName: "listMore" }
  )
  @extension("x-ms-docs-operation-type", "operation")
  @get
  op listUsers(
    ...SearchParam,
    ...UsersFilter,

    @TypeSpec.JsonSchema.uniqueItems
    @query(#{ explode: false })
    @doc("Order items by property values")
    `$orderby`?: (
      | "displayName"
      | "displayName desc"
      | "mail"
      | "mail desc"
      | "onPremisesSamAccountName"
      | "onPremisesSamAccountName desc"
    )[],

    @TypeSpec.JsonSchema.uniqueItems
    @query(#{ explode: false })
    @doc("Select properties to be returned")
    `$select`?: (
      | "id"
      | "displayName"
      | "mail"
      | "memberOf"
      | "onPremisesSamAccountName"
      | "surname"
    )[],

    @TypeSpec.JsonSchema.uniqueItems
    @query(#{ explode: false })
    @doc("Expand related entities")
    `$expand`?: ("drive" | "drives" | "memberOf" | "appRoleAssignments")[],
  ): UsersRetrieved | OdataError;

  @summary("Add new entity to users")
  @operationId("CreateUser")
  @tag("users")
  @extension("x-ms-docs-operation-type", "operation")
  @post
  op createUser(
    @doc("New entity")
    @body
    body: userResource,
  ): UserCreated | OdataError;
}

// =============================================================================
// /v1.0/users/{user-id}
// =============================================================================

@route("/v1.0/users/{user-id}")
namespace User {

  @summary("Get entity from users by key")
  @operationId("GetUser")
  @tag("user")
  @extension("x-ms-docs-operation-type", "operation")
  @get
  op getUser(
    ...UserIdPath,

    @TypeSpec.JsonSchema.uniqueItems
    @query(#{ explode: false })
    @doc("Select properties to be returned")
    `$select`?: (
      | "id"
      | "displayName"
      | "drive"
      | "drives"
      | "mail"
      | "memberOf"
      | "onPremisesSamAccountName"
      | "surname"
    )[],

    @TypeSpec.JsonSchema.uniqueItems
    @query(#{ explode: false })
    @doc("Expand related entities")
    `$expand`?: ("drive" | "drives" | "memberOf" | "appRoleAssignments")[],
  ): UserRetrieved | OdataError;

  @summary("Update entity in users")
  @operationId("UpdateUser")
  @opExample(
    #{
      parameters: #{
        `user-id`: "90eedea1-dea1-90ee-a1de-ee90a1deee90",
        body: #{displayName: "Marie Skłodowska Curie"},
      },
    },
    #{ title: "change displayName" }
  )
  @opExample(
    #{
      parameters: #{
        `user-id`: "90eedea1-dea1-90ee-a1de-ee90a1deee90",
        body: #{mail: "marie@example.com"},
      },
    },
    #{ title: "change email" }
  )
  @opExample(
    #{
      parameters: #{
        `user-id`: "90eedea1-dea1-90ee-a1de-ee90a1deee90",
        body: #{preferredLanguage: "fr"},
      },
    },
    #{ title: "change preferred language" }
  )
  @tag("user")
  @extension("x-ms-docs-operation-type", "operation")
  @patch
  op updateUser(
    ...UserIdPath,
    @doc("New property values")
    @body
    body: userBase,
  ): UserRetrieved | OdataError;

  @summary("Delete entity from users")
  @operationId("DeleteUser")
  @tag("user")
  @extension("x-ms-docs-operation-type", "operation")
  @delete
  op deleteUser(
    ...UserIdPath,

    @header("If-Match")
    @doc("ETag")
    ifMatch?: string,
  ): NoContentSuccess | OdataError;
}

// =============================================================================
// /v1.0/users/{user-id}/exportPersonalData
// =============================================================================

@route("/v1.0/users/{user-id}/exportPersonalData")
namespace UserExportPersonalData {

  @summary("export personal data of a user")
  @operationId("ExportPersonalData")
  @tag("user")
  @extension("x-ms-docs-operation-type", "operation")
  @post
  op exportPersonalData(
    ...UserIdPath,
    @doc("destination the file should be created at")
    @body
    body?: exportPersonalDataRequest,
  ): ExportPersonalDataAccepted | OdataError;
}

// =============================================================================
// /v1.0/users/{user-id}/appRoleAssignments
// =============================================================================

@route("/v1.0/users/{user-id}/appRoleAssignments")
namespace UserAppRoleAssignments {

  @summary("Get appRoleAssignments from a user")
  @doc("Represents the global roles a user has been granted for an application.")
  @operationId("user.ListAppRoleAssignments")
  @tag("user.appRoleAssignment")
  @get
  op listAppRoleAssignments(
    @path
    @doc("key: id of user")
    `user-id`: string,
  ): AppRoleAssignmentsRetrieved | OdataError;

  @summary("Grant an appRoleAssignment to a user")
  @doc("""
    Use this API to assign a global role to a user. To grant an app role assignment to a user, you need three identifiers:
    * `principalId`: The `id` of the user to whom you are assigning the app role.
    * `resourceId`: The `id` of the resource `servicePrincipal` or `application` that has defined the app role.
    * `appRoleId`: The `id` of the `appRole` (defined on the resource service principal or application) to assign to the user.
    """)
  @operationId("user.CreateAppRoleAssignments")
  @tag("user.appRoleAssignment")
  @post
  op createAppRoleAssignments(
    @path
    @doc("key: id of user")
    `user-id`: string,

    @doc("New app role assignment value")
    @body
    body: appRoleAssignment,
  ): AppRoleAssignmentCreated | OdataError;
}

// =============================================================================
// /v1.0/users/{user-id}/appRoleAssignments/{appRoleAssignment-id}
// =============================================================================

@route("/v1.0/users/{user-id}/appRoleAssignments/{appRoleAssignment-id}")
namespace UserAppRoleAssignment {

  @summary("Delete the appRoleAssignment from a user")
  @operationId("user.DeleteAppRoleAssignments")
  @tag("user.appRoleAssignment")
  @delete
  op deleteAppRoleAssignments(
    @path
    @doc("key: id of user")
    `user-id`: string,

    @path
    @doc("key: id of appRoleAssignment. This is the concatenated {user-id}:{appRole-id} separated by a colon.")
    `appRoleAssignment-id`: string,

    @header("If-Match")
    @doc("ETag")
    ifMatch?: string,
  ): NoContentSuccess | OdataError;
}

// =============================================================================
// /v1.0/users/{user-id}/photo/$value
// =============================================================================

@route("/v1.0/users/{user-id}/photo/$value")
namespace UserPhoto {

  @summary("Get the photo of a user")
  @operationId("GetUserPhoto")
  @tag("user.photo")
  @get
  op getUserPhoto(...UserIdPath): UserPhotoRetrieved | OdataError;
}
