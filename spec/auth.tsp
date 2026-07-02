import "@typespec/http";
import "@typespec/openapi";

using Http;
using OpenAPI;

namespace LibreGraph;

@doc("HTTP Basic Authentication (discouraged for production environments)")
model basicAuth {
  type: AuthType.http;
  scheme: "basic";
}

@extension("bearerFormat", "plain")
model bearerAuth {
  type: AuthType.http;
  scheme: "bearer";
}

model openId {
  type: AuthType.openIdConnect;
  openIdConnectUrl: "https://cloud.rolling.opencloud.rocks/.well-known/openid-configuration";
}
