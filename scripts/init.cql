-- First create the keyspace
CREATE KEYSPACE IF NOT EXISTS application_keyspace
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '3'}
AND durable_writes = true;

USE application_keyspace;

-- Health table
CREATE TABLE IF NOT EXISTS "health" (
    "id" TEXT PRIMARY KEY,
    "healthy" BOOLEAN
);

INSERT INTO "health" ("id", "healthy") VALUES ('singleton', true);

-- Main Emails Table
CREATE TABLE IF NOT EXISTS "emails" (
    "userId" TEXT,           
    "createdAt" TIMESTAMP,     
    "id" TEXT,                
    "campaignId" TEXT,
    "sequenceId" TEXT,
    "threadId" TEXT,
    "mailbox" TEXT,
    "sender" TEXT,
    "receiver" TEXT,
    "forwardThread" TEXT,
    "originalUser" TEXT,
    "originalMailbox" TEXT,
    "originalThreadId" TEXT,
    "businessEmail" TEXT,
    "content" TEXT,
    "reply" BOOLEAN,
    PRIMARY KEY ("userId", "createdAt", "id")
) WITH CLUSTERING ORDER BY ("createdAt" DESC);

CREATE TABLE IF NOT EXISTS "email_lookup" (
    "id" TEXT PRIMARY KEY,
    "userId" TEXT,
    "sequenceId" TEXT,
    "threadId" TEXT,
    "createdAt" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "emails_by_campaign" (
    "campaignId" TEXT,
    "createdAt" TIMESTAMP,
    "id" TEXT,
    "sequenceId" TEXT,
    "threadId" TEXT,
    "userId" TEXT,
    "sender" TEXT,
    "receiver" TEXT,
    "content" TEXT,
    PRIMARY KEY ("campaignId", "createdAt", "id")
) WITH CLUSTERING ORDER BY ("createdAt" DESC);

CREATE TABLE IF NOT EXISTS "emails_by_user" (
    "userId" TEXT,
    "createdAt" TIMESTAMP,
    "id" TEXT,
    "sequenceId" TEXT,
    "threadId" TEXT,
    "campaignId" TEXT,
    "mailbox" TEXT,
    "sender" TEXT,
    "receiver" TEXT,
    "content" TEXT,
    PRIMARY KEY ("userId", "createdAt", "id")
) WITH CLUSTERING ORDER BY ("createdAt" DESC);

-- Replies Table
CREATE TABLE IF NOT EXISTS "replies" (
    "id" TEXT PRIMARY KEY,
    "campaignId" TEXT,
    "threadId" TEXT,
    "createdAt" TIMESTAMP,
    "mailbox" TEXT,
    "userId" TEXT,
    "sender" TEXT,
    "receiver" TEXT,
    "content" TEXT,
    "analysis" TEXT
);

CREATE TABLE IF NOT EXISTS "replies_by_campaign" (
    "campaignId" TEXT,
    "createdAt" TIMESTAMP,
    "id" TEXT,
    "threadId" TEXT,
    "userId" TEXT,
    "sender" TEXT,
    "receiver" TEXT,
    "content" TEXT,
    "analysis" TEXT,
    PRIMARY KEY ("campaignId", "createdAt", "id")
) WITH CLUSTERING ORDER BY ("createdAt" DESC);

CREATE TABLE IF NOT EXISTS "replies_by_receiver" (
    "receiver" TEXT,
    "createdAt" TIMESTAMP,
    "id" TEXT,
    "threadId" TEXT,
    "userId" TEXT,
    "campaignId" TEXT,
    "sender" TEXT,
    "content" TEXT,
    "analysis" TEXT,
    PRIMARY KEY ("receiver", "createdAt", "id")
) WITH CLUSTERING ORDER BY ("createdAt" DESC);

-- Threads Table
CREATE TABLE IF NOT EXISTS "threads" (
    "userId" TEXT,
    "firstContact" TIMESTAMP,
    "id" TEXT,
    "campaignId" TEXT,
    "mailbox" TEXT,
    "seen" BOOLEAN,
    "archived" BOOLEAN,
    "messages" TEXT,
    "forwardThread" TEXT,
    PRIMARY KEY ("userId", "firstContact", "id")
) WITH CLUSTERING ORDER BY ("firstContact" DESC);

CREATE TABLE IF NOT EXISTS "thread_lookup" (
    "id" TEXT PRIMARY KEY,
    "userId" TEXT,
    "firstContact" TIMESTAMP
);

-- Campaigns
CREATE TABLE IF NOT EXISTS "campaigns" (
    "id" TEXT PRIMARY KEY,
    "userId" TEXT,
    "status" TEXT,
    "senderInformation" TEXT,
    "offerDetails" TEXT,
    "steps" INT,
    "listName" TEXT,
    "sent" INT,
    "lastBusiness" TEXT,
    "listSize" INT,
    "startDate" TIMESTAMP
);

CREATE MATERIALIZED VIEW IF NOT EXISTS "campaigns_by_user" AS
SELECT "userId", "id", "status", "senderInformation", "offerDetails", "steps", "listName", "sent", "lastBusiness", "listSize", "startDate"
FROM "campaigns"
WHERE "userId" IS NOT NULL
PRIMARY KEY ("userId", "id");

CREATE MATERIALIZED VIEW IF NOT EXISTS "campaigns_by_status" AS
SELECT "status", "id", "userId", "senderInformation", "offerDetails", "steps", "listName", "sent", "lastBusiness", "listSize", "startDate"
FROM "campaigns"
WHERE "status" IS NOT NULL
PRIMARY KEY ("status", "id");

-- Sequences
CREATE TABLE IF NOT EXISTS "sequences" (
    "id" TEXT PRIMARY KEY,
    "mailbox" TEXT,
    "mailboxName" TEXT,
    "business" TEXT,
    "sequence" LIST<TEXT>,
    "campaignId" TEXT,
    "steps" INT,
    "currentStep" INT,
    "status" TEXT,
    "archived" BOOLEAN,
    "scheduledDate" TIMESTAMP
);

-- Optimized schedule table with status in primary key
CREATE TABLE IF NOT EXISTS sequences_by_schedule (
    "scheduledDate" TIMESTAMP,
    "mailboxName" TEXT,
    "id" TEXT,
    "mailbox" TEXT,
    "business" TEXT,
    "sequence" LIST<TEXT>,
    "campaignId" TEXT,
    "steps" INT,
    "currentStep" INT,
    "status" TEXT,
    "archived" BOOLEAN,
    PRIMARY KEY (("status"), "scheduledDate", "id")
) WITH CLUSTERING ORDER BY ("scheduledDate" ASC);

-- Materialized view for status queries (unchanged)
CREATE MATERIALIZED VIEW IF NOT EXISTS "sequences_by_status" AS
SELECT "status", "id", "mailbox", "mailboxName", "business", "sequence", "campaignId", "steps", "currentStep", "archived", "scheduledDate"
FROM "sequences"
WHERE "status" IS NOT NULL
PRIMARY KEY ("status", "id");

-- Enhanced campaign view with all sequence data
CREATE MATERIALIZED VIEW IF NOT EXISTS "sequences_by_campaign" AS
SELECT "campaignId", "id", "mailbox", "mailboxName", "business", "sequence", "steps", "currentStep", "status", "archived", "scheduledDate"
FROM "sequences"
WHERE "campaignId" IS NOT NULL AND "id" IS NOT NULL
PRIMARY KEY ("campaignId", "id");

-- Mailboxes
CREATE TABLE IF NOT EXISTS "mailboxes" (
    "id" TEXT PRIMARY KEY,
    "name" TEXT,
    "capacities" LIST<INT>,
    "maxCapacity" INT,
    "type" TEXT,
    "createdAt" TIMESTAMP,
    "lastShift" TIMESTAMP,
    "active" BOOLEAN
);

CREATE MATERIALIZED VIEW IF NOT EXISTS "mailboxes_by_status" AS
SELECT "id", "name", "capacities", "maxCapacity", "type", "createdAt", "lastShift", "active"
FROM "mailboxes"
WHERE "active" IS NOT NULL
PRIMARY KEY ("active", "id");

-- Accounts
CREATE TABLE IF NOT EXISTS "accounts" (
    "id" TEXT PRIMARY KEY,
    "name" TEXT,
    "info" TEXT,
    "type" TEXT
);

-- Users
CREATE TABLE IF NOT EXISTS "users" (
    "id" TEXT PRIMARY KEY,
    "organizationId" TEXT,
    "name" TEXT,
    "hashed_pass" TEXT,
    "email" TEXT,
    "dailyLimit" INT,
    "forwardEmail" TEXT,
    "auth" TEXT,
    "createdAt" TIMESTAMP,
    "lastLogin" TIMESTAMP,
    "sentCount" INT,
);