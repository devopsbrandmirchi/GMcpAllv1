import { beforeEach, describe, expect, it } from "vitest";
import { encryptRefreshToken } from "@/lib/crypto";
import { createMemoryAppStore } from "@/store/memory";
import { setRequiredEnv } from "@/test/env";

describe("memory store isolation", () => {
  beforeEach(() => {
    setRequiredEnv();
  });

  it("upserts the same Google identity per operator without duplicates", async () => {
    const store = createMemoryAppStore();
    const operator = await store.createOperator("a@example.com");
    const first = await store.upsertConnection({
      operatorId: operator.operatorId,
      googleSubjectId: "g1",
      encryptedRefreshToken: encryptRefreshToken("1//old"),
    });
    const second = await store.upsertConnection({
      operatorId: operator.operatorId,
      googleSubjectId: "g1",
      encryptedRefreshToken: encryptRefreshToken("1//new"),
    });
    expect(first.connectionId).toBe(second.connectionId);
    expect((await store.listConnections(operator.operatorId)).length).toBe(1);
  });
});
