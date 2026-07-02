import "@typespec/http";
import "@typespec/openapi";

import "./common.models.tsp";

using Http;
using OpenAPI;

namespace LibreGraph;

// =============================================================================
// Role definitions
//
// Global permission/role concepts that are not drive-specific. The
// drive-mounted sharing operations consume `unifiedRoleDefinition` (via
// `permissionsWithAllowedValuesResponse` over in drives.models.tsp) but
// the entity itself lives here because it represents the available
// roles in the system, independent of any specific resource it could
// be granted on.
// =============================================================================

@doc("""
  Represents a collection of allowed resource actions and the conditions that must be met for the action to be allowed.
  Resource actions are tasks that can be performed on a resource. For example, an application resource may support
  create, update, delete, and reset password actions.
  """)
model unifiedRolePermission {
  @doc("""
    Set of tasks that can be performed on a resource. Required.

    The following is the schema for resource actions:

    ```
       {Namespace}/{Entity}/{PropertySet}/{Action}
    ```

     For example: `libre.graph/applications/credentials/update`
    """)
  allowedResourceActions?: string[];

  @doc("""
    A conditional expression evaluating membership in a role.

    For now we only support a limited set of operators:
      * `exists` - true if the right side property exists. Example: `exists @Resource.File`. We use this to assign different roles to files and folders.
    """)
  condition?: string;
}

@doc("""
  A role definition is a collection of permissions in libre graph listing the operations that can be performed
  and the resources against which they can performed.
  """)
model unifiedRoleDefinition {
  @doc("The description for the unifiedRoleDefinition.")
  description?: string;

  @doc("The display name for the unifiedRoleDefinition. Required. Supports $filter (`eq`, `in`).")
  displayName?: string;

  @doc("The unique identifier for the role definition. Key, not nullable, Read-only. Inherited from entity. Supports $filter (`eq`, `in`).")
  id?: string;

  @doc("List of permissions included in the role.")
  rolePermissions?: unifiedRolePermission[];

  @doc("""
    When presenting a list of roles the weight can be used to order them in a meaningful way.
    Lower weight gets higher precedence. So content with lower weight will come first. If set,
    weights should be non-zero, as 0 is interpreted as an unset weight.
    """)
  `@libre.graph.weight`?: int32;
}

@doc("A list of permission roles that can be used when sharing with users or groups.")
model RoleDefinitionsListed {
  @statusCode _: 200;
  @body body: unifiedRoleDefinition[];
}

@doc("OK")
model RoleDefinitionRetrieved {
  @statusCode _: 200;
  @body body: unifiedRoleDefinition;
}
