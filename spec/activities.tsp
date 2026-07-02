import "@typespec/http";
import "@typespec/openapi";

import "./common.models.tsp";

using Http;
using OpenAPI;

namespace LibreGraph;

@doc("Represents activity.")
model activity {
  @doc("Activity ID.")
  id: string;

  times: activityTimes;
  template: activityTemplate;
}

model activityTimes {
  @doc("Timestamp of the activity.")
  recordedTime: utcDateTime;
}

model activityTemplate {
  @doc("Activity description.")
  message: string;

  @doc("Activity description variables.")
  variables?: Record<unknown>;
}

@doc("Found activities")
model ActivitiesFound {
  @statusCode _: 200;
  @body body: activitiesResponse;
}

alias activitiesResponse = Collection<activity, "CollectionOfActivities">;

@route("/v1beta1/extensions/org.libregraph/activities")
namespace Activities {

  @summary("Get activities")
  @operationId("GetActivities")
  @tag("activities")
  @opExample(
    #{
      returnType: #{
        _: 200,
        body: #{
          value: #[
            #{
              id: "ee1130a7-1130-43ed-b40d-9f54adc5d927",
              template: #{
                message: "{user} created {resource}",
                variables: #{
                  user: #{ name: "Albert Einstein", id: "..." },
                  resource: #{ name: "Documents", id: "..." },
                },
              },
              times: #{ recordedTime: utcDateTime.fromISO("2023-09-04T10:42:00Z") },
            },
          ],
        },
      },
    },
    #{ title: "item activities" }
  )
  @get
  op getActivities(
    @query
    @example("resourceid:a0ca6a90-a365-4782-871e-d44447bbc668$a0ca6a90-a365-4782-871e-d44447bbc668 depth:2")
    kql?: string,
  ): ActivitiesFound | OdataError;
}
