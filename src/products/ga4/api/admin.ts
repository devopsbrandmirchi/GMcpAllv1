import { v1beta } from "@google-analytics/admin";
import type { OAuth2Client } from "google-auth-library";
import { mapGoogleError } from "@/lib/errors";
import { normalizePropertyId } from "@/lib/property-id";
import type { DiscoveredAccount, DiscoveredProperty } from "@/store/types";

export interface Ga4DiscoveryResult {
  accounts: DiscoveredAccount[];
  properties: DiscoveredProperty[];
}

export function createAdminClient(auth: OAuth2Client): v1beta.AnalyticsAdminServiceClient {
  return new v1beta.AnalyticsAdminServiceClient({
    authClient: auth as never,
  });
}

export async function discoverGa4Resources(
  auth: OAuth2Client,
  clientFactory: (
    authClient: OAuth2Client,
  ) => v1beta.AnalyticsAdminServiceClient = createAdminClient,
): Promise<Ga4DiscoveryResult> {
  try {
    const client = clientFactory(auth);
    const accounts = new Map<string, DiscoveredAccount>();
    const properties: DiscoveredProperty[] = [];

    for await (const summary of client.listAccountSummariesAsync()) {
      const ga4AccountId = summary.account?.replace(/^accounts\//, "") || summary.name || "";
      const accountName = summary.displayName ?? "Untitled account";
      if (ga4AccountId) {
        accounts.set(ga4AccountId, {
          ga4AccountId,
          displayName: accountName,
        });
      }

      for (const property of summary.propertySummaries ?? []) {
        if (!property.property) {
          continue;
        }
        properties.push({
          ga4AccountId,
          propertyId: normalizePropertyId(property.property),
          displayName: property.displayName ?? "Untitled property",
          propertyType: String(property.propertyType ?? "PROPERTY_TYPE_ORDINARY"),
        });
      }
    }

    return {
      accounts: [...accounts.values()],
      properties,
    };
  } catch (error) {
    throw mapGoogleError(error, "ga4");
  }
}
