import "@typespec/http";
import "@typespec/openapi";

import "./common.models.tsp";
import "./drives.models.tsp";

using Http;
using OpenAPI;

namespace LibreGraph;

// =============================================================================
// Permissions operation templates
//
// libre-graph-api's only permissionable resources today are drives and
// driveItems, so the body / query / response shapes below reference the
// drive-side sharing models (`driveItemCreateLink`, `driveItemInvite`,
// `permission`, `PermIdPath`, `PermissionsFilter`, …) that live in
// drives.models.tsp. The interface itself sits here because it is the
// permission-management contract — discoverable under the permission
// domain by name. If permissions are ever extended to other resource
// types (sites, groups, …), the new body shapes would live with that
// resource and this template's `TPath`/body parameters would pick them
// up without moving the file.
//
// The seven operations are mounted at two parent paths today:
//
//   /v1beta1/drives/{drive-id}/root/...           — the space root
//   /v1beta1/drives/{drive-id}/items/{item-id}/...— an item inside a drive
//
// The wire shape (HTTP verb, body, query parameters, response union) is
// identical regardless of where they are mounted; only the parent path
// changes. The `TPath` template argument lets each call site decide
// whether the parent is `DriveIdPath` or `DriveAndItemIdPath` (or a new
// shape if libre-graph-api ever ports the MS Graph
// `groups`/`users`/`sites` drive mounts) while the body shape stays
// guaranteed in sync.
// =============================================================================

interface PermissionsOps {
  // POST a createLink action against the parent identified by TPath.
  @post
  @extension("x-ms-docs-operation-type", "operation")
  createLink<TPath>(
    ...TPath,
    @doc("In the request body, provide a JSON object with the following parameters.")
    @body
    body?: driveItemCreateLink,
  ): CreateLinkResponse | PartialSuccess | OdataError;

  // POST a sharing invitation against the parent identified by TPath.
  @post
  @extension("x-ms-docs-operation-type", "operation")
  invite<TPath>(
    ...TPath,
    @doc("In the request body, provide a JSON object with the following parameters. To create a custom role submit a list of actions instead of roles.")
    @body
    body?: driveItemInvite,
  ): InviteResponse | PartialSuccess | InviteBadRequest | OdataError;

  // GET the effective sharing permissions on the parent identified by TPath.
  @get
  @extension("x-ms-docs-operation-type", "operation")
  listPermissions<TPath>(
    ...TPath,
    ...PermissionsFilter,
    ...PermissionsSelect,
    ...CountParam,
    ...TopParam,
  ): PermissionsCollectionRetrieved | OdataError;

  // GET a single sharing permission. TPath is the parent path; the
  // permission id is appended by the template.
  @get
  @extension("x-ms-docs-operation-type", "operation")
  getPermission<TPath>(
    ...TPath,
    ...PermIdPath,
  ): PermissionRetrieved | OdataError;

  // PATCH a sharing permission.
  @patch
  @extension("x-ms-docs-operation-type", "operation")
  updatePermission<TPath>(
    ...TPath,
    ...PermIdPath,
    @doc("New property values")
    @body
    body: permission,
  ): PermissionUpdated | OdataError;

  // DELETE a sharing permission.
  @delete
  @extension("x-ms-docs-operation-type", "operation")
  deletePermission<TPath>(
    ...TPath,
    ...PermIdPath,
  ): NoContentSuccess | OdataError;

  // POST a new password to a sharing-link permission.
  @post
  @extension("x-ms-docs-operation-type", "operation")
  setPermissionPassword<TPath>(
    ...TPath,
    ...PermIdPath,
    @doc("New password value")
    @body
    body: sharingLinkPassword,
  ): PermissionUpdated | OdataError;
}
