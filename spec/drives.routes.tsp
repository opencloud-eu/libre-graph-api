import "@typespec/http";
import "@typespec/openapi";

import "./drives.models.tsp";
import "./drives.templates.tsp";
import "./permissions.templates.tsp";

using Http;
using OpenAPI;

namespace LibreGraph;

// =============================================================================
// /v1.0/drives — drive collection + drive entity
// =============================================================================

@route("/v1.0/drives")
namespace DrivesAll {

  @summary("Get all available drives")
  @operationId("ListAllDrives")
  @tag("drives.GetDrives")
  @extension("x-ms-docs-operation-type", "operation")
  @get
  op listAllDrives(
    ...OrderBy,
    ...DrivesFilter,
  ): DrivesListResponse | OdataError;

  @summary("Create a new drive of a specific type")
  @operationId("CreateDrive")
  @opExample(
    #{
      parameters: #{
        body: #{
          name: "Mars",
          quota: #{total: 1000000000},
          description: "Team space mars project",
        },
      },
    },
    #{ title: "multiple values" }
  )
  @opExample(
    #{
      parameters: #{body: #{name: "Venus"}},
    },
    #{ title: "minimal" }
  )
  @tag("drives")
  @extension("x-ms-docs-operation-type", "operation")
  @post
  op createDrive(
    @doc("New space property values")
    @body
    body: driveResource,
  ): DriveCreated | OdataError;
}

@route("/v1.0/drives/{drive-id}")
namespace Drive {

  @summary("Get drive by id")
  @operationId("GetDrive")
  @tag("drives")
  @extension("x-ms-docs-operation-type", "operation")
  @get
  op getDrive(
    ...DriveIdPath,
    ...DrivesSelect,
  ): DriveRetrieved | OdataError;

  @summary("Update the drive")
  @operationId("UpdateDrive")
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        body: #{quota: #{total: 1000000000}},
      },
    },
    #{ title: "change quota" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        body: #{name: "Physics"},
      },
    },
    #{ title: "change name" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        body: #{description: "Marketing team collaboration area"},
      },
    },
    #{ title: "change description" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        body: #{
          special: #[
            #{
              id: "408f26e3-d6d8-4aa4-bd5c-3fd6f5032b51$aba2bafc-e1a0-421e-a37a-9acf5f655f83!14fd3432-e8d9-42a7-9446-2e3fd621afca",
              specialFolder: #{name: "image"},
            },
          ],
        },
      },
    },
    #{ title: "change drive image" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        body: #{
          special: #[
            #{
              id: "408f26e3-d6d8-4aa4-bd5c-3fd6f5032b51$aba2bafc-e1a0-421e-a37a-9acf5f655f83!14fd3432-e8d9-42a7-9446-2e3fd621afca",
              specialFolder: #{name: "readme"},
            },
          ],
        },
      },
    },
    #{ title: "change drive readme" }
  )
  @tag("drives")
  @extension("x-ms-docs-operation-type", "operation")
  @patch
  op updateDrive(
    ...DriveIdPath,
    @doc("New space values")
    @body
    body: driveBase,
  ): DriveUpdated | OdataError;

  @summary("Delete a specific space")
  @operationId("DeleteDrive")
  @tag("drives")
  @extension("x-ms-docs-operation-type", "operation")
  @delete
  op deleteDrive(
    ...DriveIdPath,
    @header("If-Match")
    @doc("ETag")
    ifMatch?: string,
  ): NoContentSuccess | OdataError;
}

// =============================================================================
// /v1beta1/drives — beta alias with extra query parameters
// =============================================================================

@route("/v1beta1/drives")
namespace DrivesBeta {

  @summary("Alias for '/v1.0/drives', the difference is that grantedtoV2 is used and roles contain unified roles instead of cs3 roles")
  @operationId("ListAllDrivesBeta")
  @tag("drives.GetDrives")
  @extension("x-ms-docs-operation-type", "operation")
  @get
  op listAllDrivesBeta(
    ...OrderBy,
    ...DrivesFilter,
    ...DrivesExpand,
    ...DrivesSelect,
  ): DrivesListResponse | OdataError;
}

// =============================================================================
// /v1.0/drives/{drive-id}/root
// =============================================================================

@route("/v1.0/drives/{drive-id}/root")
namespace DriveRoot {

  @summary("Get root from arbitrary space")
  @operationId("GetRoot")
  @tag("drives.root")
  op getRoot is DriveItemOps.get<DriveIdPath>;
}

@route("/v1.0/drives/{drive-id}/root/children")
namespace DriveRootChildrenList {

  @summary("List children of the root of an arbitrary space")
  @doc("""
    List the children directly under the root of the drive identified by `drive-id`. The drive must exist and the caller must have permission to enumerate its root.

    Mirrors `GET /v1.0/me/drive/root/children` (personal space) and complements `GET /v1.0/drives/{drive-id}/items/{item-id}/children` (children of a non-root item).

    Modeled on the MS Graph list driveItem children endpoint
    (https://learn.microsoft.com/en-us/graph/api/driveitem-list-children).
    """)
  @operationId("GetDriveRootChildren")
  @tag("drives.root")
  op getDriveRootChildren is DriveItemOps.listChildren<DriveIdPath>;
}

// =============================================================================
// /v1beta1/drives/{drive-id}/items/{item-id} — driveItem operations
// =============================================================================

@route("/v1beta1/drives/{drive-id}/items/{item-id}")
namespace DriveItem {

  @summary("Get a DriveItem.")
  @doc("Get a DriveItem by using its ID.")
  @operationId("GetDriveItem")
  @tag("driveItem")
  op getDriveItem is DriveItemOps.get<DriveAndItemIdPath, DriveItemRetrievedSelected, DriveItemSelect>;

  @summary("Update a DriveItem.")
  @doc("""
    Update a DriveItem.

    The request body must include a JSON object with the properties to update.
    Only the properties that are provided will be updated.

    Currently it supports updating the following properties:

    * `@UI.Hidden` - Hides the item from the UI.
    """)
  @operationId("UpdateDriveItem")
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        body: #{`@UI.Hidden`: true},
      },
    },
    #{ title: "change visibility" }
  )
  @tag("driveItem")
  op updateDriveItem is DriveItemOps.update<DriveAndItemIdPath>;

  @summary("Delete a DriveItem.")
  @doc("""
    Delete a DriveItem by using its ID.

    Deleting items using this method moves the items to the recycle bin instead of permanently deleting the item.

    Mounted shares in the share jail are unmounted. The `@client.synchronize` property of the `driveItem` in the [sharedWithMe](#/me.drive/ListSharedWithMe) endpoint will change to false.
    """)
  @operationId("DeleteDriveItem")
  @tag("driveItem")
  op deleteDriveItem is DriveItemOps.remove<DriveAndItemIdPath>;
}

// =============================================================================
// /v1.0/drives/{drive-id}/items/{item-id}/children — list children of an item
// =============================================================================

@route("/v1.0/drives/{drive-id}/items/{item-id}/children")
namespace DriveItemChildren {

  @summary("List children of a DriveItem")
  @doc("""
    List the children of the item identified by `item-id` in the drive identified by `drive-id`. The item must exist and be a folder.

    Modeled on the MS Graph list driveItem children endpoint
    (https://learn.microsoft.com/en-us/graph/api/driveitem-list-children).

    This endpoint also accepts the MS Graph colon-syntax URL forms:

        GET /v1.0/drives/{drive-id}/root:/{path}:/children
        GET /v1.0/drives/{drive-id}/items/{item-id}:/{path}:/children

    OpenAPI cannot express the colon-delimited path segment, so these URL forms are not represented as separate operations in this specification. The server still accepts them, resolves `:/{path}:` as the parent item, and lists its children.
    """)
  @operationId("GetDriveItemChildren")
  @tag("driveItem")
  op getDriveItemChildren is DriveItemOps.listChildren<DriveAndItemIdPath>;
}

// =============================================================================
// /v1beta1/drives/{drive-id}/items/{item-id}/content — content download
// =============================================================================

@route("/v1beta1/drives/{drive-id}/items/{item-id}/content")
namespace DriveItemContent {

  @summary("Download the content of a DriveItem")
  @doc("""
    Download the contents of the primary stream (file) of a driveItem. Only
    driveItem objects with a `file` facet can be downloaded.

    The response is a `302 Found` redirecting to a pre-authenticated download
    URL for the file. This is the same URL that is returned via the
    `@microsoft.graph.downloadUrl` instance annotation on the driveItem when
    requested via `$select`. Choose between the two based on whether you
    want to call the redirecting `/content` endpoint directly (for example,
    with a client that follows redirects automatically) or you want to
    inspect / schedule / prefetch the URL yourself via the annotation.

    The pre-authenticated URL is short-lived and does not require an
    `Authorization` header.

    To download a partial range of bytes, apply the `Range` header to the
    redirect target (the pre-authenticated URL), not to the `/content`
    request.
    """)
  @operationId("GetDriveItemContent")
  @tag("driveItem")
  op getDriveItemContent is DriveItemOps.getContent<DriveAndItemIdPath>;
}

// =============================================================================
// Space root sharing — links / invites / permissions
//
// These all live under `/v1beta1/drives/{drive-id}/root/...` and share
// their wire shape (body, query, response) with the per-item variants
// below via the `PermissionsOps` interface declared in permissions.templates.tsp.
// =============================================================================

@route("/v1beta1/drives/{drive-id}/root/children")
namespace DriveRootChildren {

  @summary("Create a drive item")
  @doc("You can use the root children endpoint to mount a remoteItem in the share jail. The `@client.synchronize` property of the `driveItem` in the [sharedWithMe](#/me.drive/ListSharedWithMe) endpoint will change to true.")
  @operationId("CreateDriveItem")
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        body: #{
          name: "Einsteins project share",
          remoteItem: #{id: "a-storage-provider-id$a-space-id!a-node-id"},
        },
      },
    },
    #{ title: "mount a shared remoteId" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
      },
      returnType: #{
        _: 200,
        body: #{
          name: "Einsteins project share",
          id: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!share-id",
          remoteItem: #{
            id: "a-storage-provider-id$a-space-id!a-node-id",
            name: "Project",
          },
          parentReference: #{
            driveId: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
            id: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!a0ca6a90-a365-4782-871e-d44447bbc668",
          },
        },
      },
    },
    #{ title: "CreateDriveItem_default_resp" }
  )
  @tag("drives.root")
  op createDriveItem is DriveItemOps.createChild<
    DriveIdPath,
    "In the request body, provide a JSON object with the following parameters. For mounting a share the necessary remoteItem id and permission id can be taken from the [sharedWithMe](#/me.drive/ListSharedWithMe) endpoint."
  >;
}

@route("/v1beta1/drives/{drive-id}/root/createLink")
namespace DriveRootCreateLink {

  @summary("Create a sharing link for the root item of a Drive")
  @doc("""
    You can use the createLink action to share a driveItem via a sharing link.

    The response will be a permission object with the link facet containing the created link details.

    ## Link types

    For now, The following values are allowed for the type parameter.

    | Value          | Display name      | Description                                                     |
    | -------------- | ----------------- | --------------------------------------------------------------- |
    | view           | View              | Creates a read-only link to the driveItem.                      |
    | upload         | Upload            | Creates a read-write link to the folder driveItem.              |
    | edit           | Edit              | Creates a read-write link to the driveItem.                     |
    | createOnly     | File Drop         | Creates an upload-only link to the folder driveItem.            |
    | blocksDownload | Secure View       | Creates a read-only link that blocks download to the driveItem. |
    """)
  @operationId("CreateLinkSpaceRoot")
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        body: #{type: "view"},
      },
    },
    #{ title: "create viewer link" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        body: #{type: "edit", displayName: "Homework"},
      },
    },
    #{ title: "create editor link with custom display name" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        body: #{type: "edit"},
      },
    },
    #{ title: "create editor link with expiry" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
      },
      returnType: #{
        _: 200,
        body: #{
          id: "7181275c-557e-4adf-8e44-abdcf5389b6a",
          link: #{
            type: "view",
            webUrl: "https://cloud.example.org/s/YlaySZdHCRHUDeE",
          },
        },
      },
    },
    #{ title: "create viewer link" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
      },
      returnType: #{
        _: 200,
        body: #{
          id: "7181275c-557e-4adf-8e44-abdcf5389b6a",
          link: #{
            type: "edit",
            `@libre.graph.displayName`: "Homework",
            webUrl: "https://cloud.example.org/s/fdleMyGeerkIZTJ",
          },
        },
      },
    },
    #{ title: "create editor link with custom display name" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
      },
      returnType: #{
        _: 200,
        body: #{
          id: "a373c812-d786-42ae-a65f-ed87ee4abd49",
          link: #{
            type: "edit",
            webUrl: "https://cloud.example.org/s/MlnTDkhcBlihNzO",
          },
        },
      },
    },
    #{ title: "create editor link with expiry" }
  )
  @tag("drives.root")
  op createLinkSpaceRoot is PermissionsOps.createLink<DriveIdPath>;
}

@route("/v1beta1/drives/{drive-id}/root/invite")
namespace DriveRootInvite {

  @summary("Send a sharing invitation")
  @doc("""
    Sends a sharing invitation for the root of a `drive`. A sharing invitation provides permissions to the
    recipients and optionally sends them an email with a sharing link.

    The response will be a permission object with the grantedToV2 property containing the created grant details.

    ## Roles property values
    For now, roles are only identified by a uuid. There are no hardcoded aliases like `read` or `write` because role actions can be completely customized.
    """)
  @operationId("InviteSpaceRoot")
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        body: #{
          recipients: #[
            #{
              `@libre.graph.recipient.type`: "user",
              objectId: "4c510ada-c86b-4815-8820-42cdf82c3d51",
            },
          ],
          roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
        },
      },
    },
    #{ title: "send viewer invite" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        body: #{
          recipients: #[
            #{
              `@libre.graph.recipient.type`: "user",
              objectId: "4c510ada-c86b-4815-8820-42cdf82c3d51",
            },
            #{
              `@libre.graph.recipient.type`: "user",
              objectId: "f7fbf8c8-139b-4376-b307-cf0a8c2d0d9c",
            },
          ],
          roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
        },
      },
    },
    #{ title: "send viewer invite to multiple recipients" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        body: #{
          recipients: #[
            #{
              `@libre.graph.recipient.type`: "user",
              objectId: "4c510ada-c86b-4815-8820-42cdf82c3d51",
            },
          ],
          roles: #["fb6c3e19-e378-47e5-b277-9732f9de6e21"],
        },
      },
    },
    #{ title: "send editor invite with expiry" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        body: #{
          recipients: #[
            #{
              `@libre.graph.recipient.type`: "group",
              objectId: "167cbee2-0518-455a-bfb2-031fe0621e5d",
            },
          ],
          roles: #["312c0871-5ef7-4b3a-85b6-0e4074c64049"],
        },
      },
    },
    #{ title: "send manager invite to group", description: "Sharing with a groups requires setting the @libre.graph.recipient.type annotation." }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        body: #{
          recipients: #[#{objectId: "4c510ada-c86b-4815-8820-42cdf82c3d51"}],
          `@libre.graph.permissions.actions`: #["libre.graph/driveItem/basic/read", "libre.graph/driveItem/path/update"],
        },
      },
    },
    #{ title: "send invite to user granting custom actions", description: "A Custom role is just a collection of actions, in this case allowing the user to stat and move driveItems" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
      },
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "34646ab6-be32-43c9-89e6-987e0c237e9b",
              roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
              grantedToV2: #{
                user: #{
                  id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                  displayName: "Albert Einstein",
                },
              },
            },
          ],
        },
      },
    },
    #{ title: "send viewer invite" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
      },
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "81d5bad3-3eff-410a-a2ea-eda2d14d4474",
              roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
              grantedToV2: #{
                user: #{
                  id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                  displayName: "Albert Einstein",
                },
              },
            },
            #{
              id: "b470677e-a7f5-4304-8ef5-f5056a21fff1",
              roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
              grantedToV2: #{
                user: #{
                  id: "f7fbf8c8-139b-4376-b307-cf0a8c2d0d9c",
                  displayName: "Marie Skłodowska Curie",
                },
              },
            },
          ],
        },
      },
    },
    #{ title: "send viewer invite to multiple recipients", description: "multiple permissions are returned as each has received a dedicated sharing id" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
      },
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "453b02be-4ec2-4e7d-b576-09fc153de812",
              roles: #["fb6c3e19-e378-47e5-b277-9732f9de6e21"],
              grantedToV2: #{
                user: #{
                  id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                  displayName: "Albert Einstein",
                },
              },
            },
          ],
        },
      },
    },
    #{ title: "send editor invite with expiry" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
      },
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "86765c0d-3905-444a-9b07-76201f8cf7df",
              roles: #["312c0871-5ef7-4b3a-85b6-0e4074c64049"],
              grantedToV2: #{
                group: #{
                  id: "167cbee2-0518-455a-bfb2-031fe0621e5d",
                  displayName: "Philosophy Haters",
                },
              },
            },
          ],
        },
      },
    },
    #{ title: "send manager invite to group" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
      },
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "c42b5cbd-2d65-42cf-b0b6-fb6d2b762256",
              grantedToV2: #{
                user: #{
                  id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                  displayName: "Albert Einstein",
                },
              },
              `@libre.graph.permissions.actions`: #["libre.graph/driveItem/basic/read", "libre.graph/driveItem/path/update"],
            },
          ],
        },
      },
    },
    #{ title: "send invite to user granting custom actions" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
      },
      returnType: #{
        _: 400,
        body: #{
          error: #{
            code: "invalidRequest",
            message: "Some users in the request cannot be invited securely.",
          },
        },
      },
    },
    #{ title: "secureSharingInvalidRequest", description: "If the recipient was given via email, but does not belong to a known user account." }
  )
  @tag("drives.root")
  op inviteSpaceRoot is PermissionsOps.invite<DriveIdPath>;
}

@route("/v1beta1/drives/{drive-id}/root/permissions")
namespace DriveRootPermissions {

  @summary("List the effective permissions on the root item of a drive.")
  @doc("""
    The permissions collection includes potentially sensitive information and may not be available for every caller.

    * For the owner of the item, all sharing permissions will be returned. This includes co-owners.
    * For a non-owner caller, only the sharing permissions that apply to the caller are returned.
    * Sharing permission properties that contain secrets (e.g. `webUrl`) are only returned for callers that are able to create the sharing permission.

    All permission objects have an `id`. A permission representing
    * a link has the `link` facet filled with details.
    * a share has the `roles` property set and the `grantedToV2` property filled with the grant recipient details.
    """)
  @operationId("ListPermissionsSpaceRoot")
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
      },
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "67445fde-a647-4dd4-b015-fc5dafd2821d",
              link: #{
                type: "view",
                webUrl: "https://cloud.example.org/s/fhGBMIkKFEHWysj",
              },
            },
            #{
              id: "34646ab6-be32-43c9-89e6-987e0c237e9b",
              roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
              grantedToV2: #{
                user: #{
                  id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                  displayName: "Albert Einstein",
                },
              },
            },
            #{
              id: "81d5bad3-3eff-410a-a2ea-eda2d14d4474",
              roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
              grantedToV2: #{
                user: #{
                  id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                  displayName: "Albert Einstein",
                },
              },
            },
            #{
              id: "b470677e-a7f5-4304-8ef5-f5056a21fff1",
              roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
              grantedToV2: #{
                user: #{
                  id: "f7fbf8c8-139b-4376-b307-cf0a8c2d0d9c",
                  displayName: "Marie Skłodowska Curie",
                },
              },
            },
            #{
              id: "453b02be-4ec2-4e7d-b576-09fc153de812",
              roles: #["fb6c3e19-e378-47e5-b277-9732f9de6e21"],
              grantedToV2: #{
                user: #{
                  id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                  displayName: "Albert Einstein",
                },
              },
            },
            #{
              id: "86765c0d-3905-444a-9b07-76201f8cf7df",
              roles: #["312c0871-5ef7-4b3a-85b6-0e4074c64049"],
              grantedToV2: #{
                group: #{
                  id: "167cbee2-0518-455a-bfb2-031fe0621e5d",
                  displayName: "Philosophy Haters",
                },
              },
            },
            #{
              id: "c42b5cbd-2d65-42cf-b0b6-fb6d2b762256",
              grantedToV2: #{
                user: #{
                  id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                  displayName: "Albert Einstein",
                },
              },
              `@libre.graph.permissions.actions`: #["libre.graph/driveItem/basic/read", "libre.graph/driveItem/path/update"],
            },
          ],
        },
      },
    },
    #{ title: "ListPermissionsSpaceRoot_default_resp" }
  )
  @tag("drives.root")
  op listPermissionsSpaceRoot is PermissionsOps.listPermissions<DriveIdPath>;
}

@route("/v1beta1/drives/{drive-id}/root/permissions/{perm-id}")
namespace DriveRootPermission {

  @summary("Get a single sharing permission for the root item of a drive")
  @doc("Return the effective sharing permission for a particular permission resource.")
  @operationId("GetPermissionSpaceRoot")
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
      },
      returnType: #{
        _: 200,
        body: #{
          id: "81d5bad3-3eff-410a-a2ea-eda2d14d4474",
          roles: #["write"],
          grantedToV2: #{
            user: #{
              id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
              displayName: "Albert Einstein",
            },
          },
        },
      },
    },
    #{ title: "edit permission" }
  )
  @tag("drives.root")
  op getPermissionSpaceRoot is PermissionsOps.getPermission<DriveIdPath>;

  @summary("Update sharing permission")
  @doc("""
    Update the properties of a sharing permission by patching the permission resource.

    Only the `roles`, `expirationDateTime` and `password` properties can be modified this way.
    """)
  @operationId("UpdatePermissionSpaceRoot")
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
        body: #{link: #{type: "edit"}},
      },
    },
    #{ title: "update link", description: "Updating a public link is done by setting the `type` property of the permission link." }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
        body: #{roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"]},
      },
    },
    #{ title: "update invite", description: "Updating an invite is done by setting the `roles` property of the permission." }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
        body: #{id: "00000000-0000-0000-0000-000000000000"},
      },
      returnType: #{
        _: 200,
        body: #{
          id: "a373c812-d786-42ae-a65f-ed87ee4abd49",
          link: #{
            type: "edit",
            webUrl: "https://cloud.example.org/s/MlnTDkhcBlihNzO",
          },
        },
      },
    },
    #{ title: "update link" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
        body: #{id: "00000000-0000-0000-0000-000000000000"},
      },
      returnType: #{
        _: 200,
        body: #{
          id: "81d5bad3-3eff-410a-a2ea-eda2d14d4474",
          roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
          grantedToV2: #{
            user: #{
              id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
              displayName: "Albert Einstein",
            },
          },
        },
      },
    },
    #{ title: "update invite" }
  )
  @tag("drives.root")
  op updatePermissionSpaceRoot is PermissionsOps.updatePermission<DriveIdPath>;

  @summary("Remove access to a Drive")
  @doc("""
    Remove access to the root item of a drive.

    Only sharing permissions that are not inherited can be deleted. The `inheritedFrom` property must be `null`.
    """)
  @operationId("DeletePermissionSpaceRoot")
  @tag("drives.root")
  op deletePermissionSpaceRoot is PermissionsOps.deletePermission<DriveIdPath>;
}

@route("/v1beta1/drives/{drive-id}/root/permissions/{perm-id}/setPassword")
namespace DriveRootPermissionSetPassword {

  @summary("Set sharing link password for the root item of a drive")
  @doc("""
    Set the password of a sharing permission.

    Only the `password` property can be modified this way.
    """)
  @operationId("SetPermissionPasswordSpaceRoot")
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
        body: #{password: "TestPassword123!"},
      },
    },
    #{ title: "set password" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
        body: #{password: ""},
      },
    },
    #{ title: "set empty password" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
        body: #{password: "x"},
      },
      returnType: #{
        _: 200,
        body: #{
          id: "7181275c-557e-4adf-8e44-abdcf5389b6a",
          hasPassword: true,
          link: #{
            type: "edit",
            `@libre.graph.displayName`: "Homework",
            webUrl: "https://cloud.example.org/s/fdleMyGeerkIZTJ",
          },
        },
      },
    },
    #{ title: "set password on editor link with custom display name" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
        body: #{password: "x"},
      },
      returnType: #{
        _: 200,
        body: #{
          id: "765c9b7b-6ccf-46ff-a659-95501250229c",
          hasPassword: false,
          link: #{
            type: "view",
            `@libre.graph.displayName`: "Quick link",
            `@libre.graph.quickLink`: true,
            webUrl: "https://cloud.example.org/s/erjHgjKjkstTesG",
          },
        },
      },
    },
    #{ title: "set empty password" }
  )
  @tag("drives.root")
  op setPermissionPasswordSpaceRoot is PermissionsOps.setPermissionPassword<DriveIdPath>;
}

// =============================================================================
// DriveItem sharing — links / invites / permissions
// =============================================================================

@route("/v1beta1/drives/{drive-id}/items/{item-id}/createLink")
namespace DriveItemCreateLink {

  @summary("Create a sharing link for a DriveItem")
  @doc("""
    You can use the createLink action to share a driveItem via a sharing link.

    The response will be a permission object with the link facet containing the created link details.

    ## Link types

    For now, The following values are allowed for the type parameter.

    | Value          | Display name      | Description                                                     |
    | -------------- | ----------------- | --------------------------------------------------------------- |
    | view           | View              | Creates a read-only link to the driveItem.                      |
    | upload         | Upload            | Creates a read-write link to the folder driveItem.              |
    | edit           | Edit              | Creates a read-write link to the driveItem.                     |
    | createOnly     | File Drop         | Creates an upload-only link to the folder driveItem.            |
    | blocksDownload | Secure View       | Creates a read-only link that blocks download to the driveItem. |
    """)
  @operationId("CreateLink")
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        body: #{type: "view"},
      },
    },
    #{ title: "create viewer link" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        body: #{type: "edit", displayName: "Homework"},
      },
    },
    #{ title: "create editor link with custom display name" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        body: #{type: "edit"},
      },
    },
    #{ title: "create editor link with expiry" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
      },
      returnType: #{
        _: 200,
        body: #{
          id: "7181275c-557e-4adf-8e44-abdcf5389b6a",
          link: #{
            type: "view",
            webUrl: "https://cloud.example.org/s/YlaySZdHCRHUDeE",
          },
        },
      },
    },
    #{ title: "create viewer link" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
      },
      returnType: #{
        _: 200,
        body: #{
          id: "7181275c-557e-4adf-8e44-abdcf5389b6a",
          link: #{
            type: "edit",
            `@libre.graph.displayName`: "Homework",
            webUrl: "https://cloud.example.org/s/fdleMyGeerkIZTJ",
          },
        },
      },
    },
    #{ title: "create editor link with custom display name" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
      },
      returnType: #{
        _: 200,
        body: #{
          id: "a373c812-d786-42ae-a65f-ed87ee4abd49",
          link: #{
            type: "edit",
            webUrl: "https://cloud.example.org/s/MlnTDkhcBlihNzO",
          },
        },
      },
    },
    #{ title: "create editor link with expiry" }
  )
  @tag("drives.permissions")
  op createLink is PermissionsOps.createLink<DriveAndItemIdPath>;
}

@route("/v1beta1/drives/{drive-id}/items/{item-id}/invite")
namespace DriveItemInvite {

  @summary("Send a sharing invitation")
  @doc("""
    Sends a sharing invitation for a `driveItem`. A sharing invitation provides permissions to the
    recipients and optionally sends them an email with a sharing link.

    The response will be a permission object with the grantedToV2 property containing the created grant details.

    ## Roles property values
    For now, roles are only identified by a uuid. There are no hardcoded aliases like `read` or `write` because role actions can be completely customized.
    """)
  @operationId("Invite")
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        body: #{
          recipients: #[
            #{
              `@libre.graph.recipient.type`: "user",
              objectId: "4c510ada-c86b-4815-8820-42cdf82c3d51",
            },
          ],
          roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
        },
      },
    },
    #{ title: "send viewer invite" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        body: #{
          recipients: #[
            #{
              `@libre.graph.recipient.type`: "user",
              objectId: "4c510ada-c86b-4815-8820-42cdf82c3d51",
            },
            #{
              `@libre.graph.recipient.type`: "user",
              objectId: "f7fbf8c8-139b-4376-b307-cf0a8c2d0d9c",
            },
          ],
          roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
        },
      },
    },
    #{ title: "send viewer invite to multiple recipients" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        body: #{
          recipients: #[
            #{
              `@libre.graph.recipient.type`: "user",
              objectId: "4c510ada-c86b-4815-8820-42cdf82c3d51",
            },
          ],
          roles: #["fb6c3e19-e378-47e5-b277-9732f9de6e21"],
        },
      },
    },
    #{ title: "send editor invite with expiry" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        body: #{
          recipients: #[
            #{
              `@libre.graph.recipient.type`: "group",
              objectId: "167cbee2-0518-455a-bfb2-031fe0621e5d",
            },
          ],
          roles: #["312c0871-5ef7-4b3a-85b6-0e4074c64049"],
        },
      },
    },
    #{ title: "send manager invite to group", description: "Sharing with a groups requires setting the @libre.graph.recipient.type annotation." }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        body: #{
          recipients: #[#{objectId: "4c510ada-c86b-4815-8820-42cdf82c3d51"}],
          `@libre.graph.permissions.actions`: #["libre.graph/driveItem/basic/read", "libre.graph/driveItem/path/update"],
        },
      },
    },
    #{ title: "send invite to user granting custom actions", description: "A Custom role is just a collection of actions, in this case allowing the user to stat and move driveItems" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
      },
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "34646ab6-be32-43c9-89e6-987e0c237e9b",
              roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
              grantedToV2: #{
                user: #{
                  id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                  displayName: "Albert Einstein",
                },
              },
            },
          ],
        },
      },
    },
    #{ title: "send viewer invite" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
      },
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "81d5bad3-3eff-410a-a2ea-eda2d14d4474",
              roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
              grantedToV2: #{
                user: #{
                  id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                  displayName: "Albert Einstein",
                },
              },
            },
            #{
              id: "b470677e-a7f5-4304-8ef5-f5056a21fff1",
              roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
              grantedToV2: #{
                user: #{
                  id: "f7fbf8c8-139b-4376-b307-cf0a8c2d0d9c",
                  displayName: "Marie Skłodowska Curie",
                },
              },
            },
          ],
        },
      },
    },
    #{ title: "send viewer invite to multiple recipients", description: "multiple permissions are returned as each has received a dedicated sharing id" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
      },
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "453b02be-4ec2-4e7d-b576-09fc153de812",
              roles: #["fb6c3e19-e378-47e5-b277-9732f9de6e21"],
              grantedToV2: #{
                user: #{
                  id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                  displayName: "Albert Einstein",
                },
              },
            },
          ],
        },
      },
    },
    #{ title: "send editor invite with expiry" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
      },
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "86765c0d-3905-444a-9b07-76201f8cf7df",
              roles: #["312c0871-5ef7-4b3a-85b6-0e4074c64049"],
              grantedToV2: #{
                group: #{
                  id: "167cbee2-0518-455a-bfb2-031fe0621e5d",
                  displayName: "Philosophy Haters",
                },
              },
            },
          ],
        },
      },
    },
    #{ title: "send manager invite to group" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
      },
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "c42b5cbd-2d65-42cf-b0b6-fb6d2b762256",
              grantedToV2: #{
                user: #{
                  id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                  displayName: "Albert Einstein",
                },
              },
              `@libre.graph.permissions.actions`: #["libre.graph/driveItem/basic/read", "libre.graph/driveItem/path/update"],
            },
          ],
        },
      },
    },
    #{ title: "send invite to user granting custom actions" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
      },
      returnType: #{
        _: 400,
        body: #{
          error: #{
            code: "invalidRequest",
            message: "Some users in the request cannot be invited securely.",
          },
        },
      },
    },
    #{ title: "secureSharingInvalidRequest", description: "If the recipient was given via email, but does not belong to a known user account." }
  )
  @tag("drives.permissions")
  op invite is PermissionsOps.invite<DriveAndItemIdPath>;
}

@route("/v1beta1/drives/{drive-id}/items/{item-id}/permissions")
namespace DriveItemPermissions {

  @summary("List the effective sharing permissions on a driveItem.")
  @doc("""
    The permissions collection includes potentially sensitive information and may not be available for every caller.

    * For the owner of the item, all sharing permissions will be returned. This includes co-owners.
    * For a non-owner caller, only the sharing permissions that apply to the caller are returned.
    * Sharing permission properties that contain secrets (e.g. `webUrl`) are only returned for callers that are able to create the sharing permission.

    All permission objects have an `id`. A permission representing
    * a link has the `link` facet filled with details.
    * a share has the `roles` property set and the `grantedToV2` property filled with the grant recipient details.
    """)
  @operationId("ListPermissions")
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
      },
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "67445fde-a647-4dd4-b015-fc5dafd2821d",
              link: #{
                type: "view",
                webUrl: "https://cloud.example.org/s/fhGBMIkKFEHWysj",
              },
            },
            #{
              id: "34646ab6-be32-43c9-89e6-987e0c237e9b",
              roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
              grantedToV2: #{
                user: #{
                  id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                  displayName: "Albert Einstein",
                },
              },
            },
            #{
              id: "81d5bad3-3eff-410a-a2ea-eda2d14d4474",
              roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
              grantedToV2: #{
                user: #{
                  id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                  displayName: "Albert Einstein",
                },
              },
            },
            #{
              id: "b470677e-a7f5-4304-8ef5-f5056a21fff1",
              roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
              grantedToV2: #{
                user: #{
                  id: "f7fbf8c8-139b-4376-b307-cf0a8c2d0d9c",
                  displayName: "Marie Skłodowska Curie",
                },
              },
            },
            #{
              id: "453b02be-4ec2-4e7d-b576-09fc153de812",
              roles: #["fb6c3e19-e378-47e5-b277-9732f9de6e21"],
              grantedToV2: #{
                user: #{
                  id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                  displayName: "Albert Einstein",
                },
              },
            },
            #{
              id: "86765c0d-3905-444a-9b07-76201f8cf7df",
              roles: #["312c0871-5ef7-4b3a-85b6-0e4074c64049"],
              grantedToV2: #{
                group: #{
                  id: "167cbee2-0518-455a-bfb2-031fe0621e5d",
                  displayName: "Philosophy Haters",
                },
              },
            },
            #{
              id: "c42b5cbd-2d65-42cf-b0b6-fb6d2b762256",
              grantedToV2: #{
                user: #{
                  id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
                  displayName: "Albert Einstein",
                },
              },
              `@libre.graph.permissions.actions`: #["libre.graph/driveItem/basic/read", "libre.graph/driveItem/path/update"],
            },
          ],
        },
      },
    },
    #{ title: "ListPermissions_default_resp" }
  )
  @tag("drives.permissions")
  op listPermissions is PermissionsOps.listPermissions<DriveAndItemIdPath>;
}

@route("/v1beta1/drives/{drive-id}/items/{item-id}/permissions/{perm-id}")
namespace DriveItemPermission {

  @summary("Get sharing permission for a file or folder")
  @doc("Return the effective sharing permission for a particular permission resource.")
  @operationId("GetPermission")
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
      },
      returnType: #{
        _: 200,
        body: #{
          id: "81d5bad3-3eff-410a-a2ea-eda2d14d4474",
          roles: #["write"],
          grantedToV2: #{
            user: #{
              id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
              displayName: "Albert Einstein",
            },
          },
        },
      },
    },
    #{ title: "edit permission" }
  )
  @tag("drives.permissions")
  op getPermission is PermissionsOps.getPermission<DriveAndItemIdPath>;

  @summary("Update sharing permission")
  @doc("""
    Update the properties of a sharing permission by patching the permission resource.

    Only the `roles`, `expirationDateTime` and `password` properties can be modified this way.
    """)
  @operationId("UpdatePermission")
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
        body: #{link: #{type: "edit"}},
      },
    },
    #{ title: "update link", description: "Updating a public link is done by setting the `type` property of the permission link." }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
        body: #{roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"]},
      },
    },
    #{ title: "update invite", description: "Updating an invite is done by setting the `roles` property of the permission." }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
        body: #{id: "00000000-0000-0000-0000-000000000000"},
      },
      returnType: #{
        _: 200,
        body: #{
          id: "a373c812-d786-42ae-a65f-ed87ee4abd49",
          link: #{
            type: "edit",
            webUrl: "https://cloud.example.org/s/MlnTDkhcBlihNzO",
          },
        },
      },
    },
    #{ title: "update link" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
        body: #{id: "00000000-0000-0000-0000-000000000000"},
      },
      returnType: #{
        _: 200,
        body: #{
          id: "81d5bad3-3eff-410a-a2ea-eda2d14d4474",
          roles: #["b1e2218d-eef8-4d4c-b82d-0f1a1b48f3b5"],
          grantedToV2: #{
            user: #{
              id: "4c510ada-c86b-4815-8820-42cdf82c3d51",
              displayName: "Albert Einstein",
            },
          },
        },
      },
    },
    #{ title: "update invite" }
  )
  @tag("drives.permissions")
  op updatePermission is PermissionsOps.updatePermission<DriveAndItemIdPath>;

  @summary("Remove access to a DriveItem")
  @doc("""
    Remove access to a DriveItem.

    Only sharing permissions that are not inherited can be deleted. The `inheritedFrom` property must be `null`.
    """)
  @operationId("DeletePermission")
  @tag("drives.permissions")
  op deletePermission is PermissionsOps.deletePermission<DriveAndItemIdPath>;
}

@route("/v1beta1/drives/{drive-id}/items/{item-id}/permissions/{perm-id}/setPassword")
namespace DriveItemPermissionSetPassword {

  @summary("Set sharing link password")
  @doc("""
    Set the password of a sharing permission.

    Only the `password` property can be modified this way.
    """)
  @operationId("SetPermissionPassword")
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
        body: #{password: "TestPassword123!"},
      },
    },
    #{ title: "set password" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
        body: #{password: ""},
      },
    },
    #{ title: "set empty password" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
        body: #{password: "x"},
      },
      returnType: #{
        _: 200,
        body: #{
          id: "7181275c-557e-4adf-8e44-abdcf5389b6a",
          hasPassword: true,
          link: #{
            type: "edit",
            `@libre.graph.displayName`: "Homework",
            webUrl: "https://cloud.example.org/s/fdleMyGeerkIZTJ",
          },
        },
      },
    },
    #{ title: "set password on editor link with custom display name" }
  )
  @opExample(
    #{
      parameters: #{
        `drive-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668",
        `item-id`: "a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668!some-item",
        `perm-id`: "a373c812-d786-42ae-a65f-ed87ee4abd49",
        body: #{password: "x"},
      },
      returnType: #{
        _: 200,
        body: #{
          id: "765c9b7b-6ccf-46ff-a659-95501250229c",
          hasPassword: false,
          link: #{
            type: "view",
            `@libre.graph.displayName`: "Quick link",
            `@libre.graph.quickLink`: true,
            webUrl: "https://cloud.example.org/s/erjHgjKjkstTesG",
          },
        },
      },
    },
    #{ title: "set empty password" }
  )
  @tag("drives.permissions")
  op setPermissionPassword is PermissionsOps.setPermissionPassword<DriveAndItemIdPath>;
}
