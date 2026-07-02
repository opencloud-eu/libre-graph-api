import "@typespec/http";
import "@typespec/openapi";
import "@typespec/json-schema";

import "./common.models.tsp";

using Http;
using OpenAPI;


namespace LibreGraph;

// -----------------------------------------------------------------------------
// Response helpers
// -----------------------------------------------------------------------------

@doc("Retrieved entity")
model OwnUserRetrieved {
  @statusCode _: 200;
  @body body: userResource;
}

@doc("Success")
model OwnUserUpdated {
  @statusCode _: 200;
  @body body: userResource;
}

@doc("Retrieved profile photo")
model PhotoRetrieved {
  @statusCode _: 200;
  @header contentType: "image/jpeg";
  @body body: bytes;
}

// -----------------------------------------------------------------------------
// /v1.0/me — current-user operations
// -----------------------------------------------------------------------------

@route("/v1.0/me")
namespace Me {

  @summary("Update the current user")
  @operationId("UpdateOwnUser")
  @opExample(
    #{
      parameters: #{body: #{preferredLanguage: "en"}},
    },
    #{ title: "change preferred language" }
  )
  @tag("me.user")
  @patch
  op updateOwnUser(
    @doc("New user values")
    @body
    body?: userBase,
  ): OwnUserUpdated | OdataError;

  @summary("Get current user")
  @operationId("GetOwnUser")
  @tag("me.user")
  @extension("x-ms-docs-operation-type", "operation")
  @get
  op getOwnUser(
    @doc("Expand related entities")
    @TypeSpec.JsonSchema.uniqueItems
    @query(#{ explode: false })
    `$expand`?: "memberOf"[],
  ): OwnUserRetrieved | OdataError;
}

// -----------------------------------------------------------------------------
// /v1.0/me/changePassword
// -----------------------------------------------------------------------------

model passwordChange {
  currentPassword: string;
  newPassword: string;
}

@route("/v1.0/me/changePassword")
namespace MeChangePassword {

  @summary("Change your own password")
  @operationId("ChangeOwnPassword")
  @tag("me.changepassword")
  @extension("x-ms-docs-operation-type", "operation")
  @post
  op changeOwnPassword(
    @doc("Password change request")
    @body
    body: passwordChange,
  ): NoContentSuccess | OdataError;
}

// -----------------------------------------------------------------------------
// /v1.0/me/photo/$value
// -----------------------------------------------------------------------------

@route("/v1.0/me/photo/$value")
namespace MePhoto {

  @summary("Get the current user's profile photo")
  @operationId("GetOwnUserPhoto")
  @tag("me.photo")
  @get
  op getOwnUserPhoto(): PhotoRetrieved | OdataError;

  @summary("Update the current user's profile photo")
  @operationId("UpdateOwnUserPhotoPut")
  @tag("me.photo")
  @put
  op updateOwnUserPhotoPut(
    @header contentType: "image/jpeg",

    @doc("New user photo")
    @body
    body?: bytes,
  ): NoContentSuccess | OdataError;

  @summary("Update the current user's profile photo")
  @operationId("UpdateOwnUserPhotoPatch")
  @tag("me.photo")
  @patch
  op updateOwnUserPhotoPatch(
    @header contentType: "image/jpeg",

    @doc("New user photo")
    @body
    body?: bytes,
  ): NoContentSuccess | OdataError;

  @summary("Delete the current user's profile photo")
  @operationId("DeleteOwnUserPhoto")
  @tag("me.photo")
  @delete
  op deleteOwnUserPhoto(): NoContentSuccess | OdataError;
}

// -----------------------------------------------------------------------------
// /v1.0/me/drives
// -----------------------------------------------------------------------------

@route("/v1.0/me/drives")
namespace MeDrives {

  @summary("Get all drives where the current user is a regular member of")
  @operationId("ListMyDrives")
  @tag("me.drives")
  @extension(
    "x-ms-pageable",
    #{ nextLinkName: "@odata.nextLink", operationName: "listMore" }
  )
  @extension("x-ms-docs-operation-type", "operation")
  @get
  op listMyDrives(
    ...OrderBy,
    ...DrivesFilter,
  ): DrivesRetrieved | OdataError;
}

@route("/v1beta1/me/drives")
namespace MeDrivesBeta {

  @summary("Alias for '/v1.0/drives', the difference is that grantedtoV2 is used and roles contain unified roles instead of cs3 roles")
  @operationId("ListMyDrivesBeta")
  @tag("me.drives")
  @extension(
    "x-ms-pageable",
    #{ nextLinkName: "@odata.nextLink", operationName: "listMore" }
  )
  @extension("x-ms-docs-operation-type", "operation")
  @get
  op listMyDrivesBeta(
    ...OrderBy,
    ...DrivesFilter,
    ...DrivesExpand,
    ...DrivesSelect,
  ): DrivesRetrieved | OdataError;
}

// -----------------------------------------------------------------------------
// /v1.0/me/drive — personal drive convenience routes
// -----------------------------------------------------------------------------

@doc("Retrieved personal space")
model PersonalDriveRetrieved {
  @statusCode _: 200;
  @body body: driveResource;
}

@doc("OK")
model SharedItemsRetrieved {
  @statusCode _: 200;
  @body body: sharedDriveItemsResponse;
}

@doc("Created")
model FollowedDriveItemCreated {
  @statusCode _: 201;
  @body body: driveItemModel;
}

@doc("No Content")
model UnfollowedNoContent {
  @statusCode _: 204;
}

alias sharedDriveItemsResponse = Collection<driveItemModel, "CollectionOfDriveItems1">;

@route("/v1.0/me/drive")
namespace MeDrive {

  @summary("Get personal space for user")
  @operationId("GetHome")
  @tag("me.drive")
  @extension("x-ms-docs-operation-type", "operation")
  @get
  op getHome(): PersonalDriveRetrieved | OdataError;
}

@route("/v1.0/me/drive/root")
namespace MeDriveRoot {

  @summary("Get root from personal space")
  @operationId("HomeGetRoot")
  @tag("me.drive.root")
  op homeGetRoot is DriveItemOps.get<{}, DriveItemRetrieved>;
}

@route("/v1.0/me/drive/root/children")
namespace MeDriveRootChildren {

  @summary("Get children from drive")
  @operationId("HomeGetChildren")
  @tag("me.drive.root.children")
  op homeGetChildren is DriveItemOps.listChildren;
}

@route("/v1beta1/me/drive/sharedByMe")
namespace MeDriveSharedByMe {

  @summary("Get a list of driveItem objects shared by the current user.")
  @doc("The `driveItems` returned from the `sharedByMe` method always include the `permissions` relation that indicates they are shared items.")
  @operationId("ListSharedByMe")
  @opExample(
    #{
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "78363031-03ef-4eda-84a2-243a691a13cd",
              eTag: "aQzEyNjQ0QTE0QjBBNzc1MCExMzc5LjQ",
              name: "March Proposal.docx",
              parentReference: #{driveId: "1991210caf", driveType: "personal"},
              permissions: #[
                #{
                  id: "81d5bad3-3eff-410a-a2ea-eda2d14d4474",
                  roles: #["write"],
                  grantedToV2: #{
                    user: #{
                      id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                      displayName: "Albert Einstein",
                    },
                  },
                },
                #{
                  id: "81d5bad3-3eff-410a-a2ea-eda2d14d4474",
                  roles: #["read"],
                  grantedToV2: #{
                    user: #{
                      id: "48016357-346a-443e-bf7a-945c9448a99b",
                      displayName: "Marie Curie",
                    },
                  },
                },
              ],
            },
          ],
        },
      },
    },
    #{ title: "ListSharedByMe_default_resp" }
  )
  @tag("me.drive")
  @extension("x-ms-docs-operation-type", "operation")
  @get
  op listSharedByMe(
    @doc("Expand related entities")
    @TypeSpec.JsonSchema.uniqueItems
    @query(#{ explode: false })
    `$expand`?: "thumbnails"[],
  ): SharedItemsRetrieved | OdataError;
}

@route("/v1beta1/me/drive/sharedWithMe")
namespace MeDriveSharedWithMe {

  @summary("Get a list of driveItem objects shared with the owner of a drive.")
  @doc("The `driveItems` returned from the `sharedWithMe` method always include the `remoteItem` facet that indicates they are items from a different drive.")
  @operationId("ListSharedWithMe")
  @opExample(
    #{
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "78363031-03ef-4eda-84a2-243a691a13cd",
              `@UI.Hidden`: false,
              `@client.synchronize`: true,
              createdBy: #{
                user: #{displayName: "Albert Einstein", id: "44feab10d55e9871"},
              },
              cTag: "adDpDMTI2NDRBMTRCMEE3NzUwITEzNzkuNjM3NjYyNzQ5NjU1MDMwMDAw",
              eTag: "aQzEyNjQ0QTE0QjBBNzc1MCExMzc5LjQ",
              name: "March Proposal.docx",
              parentReference: #{driveId: "1991210caf", driveType: "personal"},
              remoteItem: #{
                id: "02d7a7df-a6f7-44cc-848a-3c98f7dd5046",
                name: "March Proposal.docx",
                size: 19121,
                permissions: #[
                  #{
                    id: "7310e99f-377b-4cba-a1f0-ffa3331fd32c",
                    roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
                    grantedToV2: #{
                      group: #{
                        displayName: "users",
                        id: "509a9dcd-bb37-4f4f-a01a-19dca27d9cfa",
                      },
                    },
                    invitation: #{
                      invitedBy: #{
                        user: #{displayName: "Albert Einstein", id: "44feab10d55e9871"},
                      },
                    },
                  },
                ],
              },
            },
          ],
        },
      },
    },
    #{ title: "ListSharedWithMe_default_resp" }
  )
  @tag("me.drive")
  @extension("x-ms-docs-operation-type", "operation")
  @get
  op listSharedWithMe(
    @doc("Expand related entities")
    @TypeSpec.JsonSchema.uniqueItems
    @query(#{ explode: false })
    `$expand`?: "thumbnails"[],
  ): SharedItemsRetrieved | OdataError;
}

@route("/v1.0/me/drive/items/{item-id}/follow")
namespace MeDriveItemFollow {

  @summary("Follow a DriveItem")
  @doc("Follow a DriveItem.")
  @operationId("FollowDriveItem")
  @tag("me.drive")
  @extension("x-ms-docs-operation-type", "operation")
  @post
  op followDriveItem(...ItemIdPath): FollowedDriveItemCreated | OdataError;
}

@route("/v1.0/me/drive/following/{item-id}")
namespace MeDriveFollowing {

  @summary("Unfollow a DriveItem")
  @doc("Unfollow a DriveItem.")
  @operationId("UnfollowDriveItem")
  @tag("me.drive")
  @extension("x-ms-docs-operation-type", "operation")
  @delete
  op unfollowDriveItem(...ItemIdPath): UnfollowedNoContent | OdataError;
}
