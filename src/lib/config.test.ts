import { afterEach, describe, expect, it } from "vitest";
import { getConfig, resolveFirestoreDatabaseId } from "@/lib/config";
import { setRequiredEnv } from "@/test/env";

describe("firestore database id", () => {
  afterEach(() => {
    setRequiredEnv();
  });

  it("requires the dedicated named database and rejects foreign IDs", () => {
    expect(resolveFirestoreDatabaseId("gconnect-mcp-all-v1")).toBe("gconnect-mcp-all-v1");
    expect(() => resolveFirestoreDatabaseId("(default)")).toThrow(/named database/);
    expect(() => resolveFirestoreDatabaseId("default")).toThrow(/named database/);
    expect(() => resolveFirestoreDatabaseId("ga4-mcp-v3")).toThrow(/gconnect-mcp-all-v1/);
    expect(() => resolveFirestoreDatabaseId("")).toThrow(/FIRESTORE_DATABASE_ID/);
    expect(() => resolveFirestoreDatabaseId("something-else")).toThrow(/gconnect-mcp-all-v1/);
  });

  it("loads FIRESTORE_DATABASE_ID from env", () => {
    setRequiredEnv();
    expect(getConfig().firestoreDatabaseId).toBe("gconnect-mcp-all-v1");
  });
});
