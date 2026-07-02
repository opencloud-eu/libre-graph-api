import "@typespec/http";
import "@typespec/openapi";
import "@typespec/json-schema";

import "./common.models.tsp";

using Http;
using OpenAPI;


namespace LibreGraph;

@doc("Represents a school")
model educationSchool {
  @extension("readOnly", true)
  @doc("The unique identifier for an entity. Read-only.")
  id?: string;

  @doc("The organization name")
  displayName?: string;

  @doc("School number")
  schoolNumber?: string;

  @doc("External identifier of the school")
  externalId?: string;

  @doc("Date and time at which the service for this organization is scheduled to be terminated")
  terminationDate?: utcDateTime | null;
}

@doc("An extension of group representing a class or course")
model educationClass {
  @extension("readOnly", true)
  @doc("Read-only.")
  id?: string;

  @doc("An optional description for the group. Returned by default.")
  description?: string;

  @doc("The display name for the group. This property is required when a group is created and cannot be cleared during updates. Returned by default. Supports $search and $orderBy.")
  displayName: string;

  @doc("Users and groups that are members of this group. HTTP Methods: GET (supported for all groups), Nullable. Supports $expand.")
  members?: userResource[];

  @minItems(1)
  @maxItems(20)
  @doc("A list of member references to the members to be added. Up to 20 members can be added with a single request")
  `members@odata.bind`?: string[];

  @doc("Classification of the group, i.e. \"class\" or \"course\"")
  classification: "class" | "course";

  @doc("An external unique ID for the class")
  externalId?: string;
}

@doc("An extension of user with education-specific attributes")
model educationUser {
  @extension("readOnly", true)
  @doc("Read-only.")
  id?: string;

  @doc("Set to \"true\" when the account is enabled.")
  accountEnabled?: boolean;

  @doc("The name displayed in the address book for the user. This value is usually the combination of the user's first name, middle initial, and last name. This property is required when a user is created and it cannot be cleared during updates. Returned by default. Supports $orderby.")
  displayName?: string;

  @extension("readOnly", true)
  @doc("A collection of drives available for this user. Read-only.")
  @maxItems(100)
  drives?: driveResource[];

  @extension("readOnly", true)
  @doc("The personal drive of this user. Read-only.")
  drive?: driveResource;

  @doc("An external unique ID for the user. Use it to associate a user in another system, such as a student or employee ID number.")
  externalId?: string;

  @doc("Identities associated with this account.")
  identities?: objectIdentity[];

  @doc("The SMTP address for the user, for example, 'jeff@contoso.opencloud.com'. Returned by default.")
  mail?: string;

  @doc("Groups that this user is a member of. HTTP Methods: GET (supported for all groups). Read-only. Nullable. Supports $expand.")
  memberOf?: groupModel[];

  @doc("Contains the on-premises SAM account name synchronized from the on-premises directory. Read-only.")
  onPremisesSamAccountName?: string;

  passwordProfile?: passwordProfile;

  @doc("The user's surname (family name or last name). Returned by default.")
  surname?: string;

  @doc("The user's givenName. Returned by default.")
  givenName?: string;

  @doc("The user`s default role. Such as \"student\" or \"teacher\"")
  primaryRole?: string;

  @doc("The user`s type. This can be either \"Member\" for regular user, \"Guest\" for guest users or \"Federated\" for users imported from a federated instance.")
  userType?: string;
}

// =============================================================================
// Shared response shapes / path parameters
// =============================================================================

model EducationUserIdPath {
  @path
  @doc("key: id or username of user")
  @example("90eedea1-dea1-90ee-a1de-ee90a1deee90", #{ title: "id" })
  @example("max.mustermann", #{ title: "name" })
  `user-id`: string;
}

model SchoolIdPath {
  @path
  @doc("key: id or schoolNumber of school")
  `school-id`: string;
}

model ClassIdPath {
  @path
  @doc("key: id or externalId of class")
  `class-id`: string;
}

@doc("Retrieved entities")
model EducationUsersRetrieved {
  @statusCode _: 200;
  @body body: educationUsersResponse;
}

alias educationUsersResponse = Collection<educationUser, "CollectionOfEducationUser">;

@doc("Created entity")
model EducationUserCreated {
  @statusCode _: 201;
  @body body: educationUser;
}

@doc("Retrieved entity")
model EducationUserRetrieved {
  @statusCode _: 200;
  @body body: educationUser;
}

@doc("Success")
model EducationUserUpdated {
  @statusCode _: 200;
  @body body: educationUser;
}

@doc("Success")
model EducationUserUpdatedNoContent {
  @statusCode _: 204;
}

@doc("User not found")
@error
model UserNotFound {
  @statusCode _: 404;
}

@doc("Retrieved entities")
model SchoolsRetrieved {
  @statusCode _: 200;
  @body body: schoolsResponse;
}

alias schoolsResponse = Collection<educationSchool, "CollectionOfSchools">;

@doc("Created entity")
model SchoolCreated {
  @statusCode _: 201;
  @body body: educationSchool;
}

@doc("Retrieved entity")
model SchoolRetrieved {
  @statusCode _: 200;
  @body body: educationSchool;
}

@doc("Success")
model SchoolUpdated {
  @statusCode _: 200;
  @body body: educationSchool;
}

@doc("Retrieved educationUser")
model SchoolUsersRetrieved {
  @statusCode _: 200;
  @body body: educationUsersResponse;
}

@doc("Retrieved classes")
model SchoolClassesRetrieved {
  @statusCode _: 200;
  @body body: educationClassesResponse;
}

alias educationClassesResponse = Collection<educationClass, "CollectionOfEducationClass">;

@friendlyName("EducationUserReference")
model educationUserReference {
  `@odata.id`?: string;
}

@friendlyName("ClassReference")
model classReference {
  `@odata.id`?: string;
}

@friendlyName("ClassMemberReference")
model classMemberReference {
  `@odata.id`?: string;
}

@friendlyName("ClassTeacherReference")
model classTeacherReference {
  `@odata.id`?: string;
}

@doc("Retrieved entities")
model ClassesRetrieved {
  @statusCode _: 200;
  @body body: classesResponse;
}

alias classesResponse = Collection<educationClass, "CollectionOfClass">;

@doc("Created entity")
model ClassCreated {
  @statusCode _: 201;
  @body body: educationClass;
}

@doc("Retrieved entity")
model ClassRetrieved {
  @statusCode _: 200;
  @body body: educationClass;
}

@doc("New property values")
model ClassUpdated {
  @statusCode _: 200;
  @body body: educationClass;
}

@doc("Retrieved class members")
model ClassMembersRetrieved {
  @statusCode _: 200;
  @body body: educationUsersResponse;
}

@doc("Retrieved class teachers")
model ClassTeachersRetrieved {
  @statusCode _: 200;
  @body body: educationUsersResponse;
}

// =============================================================================
// Shared query / compound-path models
// =============================================================================

// Each `$`-prefixed query parameter lives in its own single-field model
// so the openapi3 emitter can hoist it into `#/components/parameters/<name>`
// using the @friendlyName as the key. A single model holding several
// `$`-prefixed properties would force the emitter to disambiguate the
// component keys as `<ModelName>.$<field>` — and OpenAPI rejects `$` in
// component keys, so the emitter would sanitize it to `_` and warn.

@friendlyName("educationUsersFilter")
model EducationUsersFilter {
  @query
  @doc("""
    Filter items by property values. Supports a subset of OData filter expressions.

    **Supported filters:**
    - By external ID: `externalId eq 'ext_12345'`
    """)
  @example("externalId eq 'ext_12345'", #{ title: "externalId", description: "Filter by external ID" })
  `$filter`?: string;
}

@friendlyName("educationUsersOrderBy")
model EducationUsersOrderBy {
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
  )[];
}

@friendlyName("educationUserExpand")
model EducationUserExpand {
  @TypeSpec.JsonSchema.uniqueItems
  @query(#{ explode: false })
  @doc("Expand related entities")
  `$expand`?: "memberOf"[];
}

@friendlyName("schoolsFilter")
model SchoolsFilter {
  @query
  @doc("""
    Filter items by property values. Supports a subset of OData filter expressions.

    **Supported filters:**
    - By external ID: `externalId eq 'ext_12345'`
    """)
  @example("externalId eq 'ext_12345'", #{ title: "externalId", description: "Filter by external ID" })
  `$filter`?: string;
}

model SchoolAndUserIdPath {
  ...SchoolIdPath;

  @path
  @doc("key: id or username of the user to unassign from school")
  `user-id`: string;
}

model SchoolAndClassIdPath {
  ...SchoolIdPath;

  @path
  @doc("key: id or externalId of the class to unassign from school")
  `class-id`: string;
}

model ClassAndUserIdPath {
  ...ClassIdPath;

  @path
  @doc("key: id or username of the user to unassign from class")
  `user-id`: string;
}

model ClassAndTeacherIdPath {
  ...ClassIdPath;

  @path
  @doc("key: id or username of the user to unassign as teacher")
  `user-id`: string;
}

// =============================================================================
// /v1.0/education/users
// =============================================================================

@route("/v1.0/education/users")
@useAuth(bearerAuth)
namespace EducationUsers {

  // Multiple $-prefixed query params force this op to skip the
  // `listCollection<TResponse, TQuery>` template — the template's single
  // TQuery slot can't hold three independently-component-named query
  // models without remerging them into a multi-field shape that re-trips
  // the openapi3 emitter's `$`-in-component-key warning.
  @summary("Get entities from education users")
  @doc("""
    Retrieves a collection of education users with optional filtering, ordering, and expansion.

    **Filtering by external ID:**
    Use `$filter` to query users by their external identifier, for example:
    `$filter=externalId eq 'EX12345'`
    """)
  @operationId("ListEducationUsers")
  @opExample(
    #{
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "90eedea1-dea1-90ee-a1de-ee90a1deee90",
              onPremisesSamAccountName: "max.mustermann",
              displayName: "Max Mustermann",
              mail: "max.musterman@example.org",
              primaryRole: "student",
              identities: #[
                #{
                  issuer: "idp.school.com",
                  issuerAssignedId: "max.mustermann",
                },
                #{issuer: "newidp.school.com", issuerAssignedId: "ieZ2AeV5"},
              ],
            },
          ],
        },
      },
    },
    #{ title: "ListEducationUsers_default_resp" }
  )
  @tag("educationUser")
  @extension("x-ms-docs-operation-type", "operation")
  @get
  op listEducationUsers(
    ...EducationUsersFilter,
    ...EducationUsersOrderBy,
    ...EducationUserExpand,
  ): EducationUsersRetrieved | OdataError;

  @summary("Add new education user")
  @operationId("CreateEducationUser")
  @opExample(
    #{
      parameters: #{
        body: #{
          onPremisesSamAccountName: "max.mustermann",
          displayName: "Max Mustermann",
          surname: "Mustermann",
          givenName: "Max",
          mail: "max.musterman@example.org",
          primaryRole: "student",
          identities: #[
            #{
              issuer: "idp.school.com",
              issuerAssignedId: "max.mustermann",
            },
          ],
        },
      },
    },
    #{ title: "Student User Creation", description: "Example request body for creating a new student user.\n" }
  )
  @opExample(
    #{
      parameters: #{
        body: #{
          onPremisesSamAccountName: "max.mustermann",
          displayName: "Max Mustermann",
          externalId: "EX12345",
          surname: "Mustermann",
          givenName: "Max",
          mail: "max.musterman@example.org",
        },
      },
    },
    #{ title: "Users with externalId", description: "Example for creating a user with an external ID.\n\n**Note:** To delete a user by externalId, first retrieve the user's ID using a filter query, then delete the user using that ID.\n" }
  )
  @opExample(
    #{
      parameters: #{body: #{displayName: "x", onPremisesSamAccountName: "x"}},
      returnType: #{
        _: 201,
        body: #{
          id: "90eedea1-dea1-90ee-a1de-ee90a1deee90",
          onPremisesSamAccountName: "max.mustermann",
          displayName: "Max Mustermann",
          surname: "Mustermann",
          givenName: "Max",
          mail: "max.musterman@example.org",
          primaryRole: "student",
          identities: #[
            #{
              issuer: "idp.school.com",
              issuerAssignedId: "max.mustermann",
            },
          ],
        },
      },
    },
    #{ title: "educationUser" }
  )
  @tag("educationUser")
  op createEducationUser is LibreGraphOps.createResource<educationUser, EducationUserCreated>;
}

@route("/v1.0/education/users/{user-id}")
@useAuth(bearerAuth)
namespace EducationUser {

  @summary("Get properties of educationUser")
  @operationId("GetEducationUser")
  @opExample(
    #{
      parameters: #{`user-id`: "90eedea1-dea1-90ee-a1de-ee90a1deee90"},
      returnType: #{
        _: 200,
        body: #{
          id: "90eedea1-dea1-90ee-a1de-ee90a1deee90",
          onPremisesSamAccountName: "max.mustermann",
          displayName: "Max Mustermann",
          surname: "Mustermann",
          givenName: "Max",
          mail: "max.musterman@example.org",
          primaryRole: "student",
          identities: #[
            #{
              issuer: "idp.school.com",
              issuerAssignedId: "max.mustermann",
            },
          ],
        },
      },
    },
    #{ title: "educationUser" }
  )
  @tag("educationUser")
  op getEducationUser is LibreGraphOps.getResource<
    EducationUserIdPath,
    EducationUserRetrieved,
    EducationUserExpand
  >;

  @summary("Update properties of educationUser")
  @operationId("UpdateEducationUser")
  @opExample(
    #{
      parameters: #{
        `user-id`: "90eedea1-dea1-90ee-a1de-ee90a1deee90",
        body: #{mail: "max.mustermann@new.domain"},
      },
    },
    #{ title: "UpdateEducationUser_default" }
  )
  @opExample(
    #{
      parameters: #{
        `user-id`: "90eedea1-dea1-90ee-a1de-ee90a1deee90",
        body: #{displayName: "x", onPremisesSamAccountName: "x"},
      },
      returnType: #{
        _: 200,
        body: #{
          id: "90eedea1-dea1-90ee-a1de-ee90a1deee90",
          onPremisesSamAccountName: "max.mustermann",
          displayName: "Max Mustermann",
          surname: "Mustermann",
          givenName: "Max",
          mail: "max.musterman@new.domain",
          primaryRole: "student",
          identities: #[
            #{
              issuer: "idp.school.com",
              issuerAssignedId: "max.mustermann",
            },
          ],
        },
      },
    },
    #{ title: "UpdateEducationUser_default_resp" }
  )
  @tag("educationUser")
  op updateEducationUser is LibreGraphOps.updateResource<EducationUserIdPath, educationUser, EducationUserUpdated | EducationUserUpdatedNoContent>;

  @summary("Delete educationUser")
  @doc("""
    Deletes an education user by their internal ID.

    **To delete by external ID:**
    If you only have an external ID, you must first retrieve the user's internal ID:
    1. Call `GET /graph/v1.0/education/users?$filter=externalId eq '{value}'`
    2. Extract the `id` from the response
    3. Use that `id` in this DELETE endpoint

    See the [ListEducationUsers](#/educationUser/ListEducationUsers) operation for query details.
    """)
  @operationId("DeleteEducationUser")
  @tag("educationUser")
  op deleteEducationUser is LibreGraphOps.deleteResourceWithoutEtag<EducationUserIdPath, UserNotFound | OdataError>;
}

// =============================================================================
// /v1.0/education/schools
// =============================================================================

@route("/v1.0/education/schools")
@useAuth(bearerAuth)
namespace Schools {

  @summary("Get a list of schools and their properties")
  @doc("""
    Retrieves a collection of education schools with optional filtering and ordering.

    **Filtering by external ID:**
    Use `$filter` to query schools by their external identifier, for example:
    `$filter=externalId eq 'EX12345'`
    """)
  @operationId("ListSchools")
  @opExample(
    #{
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "0e19303e-8144-44bd-86d8-35cc8ac9c255",
              displayName: "Gymnasium Musterstadt",
              schoolNumber: "0123",
            },
            #{
              id: "43b879c4-14c6-4e0a-9b3f-b1b33c5a4bd4",
              displayName: "Realschule Musterstadt",
              schoolNumber: "1234",
            },
          ],
        },
      },
    },
    #{ title: "ListSchools_default_resp" }
  )
  @tag("educationSchool")
  op listSchools is LibreGraphOps.listCollection<SchoolsRetrieved, SchoolsFilter>;

  @summary("Add new school")
  @operationId("CreateSchool")
  @opExample(
    #{
      parameters: #{
        body: #{displayName: "Realschule Musterstadt", schoolNumber: "1234"},
      },
    },
    #{ title: "educationSchool_post" }
  )
  @opExample(
    #{
      parameters: #{body: #{}},
      returnType: #{
        _: 201,
        body: #{
          id: "43b879c4-14c6-4e0a-9b3f-b1b33c5a4bd4",
          displayName: "Realschule Musterstadt",
          schoolNumber: "1234",
        },
      },
    },
    #{ title: "educationSchool" }
  )
  @tag("educationSchool")
  op createSchool is LibreGraphOps.createResource<educationSchool, SchoolCreated, {}, "New school">;
}

@route("/v1.0/education/schools/{school-id}")
@useAuth(bearerAuth)
namespace School {

  @summary("Get the properties of a specific school")
  @operationId("GetSchool")
  @opExample(
    #{
      parameters: #{`school-id`: "43b879c4-14c6-4e0a-9b3f-b1b33c5a4bd4"},
      returnType: #{
        _: 200,
        body: #{
          id: "43b879c4-14c6-4e0a-9b3f-b1b33c5a4bd4",
          displayName: "Realschule Musterstadt",
          schoolNumber: "1234",
        },
      },
    },
    #{ title: "educationSchool" }
  )
  @tag("educationSchool")
  op getSchool is LibreGraphOps.getResource<SchoolIdPath, SchoolRetrieved>;

  @summary("Update properties of a school")
  @operationId("UpdateSchool")
  @opExample(
    #{
      parameters: #{
        `school-id`: "43b879c4-14c6-4e0a-9b3f-b1b33c5a4bd4",
        body: #{schoolNumber: "1234"},
      },
    },
    #{ title: "Update Schoolnumber" }
  )
  @opExample(
    #{
      parameters: #{
        `school-id`: "43b879c4-14c6-4e0a-9b3f-b1b33c5a4bd4",
        body: #{},
      },
    },
    #{ title: "Set a termination date for a school" }
  )
  @opExample(
    #{
      parameters: #{
        `school-id`: "43b879c4-14c6-4e0a-9b3f-b1b33c5a4bd4",
        body: #{},
      },
    },
    #{ title: "Delete termination date from school" }
  )
  @opExample(
    #{
      parameters: #{
        `school-id`: "43b879c4-14c6-4e0a-9b3f-b1b33c5a4bd4",
        body: #{},
      },
      returnType: #{
        _: 200,
        body: #{
          id: "43b879c4-14c6-4e0a-9b3f-b1b33c5a4bd4",
          displayName: "Realschule Musterstadt",
          schoolNumber: "1234",
        },
      },
    },
    #{ title: "educationSchool" }
  )
  @tag("educationSchool")
  op updateSchool is LibreGraphOps.updateResource<SchoolIdPath, educationSchool, SchoolUpdated>;

  @summary("Delete school")
  @doc("Deletes a school. A school can only be delete if it has the terminationDate property set. And if that termination Date is in the past.")
  @operationId("DeleteSchool")
  @tag("educationSchool")
  op deleteSchool is LibreGraphOps.deleteResourceWithoutEtag<SchoolIdPath>;
}

@route("/v1.0/education/schools/{school-id}/users")
@useAuth(bearerAuth)
namespace SchoolUsers {

  @summary("Get the educationUser resources associated with an educationSchool")
  @operationId("ListSchoolUsers")
  @opExample(
    #{
      parameters: #{`school-id`: "43b879c4-14c6-4e0a-9b3f-b1b33c5a4bd4"},
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "90eedea1-dea1-90ee-a1de-ee90a1deee90",
              onPremisesSamAccountName: "max.mustermann",
              displayName: "Max Mustermann",
              surname: "Mustermann",
              givenName: "Max",
              mail: "max.musterman@example.org",
              primaryRole: "student",
              identities: #[
                #{
                  issuer: "idp.school.com",
                  issuerAssignedId: "max.mustermann",
                },
              ],
            },
          ],
        },
      },
    },
    #{ title: "ListSchoolUsers_default_resp" }
  )
  @tag("educationSchool")
  op listSchoolUsers is LibreGraphOps.getResource<SchoolIdPath, SchoolUsersRetrieved>;
}

@route("/v1.0/education/schools/{school-id}/users/$ref")
@useAuth(bearerAuth)
namespace SchoolUsersRef {

  @summary("Assign a user to a school")
  @operationId("AddUserToSchool")
  @tag("educationSchool")
  op addUserToSchool is LibreGraphOps.addRef<SchoolIdPath, educationUserReference, "educationUser to be added as member">;
}

@route("/v1.0/education/schools/{school-id}/users/{user-id}/$ref")
@useAuth(bearerAuth)
namespace SchoolUserRef {

  @summary("Unassign user from a school")
  @operationId("DeleteUserFromSchool")
  @tag("educationSchool")
  op deleteUserFromSchool is LibreGraphOps.deleteRef<SchoolAndUserIdPath>;
}

@route("/v1.0/education/schools/{school-id}/classes")
@useAuth(bearerAuth)
namespace SchoolClasses {

  @summary("Get the educationClass resources owned by an educationSchool")
  @operationId("ListSchoolClasses")
  @opExample(
    #{
      parameters: #{`school-id`: "43b879c4-14c6-4e0a-9b3f-b1b33c5a4bd4"},
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "86948e45-96a6-43df-b83d-46e92afd30de",
              displayName: "Mathematik",
              classification: "course",
              externalId: "ac528aea-978e-415c-a733-c4ba235d3388",
            },
            #{
              id: "9097631c-24b6-4621-9635-36195a9c8d79",
              displayName: "10b",
              classification: "class",
              externalId: "0123_10b",
            },
          ],
        },
      },
    },
    #{ title: "ListSchoolClasses_default_resp" }
  )
  @tag("educationSchool")
  op listSchoolClasses is LibreGraphOps.getResource<SchoolIdPath, SchoolClassesRetrieved>;
}

@route("/v1.0/education/schools/{school-id}/classes/$ref")
@useAuth(bearerAuth)
namespace SchoolClassesRef {

  @summary("Assign a class to a school")
  @operationId("AddClassToSchool")
  @tag("educationSchool")
  op addClassToSchool is LibreGraphOps.addRef<SchoolIdPath, classReference, "educationClass to be added as member">;
}

@route("/v1.0/education/schools/{school-id}/classes/{class-id}/$ref")
@useAuth(bearerAuth)
namespace SchoolClassRef {

  @summary("Unassign class from a school")
  @operationId("DeleteClassFromSchool")
  @tag("educationSchool")
  op deleteClassFromSchool is LibreGraphOps.deleteRef<SchoolAndClassIdPath>;
}

// =============================================================================
// /v1.0/education/classes
// =============================================================================

@route("/v1.0/education/classes")
@useAuth(bearerAuth)
namespace Classes {

  @summary("list education classes")
  @operationId("ListClasses")
  @opExample(
    #{
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "86948e45-96a6-43df-b83d-46e92afd30de",
              displayName: "Mathematik",
              classification: "course",
              externalId: "ac528aea-978e-415c-a733-c4ba235d3388",
            },
            #{
              id: "9097631c-24b6-4621-9635-36195a9c8d79",
              displayName: "10b",
              classification: "class",
              externalId: "0123_10b",
            },
          ],
        },
      },
    },
    #{ title: "ListClasses_default_resp" }
  )
  @tag("educationClass")
  op listClasses is LibreGraphOps.listCollection<ClassesRetrieved>;

  @summary("Add new education class")
  @operationId("CreateClass")
  @opExample(
    #{
      parameters: #{
        body: #{
          displayName: "Mathematik",
          classification: "course",
          externalId: "ac528aea-978e-415c-a733-c4ba235d3388",
        },
      },
    },
    #{ title: "educationClass_post" }
  )
  @opExample(
    #{
      parameters: #{body: #{displayName: "x", classification: "class"}},
      returnType: #{
        _: 201,
        body: #{
          id: "86948e45-96a6-43df-b83d-46e92afd30de",
          displayName: "Mathematik",
          classification: "course",
          externalId: "ac528aea-978e-415c-a733-c4ba235d3388",
        },
      },
    },
    #{ title: "educationClass" }
  )
  @tag("educationClass")
  op createClass is LibreGraphOps.createResource<educationClass, ClassCreated>;
}

@route("/v1.0/education/classes/{class-id}")
@useAuth(bearerAuth)
namespace Class {

  @summary("Get class by key")
  @operationId("GetClass")
  @opExample(
    #{
      parameters: #{`class-id`: "86948e45-96a6-43df-b83d-46e92afd30de"},
      returnType: #{
        _: 200,
        body: #{
          id: "86948e45-96a6-43df-b83d-46e92afd30de",
          displayName: "Mathematik",
          classification: "course",
          externalId: "ac528aea-978e-415c-a733-c4ba235d3388",
        },
      },
    },
    #{ title: "educationClass" }
  )
  @tag("educationClass")
  op getClass is LibreGraphOps.getResource<ClassIdPath, ClassRetrieved>;

  @summary("Update properties of a education class")
  @operationId("UpdateClass")
  @opExample(
    #{
      parameters: #{
        `class-id`: "86948e45-96a6-43df-b83d-46e92afd30de",
        body: #{displayName: "Musik", classification: "class"},
      },
    },
    #{ title: "update name" }
  )
  @opExample(
    #{
      parameters: #{
        `class-id`: "86948e45-96a6-43df-b83d-46e92afd30de",
        body: #{
          displayName: "10b",
          classification: "class",
          `members@odata.bind`: #[
            "https://localhost:9200/graph/v1.0/education/users/4c510ada-c86b-4815-8820-42cdf82c3d51",
            "https://localhost:9200/graph/v1.0/education/users/c54b0588-7157-4521-bb52-c1c8ca84ea71",
          ],
        },
      },
    },
    #{ title: "add multiple members" }
  )
  @opExample(
    #{
      parameters: #{
        `class-id`: "86948e45-96a6-43df-b83d-46e92afd30de",
        body: #{displayName: "x", classification: "class"},
      },
      returnType: #{
        _: 200,
        body: #{
          id: "86948e45-96a6-43df-b83d-46e92afd30de",
          displayName: "Musik",
          classification: "course",
          externalId: "cb766da3-bab1-478a-9615-f99d4c59c09a",
        },
      },
    },
    #{ title: "UpdateClass_default_resp" }
  )
  @tag("educationClass")
  op updateClass is LibreGraphOps.updateResource<ClassIdPath, educationClass, ClassUpdated | NoContentSuccess>;

  @summary("Delete education class")
  @operationId("DeleteClass")
  @tag("educationClass")
  op deleteClass is LibreGraphOps.deleteResourceWithoutEtag<ClassIdPath>;
}

@route("/v1.0/education/classes/{class-id}/members")
@useAuth(bearerAuth)
namespace ClassMembers {

  @summary("Get the educationClass resources owned by an educationSchool")
  @operationId("ListClassMembers")
  @opExample(
    #{
      parameters: #{`class-id`: "86948e45-96a6-43df-b83d-46e92afd30de"},
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "90eedea1-dea1-90ee-a1de-ee90a1deee90",
              onPremisesSamAccountName: "max.mustermann",
              displayName: "Max Mustermann",
              surname: "Mustermann",
              givenName: "Max",
              mail: "max.musterman@example.org",
              primaryRole: "student",
              identities: #[
                #{
                  issuer: "idp.school.com",
                  issuerAssignedId: "max.mustermann",
                },
              ],
            },
          ],
        },
      },
    },
    #{ title: "ListClassMembers_default_resp" }
  )
  @tag("educationClass")
  op listClassMembers is LibreGraphOps.getResource<ClassIdPath, ClassMembersRetrieved>;
}

@route("/v1.0/education/classes/{class-id}/members/$ref")
@useAuth(bearerAuth)
namespace ClassMembersRef {

  @summary("Assign a user to a class")
  @operationId("AddUserToClass")
  @tag("educationClass")
  op addUserToClass is LibreGraphOps.addRef<ClassIdPath, classMemberReference, "educationUser to be added as member">;
}

@route("/v1.0/education/classes/{class-id}/members/{user-id}/$ref")
@useAuth(bearerAuth)
namespace ClassMemberRef {

  @summary("Unassign user from a class")
  @operationId("DeleteUserFromClass")
  @tag("educationClass")
  op deleteUserFromClass is LibreGraphOps.deleteRef<ClassAndUserIdPath>;
}

@route("/v1.0/education/classes/{class-id}/teachers")
@useAuth(bearerAuth)
namespace ClassTeachers {

  @summary("Get the teachers for a class")
  @operationId("GetTeachers")
  @opExample(
    #{
      parameters: #{`class-id`: "86948e45-96a6-43df-b83d-46e92afd30de"},
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "90eedea1-dea1-90ee-a1de-ee90a1deee90",
              onPremisesSamAccountName: "max.mustermann",
              displayName: "Max Mustermann",
              surname: "Mustermann",
              givenName: "Max",
              mail: "max.musterman@example.org",
              primaryRole: "teacher",
              identities: #[
                #{
                  issuer: "idp.school.com",
                  issuerAssignedId: "max.mustermann",
                },
              ],
            },
          ],
        },
      },
    },
    #{ title: "GetTeachers_default_resp" }
  )
  @tag("educationClass.teachers")
  op getTeachers is LibreGraphOps.getResource<ClassIdPath, ClassTeachersRetrieved>;
}

@route("/v1.0/education/classes/{class-id}/teachers/$ref")
@useAuth(bearerAuth)
namespace ClassTeachersRef {

  @summary("Assign a teacher to a class")
  @operationId("AddTeacherToClass")
  @tag("educationClass.teachers")
  op addTeacherToClass is LibreGraphOps.addRef<ClassIdPath, classTeacherReference, "educationUser to be added as teacher">;
}

@route("/v1.0/education/classes/{class-id}/teachers/{user-id}/$ref")
@useAuth(bearerAuth)
namespace ClassTeacherRef {

  @summary("Unassign user as teacher of a class")
  @operationId("DeleteTeacherFromClass")
  @tag("educationClass.teachers")
  op deleteTeacherFromClass is LibreGraphOps.deleteRef<ClassAndTeacherIdPath>;
}
