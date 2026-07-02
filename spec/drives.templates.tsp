import "@typespec/http";
import "@typespec/openapi";

import "./drives.models.tsp";

using Http;
using OpenAPI;

namespace LibreGraph;

// =============================================================================
// DriveItem operation templates
//
// A driveItem can be reached from several different routes — the root of
// the current user's drive (`/v1.0/me/drive/root`), the root of an
// arbitrary drive (`/v1.0/drives/{drive-id}/root`) and an item inside any
// drive (`/v1beta1/drives/{drive-id}/items/{item-id}`). The shape of the
// operations themselves (`GET`, `PATCH`, `DELETE`, `GET /content`,
// `GET /children`, `POST /children`) is identical regardless of where
// they are mounted. The templates below capture that shared shape so a
// new mount point is one `op … is …` line, not a copy of the whole
// operation.
// =============================================================================

interface DriveItemOps {
  // GET the driveItem itself.
  @get
  @extension("x-ms-docs-operation-type", "operation")
  get<TPath = {}, TResponse = DriveItemRetrieved, TQuery = {}>(
    ...TPath,
    ...TQuery,
  ): TResponse | OdataError;

  // PATCH the driveItem.
  @patch
  @extension("x-ms-docs-operation-type", "operation")
  update<TPath, TBodyDoc extends valueof string = "DriveItem properties to update">(
    ...TPath,
    @doc(TBodyDoc)
    @body
    body: driveItemModel,
  ): DriveItemUpdated | OdataError;

  // DELETE the driveItem.
  @delete
  @extension("x-ms-docs-operation-type", "operation")
  remove<TPath>(...TPath): NoContentSuccess | OdataError;

  // GET the paginated children of the driveItem (or root).
  @get
  @extension("x-ms-docs-operation-type", "operation")
  listChildren<TPath = {}>(
    ...TPath,
  ): DriveItemListRetrieved | OdataError;

  // POST a new child driveItem under the parent identified by TPath.
  @post
  @extension("x-ms-docs-operation-type", "operation")
  createChild<
    TPath,
    TBodyDoc extends valueof string = "In the request body, provide a JSON object with the following parameters."
  >(
    ...TPath,
    @doc(TBodyDoc)
    @body
    body?: driveItemModel,
  ): CreateChildItemResponse | OdataError;

  // GET the binary content of the driveItem (302 redirect to a pre-signed
  // download URL).
  @get
  @extension("x-ms-docs-operation-type", "operation")
  getContent<TPath>(
    ...TPath,
  ): DriveItemContentRedirect | DriveItemContentNotFound | OdataError;
}
