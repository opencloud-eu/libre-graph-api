import "@typespec/http";
import "@typespec/openapi";

import "./common.models.tsp";

using Http;
using OpenAPI;

namespace LibreGraph;

@doc("Represents an email address.")
model emailAddress {
  @doc("The email address.")
  address?: string;

  @doc("The name associated with the email address.")
  name?: string;
}

@doc("Represents a recipient of an invitation.")
model recipient {
  @doc("The email address of the recipient.")
  emailAddress?: emailAddress;
}

@doc("Additional information about the invitation message.")
model invitedUserMessageInfo {
  @doc("Additional recipients who will receive a copy of the invitation message.")
  ccRecipients?: recipient[];

  @doc("The customized message body that will be included in the invitation message.")
  customizedMessageBody?: string;

  @doc("The language of the invitation message.")
  messageLanguage?: string;
}

@doc("Represents an invitation to a drive item.")
model invitation {
  @doc("The display name of the user being invited.")
  invitedUserDisplayName?: string;

  @doc("The email address of the user being invited. Required.")
  invitedUserEmailAddress?: string;

  @doc("Additional information about the invitation message.")
  invitedUserMessageInfo?: invitedUserMessageInfo;

  @doc("Indicates whether an invitation message should be sent to the user.")
  sendInvitationMessage?: boolean;

  @doc("The URL to which the user is redirected after accepting the invitation. Required.")
  inviteRedirectUrl?: string;

  @extension("readOnly", true)
  @doc("The URL that the user can use to redeem the invitation. Read-only.")
  inviteRedeemUrl?: string;

  @extension("readOnly", true)
  @doc("The status of the invitation. Read-only.")
  status?: string;

  @extension("readOnly", true)
  @doc("The user object of the invited user. Read-only.")
  invitedUser?: userResource;

  @doc("The type of user being invited.")
  invitedUserType?: string;
}

alias invitationsResponse = Collection<invitation, "CollectionOfInvitations">;

model InvitationIdPath {
  @path
  @doc("key: id of invitation")
  `invitation-id`: string;
}

@route("/v1.0/invitations")
namespace Invitations {

  @summary("Create a new invitation")
  @operationId("CreateInvitation")
  @tag("invitations")
  op createInvitation is LibreGraphOps.createResource<invitation, Created<invitation, "Invitation created successfully">, {}, "New invitation">;

  @summary("Get a list of invitations")
  @operationId("ListInvitations")
  @tag("invitations")
  op listInvitations is LibreGraphOps.listCollection<Retrieved<invitationsResponse, "Retrieved invitations">>;
}

@route("/v1.0/invitations/{invitation-id}")
namespace Invitation {

  @summary("Get an invitation by key")
  @operationId("GetInvitation")
  @tag("invitations")
  op getInvitation is LibreGraphOps.getResource<InvitationIdPath, Retrieved<invitation, "Retrieved invitation">>;
}
