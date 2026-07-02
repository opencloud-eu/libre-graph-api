import "@typespec/http";
import "@typespec/openapi";

import "./common.models.tsp";
import "./permissions.models.tsp";

using Http;
using OpenAPI;

namespace LibreGraph;

// =============================================================================
// /v1beta1/roleManagement/permissions/roleDefinitions
//
// Global "what roles can be granted" endpoints. Not anchored to any
// specific drive or driveItem — they describe the set of permission
// roles available in the system, which the drive-mounted sharing
// endpoints (createLink, invite, …) reference when assigning roles.
// =============================================================================

@route("/v1beta1/roleManagement/permissions/roleDefinitions")
namespace PermissionRoleDefinitions {

  @summary("List roleDefinitions")
  @doc("Get a list of `unifiedRoleDefinition` objects for the permissions provider. This list determines the roles that can be selected when creating sharing invites.")
  @operationId("ListPermissionRoleDefinitions")
  @opExample(
    #{
      returnType: #{
        _: 200,
        body: #[
          #{
            id: "b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5",
            description: "Allows reading the shared file or folder",
            displayName: "Viewer",
            rolePermissions: #[
              #{
                allowedResourceActions: #[
                  "libre.graph/driveItem/basic/read",
                  "libre.graph/driveItem/permissions/read",
                  "libre.graph/driveItem/upload/create",
                ],
                condition: "exists @Resource.File",
              },
            ],
            `@libre.graph.weight`: 1,
          },
          #{
            id: "fb6c3e19-e378-47e5-b277-9732f9de6e21",
            description: "Allows reading and writing the shared file or folder",
            displayName: "Editor",
            rolePermissions: #[
              #{
                allowedResourceActions: #["libre.graph/driveItem/standard/allTasks"],
                condition: "exists @Resource.File",
              },
            ],
            `@libre.graph.weight`: 2,
          },
          #{
            id: "312c0871-5ef7-4b3a-85b6-0e4074c64049",
            description: "Allows managing a space",
            displayName: "Manager",
            rolePermissions: #[
              #{
                allowedResourceActions: #["libre.graph/drive/standard/allTasks"],
                condition: "exists @Resource.File",
              },
            ],
            `@libre.graph.weight`: 3,
          },
          #{
            id: "4916f47e-66d5-49bb-9ac9-748ad00334b",
            description: "Allows creating new files",
            displayName: "File Drop",
            rolePermissions: #[
              #{
                allowedResourceActions: #["libre.graph/driveItem/upload/create"],
                condition: "exists @Resource.File",
              },
            ],
            `@libre.graph.weight`: 4,
          },
        ],
      },
    },
    #{ title: "ListPermissionRoleDefinitions_default_resp" }
  )
  @tag("roleManagement")
  @get
  op listPermissionRoleDefinitions(): RoleDefinitionsListed | OdataError;
}

@route("/v1beta1/roleManagement/permissions/roleDefinitions/{role-id}")
namespace PermissionRoleDefinition {

  @summary("Get unifiedRoleDefinition")
  @doc("Read the properties and relationships of a `unifiedRoleDefinition` object.")
  @operationId("GetPermissionRoleDefinition")
  @opExample(
    #{
      parameters: #{`role-id`: "b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"},
      returnType: #{
        _: 200,
        body: #{
          id: "b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5",
          description: "Allows reading the shared file or folder",
          displayName: "Viewer",
          rolePermissions: #[
            #{
              allowedResourceActions: #["libre.graph/driveItem/basic/read"],
              condition: "exists @Resource.File",
            },
          ],
          `@libre.graph.weight`: 1,
        },
      },
    },
    #{ title: "Viewer" }
  )
  @opExample(
    #{
      parameters: #{`role-id`: "fb6c3e19-e378-47e5-b277-9732f9de6e21"},
      returnType: #{
        _: 200,
        body: #{
          id: "fb6c3e19-e378-47e5-b277-9732f9de6e21",
          description: "Allows reading and writing the shared file or folder",
          displayName: "Editor",
          rolePermissions: #[
            #{
              allowedResourceActions: #["libre.graph/driveItem/standard/allTasks"],
              condition: "exists @Resource.File",
            },
          ],
          `@libre.graph.weight`: 2,
        },
      },
    },
    #{ title: "Editor" }
  )
  @opExample(
    #{
      parameters: #{`role-id`: "312c0871-5ef7-4b3a-85b6-0e4074c64049"},
      returnType: #{
        _: 200,
        body: #{
          id: "312c0871-5ef7-4b3a-85b6-0e4074c64049",
          description: "Allows managing a space",
          displayName: "Manager",
          rolePermissions: #[
            #{
              allowedResourceActions: #["libre.graph/drive/standard/allTasks"],
              condition: "exists @Resource.File",
            },
          ],
          `@libre.graph.weight`: 3,
        },
      },
    },
    #{ title: "Manager" }
  )
  @opExample(
    #{
      parameters: #{`role-id`: "4916f47e-66d5-49bb-9ac9-748ad00334b"},
      returnType: #{
        _: 200,
        body: #{
          id: "4916f47e-66d5-49bb-9ac9-748ad00334b",
          description: "Allows creating new files",
          displayName: "File Drop",
          rolePermissions: #[
            #{
              allowedResourceActions: #["libre.graph/driveItem/upload/create"],
              condition: "exists @Resource.File",
            },
          ],
          `@libre.graph.weight`: 4,
        },
      },
    },
    #{ title: "File Drop" }
  )
  @tag("roleManagement")
  @get
  op getPermissionRoleDefinition(
    @path
    @extension("x-ms-docs-key-type", "roleDefinition")
    @doc("key: id of roleDefinition")
    `role-id`: string,
  ): RoleDefinitionRetrieved | OdataError;
}
