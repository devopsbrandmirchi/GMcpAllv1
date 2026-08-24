# Google Ads

Official REST API version: **v25** (`src/products/google-ads/api/version.ts`).

There is no official Node.js client. This app uses `google-auth-library` plus `fetch`.

## Credentials

Every Ads call sends:

- `Authorization: Bearer` from the resolved Google connection
- `developer-token` from `GOOGLE_ADS_DEVELOPER_TOKEN` (application secret)
- `login-customer-id` only when the customer is reached through a manager

The developer token is never logged or returned to Claude.

## Discovery

1. `customers:listAccessibleCustomers`
2. `CustomerClient` GAQL recursion from each accessible manager
3. Persist `ads_customers` and `ads_hierarchy_edges` scoped to `(operatorId, connectionId)`

## login-customer-id

- Directly accessible customer: header omitted
- Client under an MCC: header set to the authorized manager
- Same customer in multiple hierarchies: shortest path, then lowest manager ID

Customer IDs are normalized by stripping hyphens (`123-456-7890` → `1234567890`).

## Tools

`ads_list_accessible_accounts`, `ads_get_account_hierarchy`, `ads_get_account`, `ads_run_query`, `ads_campaigns`, `ads_ad_groups`, `ads_ads`, `ads_campaign_performance`.

`ads_run_query` accepts SELECT GAQL only. Mutations are rejected.
