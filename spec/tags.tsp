import "@typespec/http";
import "@typespec/openapi";

import "./common.models.tsp";

using Http;
using OpenAPI;

namespace LibreGraph;

model tagAssignment {
  resourceId: string;
  tags: string[];
}

model tagUnassignment {
  resourceId: string;
  tags: string[];
}

@doc("Retrieved tags")
model TagsRetrieved {
  @statusCode _: 200;
  @body body: tagsResponse;
}

alias tagsResponse = Collection<string, "CollectionOfTags">;

@doc("Success")
model TagsOk {
  @statusCode _: 200;
}

@route("/v1.0/extensions/org.libregraph/tags")
namespace Tags {

  @summary("Get all known tags")
  @operationId("GetTags")
  @tag("tags")
  @get
  op getTags(): TagsRetrieved | OdataError;

  @summary("Assign tags to a resource")
  @operationId("AssignTags")
  @opExample(
    #{
      parameters: #{
        body: #{
          resourceId: "7f92b0a9-06ad-49dc-890f-0e0a6eb4dea6$e9f01ca3-577f-4d1d-acd4-1cc44149ac25!5fb9f87c-a317-467b-9882-eb9f171564ac",
          tags: #["tag_to_assign_1", "tag_to_assign_2"],
        },
      },
    },
    #{ title: "tags_put" }
  )
  @tag("tags")
  @put
  op assignTags(
    @body
    body: tagAssignment,
  ): TagsOk | OdataError;

  @summary("Unassign tags from a resource")
  @operationId("UnassignTags")
  @opExample(
    #{
      parameters: #{
        body: #{
          resourceId: "7f92b0a9-06ad-49dc-890f-0e0a6eb4dea6$e9f01ca3-577f-4d1d-acd4-1cc44149ac25!5fb9f87c-a317-467b-9882-eb9f171564ac",
          tags: #["tag_to_unassign_1", "tag_to_unassign_2"],
        },
      },
    },
    #{ title: "tags_delete" }
  )
  @tag("tags")
  @delete
  op unassignTags(
    @body
    body: tagUnassignment,
  ): TagsOk | OdataError;
}
