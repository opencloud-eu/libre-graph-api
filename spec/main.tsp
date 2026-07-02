import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "./auth.tsp";
import "./common.models.tsp";
import "./common.templates.tsp";
import "./drives.models.tsp";
import "./drives.templates.tsp";
import "./drives.routes.tsp";
import "./permissions.models.tsp";
import "./permissions.templates.tsp";
import "./permissions.routes.tsp";
import "./me.tsp";
import "./users.tsp";
import "./groups.tsp";
import "./invitations.tsp";
import "./activities.tsp";
import "./education.tsp";
import "./applications.tsp";
import "./tags.tsp";

using Http;
using OpenAPI;

// API-level auth: an operation accepts either OpenID Connect or HTTP Basic.
// Education endpoints override this to require Bearer tokens (see
// education.tsp).
@useAuth(openId | basicAuth)
@service(#{ title: "Libre Graph API" })
@info(#{
  version: "v1.0.8",
  license: #{
    name: "Apache 2.0",
    url: "https://www.apache.org/licenses/LICENSE-2.0.html",
  },
})
@doc("Libre Graph is a free API for cloud collaboration inspired by the MS Graph API.")
@server("https://localhost:9200/graph", "OpenCloud Development Setup")
namespace LibreGraph;
