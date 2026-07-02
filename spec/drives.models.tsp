import "@typespec/http";
import "@typespec/openapi";
import "@typespec/json-schema";

import "./common.models.tsp";
import "./common.templates.tsp";

using Http;
using OpenAPI;


namespace LibreGraph;

// =============================================================================
// Identity types
//
// Used throughout the drive domain for createdBy / lastModifiedBy / owner
// fields and on the permission resource (grantedToV2). Defined here because
// no other domain currently references them.
// =============================================================================

model identity {
  @doc("The identity's display name. Note that this may not always be available or up to date. For example, if a user changes their display name, the API may show the new value in a future response, but the items associated with the user won't show up as having changed when using delta.")
  displayName: string;

  @doc("Unique identifier for the identity.")
  id?: string;

  @doc("The type of the identity. This can be either \"Member\" for regular user, \"Guest\" for guest users or \"Federated\" for users imported from a federated instance. Can be used by clients to indicate the type of user. For more details, clients should look up and cache the user at the /users endpoint.")
  `@libre.graph.userType`?: string;
}

@doc("Optional. User account.")
model identitySet {
  @doc("Optional. The application associated with this action.")
  application?: identity;

  @doc("Optional. The device associated with this action.")
  device?: identity;

  @doc("Optional. The user associated with this action.")
  user?: identity;

  @doc("Optional. The group associated with this action.")
  group?: identity;
}

model sharePointIdentitySet {
  user?: identity;
  group?: identity;
}

// =============================================================================
// Drive entity + itemReference
// =============================================================================

model itemReference {
  @extension("readOnly", true)
  @doc("Unique identifier of the drive instance that contains the item. Read-only.")
  driveId?: string;

  @extension("readOnly", true)
  @doc("Identifies the type of drive. See [drive][] resource for values. Read-only.")
  driveType?: string;

  @extension("readOnly", true)
  @doc("Unique identifier of the item in the drive. Read-only.")
  id?: string;

  @extension("readOnly", true)
  @doc("The name of the item being referenced. Read-only.")
  name?: string;

  @extension("readOnly", true)
  @doc("Path that can be used to navigate to the item. Read-only.")
  path?: string;
}

@friendlyName("driveUpdate")
@doc("The drive represents an update to a space on the storage.")
model driveBase {
  @extension("readOnly", true)
  @doc("The unique identifier for this drive.")
  id?: string;

  @extension("readOnly", true)
  @doc("Identity of the user, device, or application which created the item. Read-only.")
  createdBy?: identitySet;

  @extension("pattern", "^[0-9]{4,}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])[Tt]([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]([.][0-9]{1,12})?([Zz]|[+-][0-9][0-9]:[0-9][0-9])$")
  @extension("readOnly", true)
  @doc("Date and time of item creation. Read-only.")
  createdDateTime?: utcDateTime;

  @doc("Provides a user-visible description of the item. Optional.")
  description?: string;

  @extension("readOnly", true)
  @doc("ETag for the item. Read-only.")
  eTag?: string;

  @extension("readOnly", true)
  @doc("Identity of the user, device, and application which last modified the item. Read-only.")
  lastModifiedBy?: identitySet;

  @extension("pattern", "^[0-9]{4,}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])[Tt]([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]([.][0-9]{1,12})?([Zz]|[+-][0-9][0-9]:[0-9][0-9])$")
  @extension("readOnly", true)
  @doc("Date and time the item was last modified. Read-only.")
  lastModifiedDateTime?: utcDateTime;

  @doc("The name of the item. Read-write.")
  name?: string;

  @doc("Parent information, if the item has a parent. Read-write.")
  parentReference?: itemReference;

  @extension("readOnly", true)
  @doc("URL that displays the resource in the browser. Read-only.")
  webUrl?: string;

  @extension("readOnly", true)
  @doc("Describes the type of drive represented by this resource. Values are \"personal\" for users home spaces, \"project\", \"virtual\" or \"share\". Read-only.")
  driveType?: string;

  @doc("The drive alias can be used in clients to make the urls user friendly. Example: 'personal/einstein'. This will be used to resolve to the correct driveID.")
  driveAlias?: string;

  owner?: identitySet;
  quota?: quotaModel;

  @extension("readOnly", true)
  @doc("All items contained in the drive. Read-only. Nullable.")
  items?: driveItemModel[];

  @doc("Drive item describing the drive's root. Read-only.")
  root?: driveItemModel;

  @doc("A collection of special drive resources.")
  special?: driveItemModel[];

  @extension("readOnly", true)
  @doc("Indicates whether the drive has items in the trash. Read-only.")
  `@libre.graph.hasTrashedItems`?: boolean;
}

@friendlyName("drive")
@doc("The drive represents a space on the storage.")
model driveResource extends driveBase {
  @doc("The name of the item. Read-write.")
  name: string;
}

// =============================================================================
// driveItem facet schemas
// =============================================================================

@doc("Information about the deleted state of the item. Read-only.")
@extension("readOnly", true)
model deleted {
  @doc("Represents the state of the deleted item.")
  state?: string;
}

@doc("Hashes of the file's binary content, if available. Read-only.")
@extension("readOnly", true)
model hashes {
  @doc("The CRC32 value of the file (if available). Read-only.")
  @maxLength(8)
  crc32Hash?: string;

  @doc("A proprietary hash of the file that can be used to determine if the contents of the file have changed (if available). Read-only.")
  quickXorHash?: string;

  @doc("SHA1 hash for the contents of the file (if available). Read-only.")
  @maxLength(40)
  sha1Hash?: string;

  @doc("SHA256 hash for the contents of the file (if available). Read-only.")
  @maxLength(160)
  sha256Hash?: string;
}

@doc("File metadata, if the item is a file. Read-only.")
@extension("readOnly", true)
model openGraphFile {
  hashes?: hashes;

  @extension("readOnly", true)
  @doc("The MIME type for the file. This is determined by logic on the server and might not be the value provided when the file was uploaded. Read-only.")
  mimeType?: string;

  processingMetadata?: boolean;
}

@doc("File system information on client. Read-write.")
model fileSystemInfo {
  @extension("pattern", "^[0-9]{4,}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])[Tt]([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]([.][0-9]{1,12})?([Zz]|[+-][0-9][0-9]:[0-9][0-9])$")
  @doc("The UTC date and time the file was created on a client.")
  createdDateTime?: utcDateTime;

  @extension("pattern", "^[0-9]{4,}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])[Tt]([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]([.][0-9]{1,12})?([Zz]|[+-][0-9][0-9]:[0-9][0-9])$")
  @doc("The UTC date and time the file was last accessed. Available for the recent file list only.")
  lastAccessedDateTime?: utcDateTime;

  @extension("pattern", "^[0-9]{4,}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])[Tt]([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]([.][0-9]{1,12})?([Zz]|[+-][0-9][0-9]:[0-9][0-9])$")
  @doc("The UTC date and time the file was last modified on a client.")
  lastModifiedDateTime?: utcDateTime;
}

@doc("A collection of properties defining the recommended view for the folder.")
model folderView {
  @doc("The method by which the folder should be sorted.")
  sortBy?: string;

  @doc("If true, indicates that items should be sorted in descending order. Otherwise, items should be sorted ascending.")
  sortOrder?: string;

  @doc("The type of view that should be used to represent the folder.")
  viewType?: string;
}

@doc("Folder metadata, if the item is a folder. Read-only.")
@extension("readOnly", true)
model folder {
  @doc("Number of children contained immediately within this container.")
  @maxValue(2147483647)
  childCount?: int32;

  view?: folderView;
}

@doc("Image metadata, if the item is an image. Read-only.")
@extension("readOnly", true)
model image {
  @extension("readOnly", true)
  @doc("Optional. Height of the image, in pixels. Read-only.")
  @maxValue(2147483647)
  height?: int32;

  @extension("readOnly", true)
  @doc("Optional. Width of the image, in pixels. Read-only.")
  @maxValue(2147483647)
  width?: int32;
}

@doc("""
  The photo resource provides photo and camera properties, for example, EXIF metadata, on a driveItem.
  """)
@extension("readOnly", true)
model photo {
  @doc("Camera manufacturer. Read-only.")
  cameraMake?: string;

  @doc("Camera model. Read-only.")
  cameraModel?: string;

  @doc("The denominator for the exposure time fraction from the camera. Read-only.")
  exposureDenominator?: float64;

  @doc("The numerator for the exposure time fraction from the camera. Read-only.")
  exposureNumerator?: float64;

  @doc("The F-stop value from the camera. Read-only.")
  fNumber?: float64;

  @doc("The focal length from the camera. Read-only.")
  focalLength?: float64;

  @doc("The ISO value from the camera. Read-only.")
  iso?: int32;

  @doc("The orientation value from the camera. Read-only.")
  orientation?: int16;

  @extension("pattern", "^[0-9]{4,}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])[Tt]([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]([.][0-9]{1,12})?([Zz]|[+-][0-9][0-9]:[0-9][0-9])$")
  @doc("Represents the date and time the photo was taken. Read-only.")
  takenDateTime?: utcDateTime;
}

@doc("""
  Motion Photo metadata. A Motion Photo is a still image with a short video clip appended to
  the end of the file. The presence of this facet on a driveItem indicates that the item is
  a Motion Photo; absence indicates it is not.

  Based on the Google Motion Photo format v1.0 specification:
  https://developer.android.com/media/platform/motion-photo-format
  """)
@extension("readOnly", true)
model motionPhoto {
  @extension("readOnly", true)
  @doc("The file format version of the Motion Photo. Currently always 1. Read-only.")
  version?: int32;

  @doc("""
    Presentation timestamp in microseconds of the video frame that corresponds to the still
    image. A value of -1 indicates unspecified. If absent, readers should use a timestamp
    near the middle of the video track. Read-only.
    """)
  @extension("readOnly", true)
  presentationTimestampUs?: int64;

  @doc("""
    Size in bytes of the embedded video portion of the file. The video is appended at the
    end of the file, so clients can fetch it with a Range request:
    `Range: bytes=<fileSize - videoSize>-`. Read-only.
    """)
  @extension("readOnly", true)
  videoSize?: int64;
}

@doc("""
  The GeoCoordinates resource provides geographic coordinates and elevation of a location based on metadata contained within the file.
  If a DriveItem has a non-null location facet, the item represents a file with a known location associated with it.
  """)
@extension("readOnly", true)
model geoCoordinates {
  @doc("The altitude (height), in feet, above sea level for the item. Read-only.")
  altitude?: float64;

  @doc("The latitude, in decimal, for the item. Read-only.")
  latitude?: float64;

  @doc("The longitude, in decimal, for the item. Read-only.")
  longitude?: float64;
}

@doc("""
  The thumbnail resource type represents a thumbnail for an image, video, document, or any item that has a bitmap representation.
  """)
@extension("readOnly", true)
model thumbnail {
  @doc("The content stream for the thumbnail.")
  @encode("base64url")
  content?: bytes;

  @doc("The height of the thumbnail, in pixels.")
  height?: int32;

  @doc("The unique identifier of the item that provided the thumbnail. This is only available when a folder thumbnail is requested.")
  sourceItemId?: string;

  @doc("The URL used to fetch the thumbnail content.")
  url?: string;

  @doc("The width of the thumbnail, in pixels.")
  width?: int32;
}

@doc("""
  The ThumbnailSet resource is a keyed collection of thumbnail resources.
  It's used to represent a set of thumbnails associated with a DriveItem.
  """)
@extension("readOnly", true)
model thumbnailSet {
  @doc("The ID within the item. Read-only.")
  id?: string;

  @doc("A 1920x1920 scaled thumbnail.")
  large?: thumbnail;

  @doc("A 176x176 scaled thumbnail.")
  medium?: thumbnail;

  @doc("A 48x48 cropped thumbnail.")
  small?: thumbnail;

  @doc("A custom thumbnail image or the original image used to generate other thumbnails.")
  source?: thumbnail;
}

@doc("If this property is non-null, it indicates that the driveItem is the top-most driveItem in the drive.")
model root {}

@doc("Metadata for trashed drive Items")
@extension("readOnly", true)
model trash {
  @extension("readOnly", true)
  @doc("Identity of the user, device, or application which trashed the item. Read-only.")
  trashedBy?: identitySet;

  @extension("pattern", "^[0-9]{4,}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])[Tt]([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]([.][0-9]{1,12})?([Zz]|[+-][0-9][0-9]:[0-9][0-9])$")
  @doc("The UTC date and time the folder was marked as trashed.")
  trashedDateTime?: utcDateTime;
}

@doc("If the current item is also available as a special folder, this facet is returned. Read-only")
@extension("readOnly", true)
model specialFolder {
  @doc("The unique identifier for this item in the /drive/special collection")
  name?: string;
}

@doc("""
  The Audio resource groups audio-related properties on an item into a single structure.

  If a DriveItem has a non-null audio facet, the item represents an audio file. The properties of the Audio resource are populated by extracting metadata from the file.
  """)
model audio {
  @doc("The title of the album for this audio file.")
  album?: string;

  @doc("The artist named on the album for the audio file.")
  albumArtist?: string;

  @doc("The performing artist for the audio file.")
  artist?: string;

  @doc("Bitrate expressed in kbps.")
  bitrate?: int64;

  @doc("The name of the composer of the audio file.")
  composers?: string;

  @doc("Copyright information for the audio file.")
  copyright?: string;

  @doc("The number of the disc this audio file came from.")
  disc?: int16;

  @doc("The total number of discs in this album.")
  discCount?: int16;

  @doc("Duration of the audio file, expressed in milliseconds")
  duration?: int64;

  @doc("The genre of this audio file.")
  genre?: string;

  @doc("Indicates if the file is protected with digital rights management.")
  hasDrm?: boolean;

  @doc("Indicates if the file is encoded with a variable bitrate.")
  isVariableBitrate?: boolean;

  @doc("The title of the audio file.")
  title?: string;

  @doc("The number of the track on the original disc for this audio file.")
  track?: int32;

  @doc("The total number of tracks on the original disc for this audio file.")
  trackCount?: int32;

  @doc("The year the audio file was recorded.")
  year?: int32;
}

@doc("""
  The video resource groups video-related data items into a single structure.

  If a driveItem has a non-null video facet, the item represents a video file. The properties of the video resource are populated by extracting metadata from the file.
  """)
model video {
  @doc("Number of audio bits per sample.")
  audioBitsPerSample?: int32;

  @doc("Number of audio channels.")
  audioChannels?: int32;

  @doc("Name of the audio format (AAC, MP3, etc.).")
  audioFormat?: string;

  @doc("Number of audio samples per second.")
  audioSamplesPerSecond?: int32;

  @doc("Bit rate of the video in bits per second.")
  bitrate?: int32;

  @doc("Duration of the file in milliseconds.")
  duration?: int64;

  @doc("\"Four character code\" name of the video format.")
  fourCC?: string;

  @doc("Frame rate of the video.")
  frameRate?: float64;

  @doc("Height of the video, in pixels.")
  height?: int32;

  @doc("Width of the video, in pixels.")
  width?: int32;
}

@doc("invitation-related data items")
model sharingInvitation {
  @doc("Provides information about who sent the invitation that created this permission, if that information is available. Read-only.")
  invitedBy?: identitySet;
}

@doc("""
  The Permission resource provides information about a sharing permission granted for a DriveItem resource.

  ### Remarks

  The Permission resource uses *facets* to provide information about the kind of permission represented by the resource.

  Permissions with a `link` facet represent sharing links created on the item. Sharing links contain a unique token that provides access to the item for anyone with the link.

  Permissions with a `invitation` facet represent permissions added by inviting specific users or groups to have access to the file.
  """)
@extension("readOnly", true)
model permission {
  @extension("readOnly", true)
  @doc("The unique identifier of the permission among all permissions on the item. Read-only.")
  id?: string;

  @doc("""
    Indicates whether the password is set for this permission. This property only
    appears in the response. Optional. Read-only.
    """)
  @extension("readOnly", true)
  hasPassword?: boolean;

  @doc("An optional expiration date which limits the permission in time.")
  expirationDateTime?: utcDateTime | null;

  @doc("An optional creation date. Libregraph only.")
  createdDateTime?: utcDateTime | null;

  @doc("For user type permissions, the details of the users and applications for this permission. Only part of responses. Use the invitation property when creating shares.")
  grantedToV2?: sharePointIdentitySet;

  @doc("Provides the link details of the current permission, if it is a link type permissions.")
  link?: sharingLinkModel;

  roles?: string[];

  #deprecated "Replaced by `grantedToV2`."
  @doc("For link type permissions, the details of the identity to whom permission was granted. This could be used to grant access to a an external user that can be identified by email, aka guest accounts.")
  grantedToIdentities?: identitySet[];

  @doc("Use this to create a permission with custom actions.")
  `@libre.graph.permissions.actions`?: string[];

  @doc("Details of any associated sharing invitation for this permission.")
  invitation?: sharingInvitation;
}

@doc("Remote item data, if the item is shared from a drive other than the one being accessed. Read-only.")
@friendlyName("remoteItem")
model remoteItemModel {
  createdBy?: identitySet;

  @extension("pattern", "^[0-9]{4,}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])T([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]([.][0-9]{1,12})?(Z|[+-][0-9][0-9]:[0-9][0-9])$")
  @doc("Date and time of item creation. Read-only.")
  createdDateTime?: utcDateTime;

  file?: openGraphFile;
  fileSystemInfo?: fileSystemInfo;
  folder?: folder;

  @doc("The drive alias can be used in clients to make the urls user friendly. Example: 'personal/einstein'. This will be used to resolve to the correct driveID.")
  driveAlias?: string;

  @doc("The relative path of the item in relation to its drive root.")
  path?: string;

  @doc("Unique identifier for the drive root of this item. Read-only.")
  rootId?: string;

  @doc("Unique identifier for the remote item in its drive. Read-only.")
  id?: string;

  image?: image;
  lastModifiedBy?: identitySet;

  @extension("pattern", "^[0-9]{4,}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])T([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]([.][0-9]{1,12})?(Z|[+-][0-9][0-9]:[0-9][0-9])$")
  @doc("Date and time the item was last modified. Read-only.")
  lastModifiedDateTime?: utcDateTime;

  @doc("Optional. Filename of the remote item. Read-only.")
  name?: string;

  @extension("readOnly", true)
  @doc("ETag for the item. Read-only.")
  eTag?: string;

  @extension("readOnly", true)
  @doc("An eTag for the content of the item. This eTag is not changed if only the metadata is changed. Note This property is not returned if the item is a folder. Read-only.")
  cTag?: string;

  parentReference?: itemReference;

  @extension("readOnly", true)
  @doc("The set of permissions for the item. Read-only. Nullable.")
  permissions?: permission[];

  @doc("Size of the remote item. Read-only.")
  size?: int64;

  specialFolder?: specialFolder;

  @doc("DAV compatible URL for the item.")
  webDavUrl?: string;

  @doc("URL that displays the resource in the browser. Read-only.")
  webUrl?: string;
}

// =============================================================================
// quota
// =============================================================================

@friendlyName("quota")
@doc("Optional. Information about the drive's storage space quota. Read-only.")
@extension("readOnly", true)
model quotaModel {
  @extension("readOnly", true)
  @doc("Total space consumed by files in the recycle bin, in bytes. Read-only.")
  deleted?: int64;

  @extension("readOnly", true)
  @doc("Total space remaining before reaching the quota limit, in bytes. Read-only.")
  remaining?: int64;

  @extension("readOnly", true)
  @doc("Enumeration value that indicates the state of the storage space. Either \"normal\", \"nearing\", \"critical\" or \"exceeded\". Read-only.")
  state?: string;

  @extension("readOnly", true)
  @doc("Total allowed storage space, in bytes. Read-only.")
  total?: int64;

  @extension("readOnly", true)
  @doc("Total space used, in bytes. Read-only.")
  used?: int64;
}

// =============================================================================
// driveItem
// =============================================================================

@friendlyName("driveItem")
@doc("Represents a resource inside a drive. Read-only.")
@extension("readOnly", true)
model driveItemModel {
  @extension("readOnly", true)
  @doc("Read-only.")
  id?: string;

  @extension("readOnly", true)
  @doc("Identity of the user, device, or application which created the item. Read-only.")
  createdBy?: identitySet;

  @extension("pattern", "^[0-9]{4,}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])[Tt]([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]([.][0-9]{1,12})?([Zz]|[+-][0-9][0-9]:[0-9][0-9])$")
  @extension("readOnly", true)
  @doc("Date and time of item creation. Read-only.")
  createdDateTime?: utcDateTime;

  @doc("Provides a user-visible description of the item. Optional.")
  description?: string;

  @extension("readOnly", true)
  @doc("ETag for the item. Read-only.")
  eTag?: string;

  @extension("readOnly", true)
  @doc("Identity of the user, device, and application which last modified the item. Read-only.")
  lastModifiedBy?: identitySet;

  @extension("pattern", "^[0-9]{4,}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])[Tt]([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]([.][0-9]{1,12})?([Zz]|[+-][0-9][0-9]:[0-9][0-9])$")
  @extension("readOnly", true)
  @doc("Date and time the item was last modified. Read-only.")
  lastModifiedDateTime?: utcDateTime;

  @doc("The name of the item. Read-write.")
  name?: string;

  @doc("Parent information, if the item has a parent. Read-write.")
  parentReference?: itemReference;

  @extension("readOnly", true)
  @doc("URL that displays the resource in the browser. Read-only.")
  webUrl?: string;

  @doc("The content stream, if the item represents a file.")
  @encode("base64url")
  content?: bytes;

  @extension("readOnly", true)
  @doc("An eTag for the content of the item. This eTag is not changed if only the metadata is changed. Note This property is not returned if the item is a folder. Read-only.")
  cTag?: string;

  deleted?: deleted;
  file?: openGraphFile;
  fileSystemInfo?: fileSystemInfo;
  folder?: folder;
  image?: image;
  photo?: photo;
  location?: geoCoordinates;

  @doc("Collection containing ThumbnailSet objects associated with the item. Read-only. Nullable.")
  thumbnails?: thumbnailSet[];

  root?: root;
  trash?: trash;
  specialFolder?: specialFolder;
  remoteItem?: remoteItemModel;

  @extension("readOnly", true)
  @doc("Size of the item in bytes. Read-only.")
  size?: int64;

  @extension("readOnly", true)
  @doc("WebDAV compatible URL for the item. Read-only.")
  webDavUrl?: string;

  @extension("readOnly", true)
  @doc("Collection containing Item objects for the immediate children of Item. Only items representing folders have children. Read-only. Nullable.")
  children?: driveItemModel[];

  @extension("readOnly", true)
  @doc("The set of permissions for the item. Read-only. Nullable.")
  permissions?: permission[];

  audio?: audio;
  video?: video;
  `@libre.graph.motionPhoto`?: motionPhoto;

  @doc("Indicates if the item is synchronized with the underlying storage provider. Read-only.")
  `@client.synchronize`?: boolean;

  @doc("""
    A pre-authenticated URL that can be used to download the item's content without
    providing an Authorization header. The URL is short-lived and cannot be cached.

    This annotation is only populated when explicitly requested via `$select`, and
    only for items that have a `file` facet. The returned URL is valid for a
    limited time and should be used promptly.
    """)
  @extension("readOnly", true)
  `@microsoft.graph.downloadUrl`?: string;

  @doc("Properties or facets (see UI.Facet) annotated with this term will not be rendered if the annotation evaluates to true. Users can set this to hide permissions.")
  `@UI.Hidden`?: boolean;
}

// =============================================================================
// Shared parameters used by drives operations
// =============================================================================

@friendlyName("drivesSelect")
model DrivesSelect {
  @TypeSpec.JsonSchema.uniqueItems
  @query(#{ explode: false })
  @doc("Select properties to be returned. By default all properties are returned.")
  `$select`?: "@libre.graph.hasTrashedItems"[];
}

@friendlyName("driveItemSelect")
model DriveItemSelect {
  @TypeSpec.JsonSchema.uniqueItems
  @query(#{ explode: false })
  @doc("Select additional properties to be returned.")
  `$select`?: "@microsoft.graph.downloadUrl"[];
}

model ItemIdPath {
  @path
  @extension("x-ms-docs-key-type", "item")
  @doc("key: id of item")
  @example("a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668")
  `item-id`: string;
}

@friendlyName("drivesExpand")
model DrivesExpand {
  @query
  @doc("Expand related entities")
  `$expand`?: string;
}

model DriveIdPath {
  @path
  @extension("x-ms-docs-key-type", "drive")
  @doc("key: id of drive")
  @example("a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668")
  `drive-id`: string;
}

model DriveAndItemIdPath {
  ...DriveIdPath;
  ...ItemIdPath;
}

@friendlyName("orderby")
model OrderBy {
  @query
  @doc("The $orderby system query option allows clients to request resources in either ascending order using asc or descending order using desc.")
  `$orderby`?: string;
}

@friendlyName("drivesFilter")
model DrivesFilter {
  @query
  @doc("Filter items by property values")
  `$filter`?: string;
}

// =============================================================================
// Drive collection / item response wrappers
// =============================================================================

@doc("Retrieved spaces")
model DrivesListResponse {
  @statusCode _: 200;
  @body body: allDrivesCollection;
}

alias allDrivesCollection = Collection<driveResource, "CollectionOfDrives1">;

@doc("Retrieved drive")
model DriveRetrieved {
  @statusCode _: 200;
  @body body: driveResource;
}

@doc("Created")
model DriveCreated {
  @statusCode _: 201;
  @body body: driveResource;
}

@doc("Success")
model DriveUpdated {
  @statusCode _: 200;
  @body body: driveResource;
}

@doc("Retrieved spaces")
model DrivesRetrieved {
  @statusCode _: 200;
  @body body: drivesResponse;
}

alias drivesResponse = PaginatedCollectionWithMaxItems<driveResource, "CollectionOfDrives", 100>;

@doc("Retrieved resource")
model DriveItemRetrieved {
  @statusCode _: 200;
  @body body: driveItemModel;
}

@doc("Retrieved resource list")
model DriveItemListRetrieved {
  @statusCode _: 200;
  @body body: paginatedDriveItemsCollection;
}

alias paginatedDriveItemsCollection = PaginatedCollectionWithMaxItems<driveItemModel, "CollectionOfDriveItems", 100>;

@doc("Retrieved driveItem")
model DriveItemRetrievedSelected {
  @statusCode _: 200;
  @body body: driveItemModel;
}

@doc("Success")
model DriveItemUpdated {
  @statusCode _: 200;
  @body body: driveItemModel;
}

@doc("Pre-authenticated redirect to the file content.")
model DriveItemContentRedirect {
  @statusCode _: 302;

  @header("Location")
  @doc("The pre-authenticated URL where the content can be downloaded.")
  location: url;
}

@doc("The driveItem was not found or is not a file.")
@error
model DriveItemContentNotFound {
  @statusCode _: 404;
  @body body: OdataError;
}

@doc("Response")
model CreateChildItemResponse {
  @statusCode _: 200;
  @body body: driveItemModel;
}

// =============================================================================
// Sharing protocol models (driveItem-specific)
// =============================================================================

@doc("""
  The type of the link created.

  | Value          | Display name      | Description                                                     |
  | -------------- | ----------------- | --------------------------------------------------------------- |
  | internal       | Internal          | Creates an internal link without any permissions.               |
  | view           | View              | Creates a read-only link to the driveItem.                      |
  | upload         | Upload            | Creates a read-write link to the folder driveItem.              |
  | edit           | Edit              | Creates a read-write link to the driveItem.                     |
  | createOnly     | File Drop         | Creates an upload-only link to the folder driveItem.            |
  | blocksDownload | Secure View       | Creates a read-only link that blocks download to the driveItem. |
  """)
union sharingLinkType {
  internal: "internal",
  view: "view",
  upload: "upload",
  edit: "edit",
  createOnly: "createOnly",
  blocksDownload: "blocksDownload",
}

@friendlyName("sharingLink")
@doc("""
  The `SharingLink` resource groups link-related data items into a single structure.

  If a `permission` resource has a non-null `sharingLink` facet, the permission represents a sharing link (as opposed to permissions granted to a person or group).
  """)
model sharingLinkModel {
  type?: sharingLinkType;

  @extension("readOnly", true)
  @doc("If `true` then the user can only use this link to view the item on the web, and cannot use it to download the contents of the item.")
  preventsDownload?: boolean;

  @extension("readOnly", true)
  @doc("A URL that opens the item in the browser on the website.")
  webUrl?: string;

  @doc("Provides a user-visible display name of the link. Optional. Libregraph only.")
  `@libre.graph.displayName`?: string;

  @doc("The quicklink property can be assigned to only one link per resource. A quicklink can be used in the clients to provide a one-click copy to clipboard action. Optional. Libregraph only.")
  `@libre.graph.quickLink`?: boolean;
}

@doc("""
  Represents a person, group, or other recipient to share a drive item with using the invite action.

  When using invite to add permissions, the `driveRecipient` object would specify the `email`, `alias`,
  or `objectId` of the recipient. Only one of these values is required; multiple values are not accepted.
  """)
model driveRecipient {
  @doc("The unique identifier for the recipient in the directory.")
  objectId?: string;

  @doc("When the recipient is referenced by objectId this annotation is used to differentiate `user` and `group` recipients.")
  `@libre.graph.recipient.type`?: string = "user";
}

model driveItemCreateLink {
  type?: sharingLinkType;

  @doc("Optional. A String with format of yyyy-MM-ddTHH:mm:ssZ of DateTime indicates the expiration time of the permission.")
  expirationDateTime?: utcDateTime;

  @doc("Optional.The password of the sharing link that is set by the creator.")
  password?: string;

  @doc("Provides a user-visible display name of the link. Optional. Libregraph only.")
  displayName?: string;

  @doc("The quicklink property can be assigned to only one link per resource. A quicklink can be used in the clients to provide a one-click copy to clipboard action. Optional. Libregraph only.")
  `@libre.graph.quickLink`?: boolean;
}

model driveItemInvite {
  @doc("A collection of recipients who will receive access and the sharing invitation. Currently, only internal users or groups are supported.")
  recipients?: driveRecipient[];

  @doc("Specifies the roles that are to be granted to the recipients of the sharing invitation.")
  roles?: string[];

  @doc("Specifies the actions that are to be granted to the recipients of the sharing invitation, in effect creating a custom role.")
  `@libre.graph.permissions.actions`?: string[];

  @doc("Specifies the dateTime after which the permission expires.")
  expirationDateTime?: utcDateTime;
}

@doc("The sharing link password which should be set.")
model sharingLinkPassword {
  @doc("Password. It may require a password policy.")
  password?: string;
}

// =============================================================================
// Permission query parameters / path params (drive-mounted permission routes only)
// =============================================================================

@friendlyName("permissionsFilter")
model PermissionsFilter {
  @query
  @doc("Filter items by property values. By default all permissions are returned and the available sharing roles are limited to normal users. To get a list of sharing roles applicable to federated users use the example $select query and combine it with $filter to omit the list of permissions.")
  `$filter`?: string;
}

@friendlyName("permissionsSelect")
model PermissionsSelect {
  @TypeSpec.JsonSchema.uniqueItems
  @query(#{ explode: false })
  @doc("Select properties to be returned. By default all properties are returned. Select the roles property to fetch the available sharing roles without resolving all the permissions. Combine this with the $filter parameter to fetch the actions applicable to federated users.")
  `$select`?: ("@libre.graph.permissions.actions.allowedValues" | "@libre.graph.permissions.roles.allowedValues" | "value")[];
}

model PermIdPath {
  @path
  @extension("x-ms-docs-key-type", "permission")
  @doc("key: id of permission")
  `perm-id`: string;
}

// =============================================================================
// Permission response wrappers
// =============================================================================

@doc("Retrieved resource")
model PermissionsCollectionRetrieved {
  @statusCode _: 200;
  @body body: permissionsWithAllowedValuesResponse;
}

@friendlyName("CollectionOfPermissionsWithAllowedValues")
model permissionsWithAllowedValuesResponse {
  @doc("A list of role definitions that can be chosen for the resource.")
  `@libre.graph.permissions.roles.allowedValues`?: unifiedRoleDefinition[];

  @doc("""
    A list of actions that can be chosen for a custom role.

    Following the CS3 API we can represent the CS3 permissions by mapping them to driveItem properties or relations like this:
    | [CS3 ResourcePermission](https://cs3org.github.io/cs3apis/#cs3.storage.provider.v1beta1.ResourcePermissions) | action | comment |
    | ------------------------------------------------------------------------------------------------------------ | ------ | ------- |
    | `stat` | `libre.graph/driveItem/basic/read` | `basic` because it does not include versions or trashed items |
    | `get_quota` | `libre.graph/driveItem/quota/read` | read only the `quota` property |
    | `get_path` | `libre.graph/driveItem/path/read` | read only the `path` property |
    | `move` | `libre.graph/driveItem/path/update` | allows updating the `path` property of a CS3 resource |
    | `delete` | `libre.graph/driveItem/standard/delete` | `standard` because deleting is a common update operation |
    | `list_container` | `libre.graph/driveItem/children/read` | |
    | `create_container` | `libre.graph/driveItem/children/create` | |
    | `initiate_file_download` | `libre.graph/driveItem/content/read` | `content` is the property read when initiating a download |
    | `initiate_file_upload` | `libre.graph/driveItem/upload/create` | `uploads` are a separate property. postprocessing creates the `content` |
    | `add_grant` | `libre.graph/driveItem/permissions/create` | |
    | `list_grant` | `libre.graph/driveItem/permissions/read` | |
    | `update_grant` | `libre.graph/driveItem/permissions/update` | |
    | `remove_grant` | `libre.graph/driveItem/permissions/delete` | |
    | `deny_grant` | `libre.graph/driveItem/permissions/deny` | uses a non CRUD action `deny` |
    | `list_file_versions` | `libre.graph/driveItem/versions/read` | `versions` is a `driveItemVersion` collection |
    | `restore_file_version` | `libre.graph/driveItem/versions/update` | the only `update` action is restore |
    | `list_recycle` | `libre.graph/driveItem/deleted/read` | reading a driveItem `deleted` property implies listing |
    | `restore_recycle_item` | `libre.graph/driveItem/deleted/update` | the only `update` action is restore |
    | `purge_recycle` | `libre.graph/driveItem/deleted/delete` | allows purging deleted `driveItems` |
    """)
  `@libre.graph.permissions.actions.allowedValues`?: string[];

  value?: permission[];

  @doc("The total number of permissions available, only present if the `count` query parameter is set to true.")
  `@odata.count`?: int32;
}

@doc("Response")
model CreateLinkResponse {
  @statusCode _: 200;
  @body body: permission;
}

@doc("""
  Multi-Status. The operation has completed but at least one sub-operation
  did not succeed — typically returned by `invite` when the call carries
  multiple recipients and only some of them could be granted access. The
  body shape is intentionally unspecified for now; clients should treat
  `207` as a soft failure and inspect server-side logs or the resource
  state to determine which sub-operations succeeded.
  """)
model PartialSuccess {
  @statusCode _: 207;
}

@doc("Response")
model InviteResponse {
  @statusCode _: 200;
  @body body: invitePermissionsResponse;
}

alias invitePermissionsResponse = Collection<permission, "CollectionOfPermissions">;

@doc("Bad request")
@error
model InviteBadRequest {
  @statusCode _: 400;
  @body body: OdataError;
}

@doc("Retrieved resource")
model PermissionRetrieved {
  @statusCode _: 200;
  @body body: permission;
}

@doc("Updated permission")
model PermissionUpdated {
  @statusCode _: 200;
  @body body: permission;
}
