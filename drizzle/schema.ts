import { pgTable, serial, text, timestamp, boolean, integer, jsonb, uniqueIndex, index } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

// Users table
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name'),
  email: text('email').notNull().unique(),
  emailVerified: timestamp('email_verified'),
  image: text('image'),
  password: text('password'),
  role: text('role', { enum: ['ADMIN', 'EDITOR', 'VIEWER'] }).default('VIEWER'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
}, (table) => ({
  emailIdx: uniqueIndex('email_idx').on(table.email),
}));

// Accounts table for OAuth
export const accounts = pgTable('accounts', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  type: text('type').notNull(),
  provider: text('provider').notNull(),
  providerAccountId: text('provider_account_id').notNull(),
  refresh_token: text('refresh_token'),
  access_token: text('access_token'),
  expires_at: integer('expires_at'),
  token_type: text('token_type'),
  scope: text('scope'),
  id_token: text('id_token'),
  session_state: text('session_state'),
}, (table) => ({
  providerIdx: index('provider_idx').on(table.provider, table.providerAccountId),
}));

// Sessions table
export const sessions = pgTable('sessions', {
  id: serial('id').primaryKey(),
  sessionToken: text('session_token').notNull().unique(),
  userId: integer('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  expires: timestamp('expires').notNull(),
});

// Verification tokens
export const verificationTokens = pgTable('verification_tokens', {
  identifier: text('identifier').notNull(),
  token: text('token').notNull(),
  expires: timestamp('expires').notNull(),
}, (table) => ({
  tokenIdx: uniqueIndex('token_idx').on(table.token),
}));

// Prompts table
export const prompts = pgTable('prompts', {
  id: serial('id').primaryKey(),
  title: text('title').notNull(),
  content: text('content').notNull(),
  description: text('description'),
  userId: integer('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  categoryId: integer('category_id').references(() => categories.id),
  isTemplate: boolean('is_template').default(false),
  isPublic: boolean('is_public').default(false),
  tags: text('tags').array(),
  metadata: jsonb('metadata'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
}, (table) => ({
  userIdx: index('prompts_user_idx').on(table.userId),
  categoryIdx: index('prompts_category_idx').on(table.categoryId),
  templateIdx: index('prompts_template_idx').on(table.isTemplate),
}));

// Categories table
export const categories = pgTable('categories', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  description: text('description'),
  color: text('color'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

// Prompt versions table for version control
export const promptVersions = pgTable('prompt_versions', {
  id: serial('id').primaryKey(),
  promptId: integer('prompt_id').notNull().references(() => prompts.id, { onDelete: 'cascade' }),
  content: text('content').notNull(),
  version: integer('version').notNull(),
  changeLog: text('change_log'),
  createdAt: timestamp('created_at').defaultNow(),
  createdBy: integer('created_by').notNull().references(() => users.id),
}, (table) => ({
  promptVersionIdx: index('prompt_version_idx').on(table.promptId, table.version),
}));

// Prompt analysis results
export const promptAnalysis = pgTable('prompt_analysis', {
  id: serial('id').primaryKey(),
  promptId: integer('prompt_id').notNull().references(() => prompts.id, { onDelete: 'cascade' }),
  versionId: integer('version_id').references(() => promptVersions.id),
  clarityScore: integer('clarity_score'),
  completenessScore: integer('completeness_score'),
  biasScore: integer('bias_score'),
  toneAnalysis: jsonb('tone_analysis'),
  suggestions: jsonb('suggestions'),
  analysisData: jsonb('analysis_data'),
  createdAt: timestamp('created_at').defaultNow(),
}, (table) => ({
  promptAnalysisIdx: index('prompt_analysis_idx').on(table.promptId),
}));

// Workspaces for team collaboration
export const workspaces = pgTable('workspaces', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  description: text('description'),
  ownerId: integer('owner_id').notNull().references(() => users.id),
  settings: jsonb('settings'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

// Workspace members
export const workspaceMembers = pgTable('workspace_members', {
  id: serial('id').primaryKey(),
  workspaceId: integer('workspace_id').notNull().references(() => workspaces.id, { onDelete: 'cascade' }),
  userId: integer('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  role: text('role', { enum: ['ADMIN', 'EDITOR', 'VIEWER'] }).default('VIEWER'),
  createdAt: timestamp('created_at').defaultNow(),
}, (table) => ({
  workspaceMemberIdx: uniqueIndex('workspace_member_idx').on(table.workspaceId, table.userId),
}));

// Shared links
export const sharedLinks = pgTable('shared_links', {
  id: serial('id').primaryKey(),
  promptId: integer('prompt_id').notNull().references(() => prompts.id, { onDelete: 'cascade' }),
  token: text('token').notNull().unique(),
  expiresAt: timestamp('expires_at'),
  isActive: boolean('is_active').default(true),
  createdBy: integer('created_by').notNull().references(() => users.id),
  createdAt: timestamp('created_at').defaultNow(),
}, (table) => ({
  tokenIdx: uniqueIndex('shared_link_token_idx').on(table.token),
}));

// Relations
export const usersRelations = relations(users, ({ many }) => ({
  accounts: many(accounts),
  sessions: many(sessions),
  prompts: many(prompts),
  promptVersions: many(promptVersions),
  workspaces: many(workspaces),
  workspaceMembers: many(workspaceMembers),
  sharedLinks: many(sharedLinks),
}));

export const accountsRelations = relations(accounts, ({ one }) => ({
  user: one(users, {
    fields: [accounts.userId],
    references: [users.id],
  }),
}));

export const sessionsRelations = relations(sessions, ({ one }) => ({
  user: one(users, {
    fields: [sessions.userId],
    references: [users.id],
  }),
}));

export const promptsRelations = relations(prompts, ({ one, many }) => ({
  user: one(users, {
    fields: [prompts.userId],
    references: [users.id],
  }),
  category: one(categories, {
    fields: [prompts.categoryId],
    references: [categories.id],
  }),
  versions: many(promptVersions),
  analysis: many(promptAnalysis),
  sharedLinks: many(sharedLinks),
}));

export const categoriesRelations = relations(categories, ({ many }) => ({
  prompts: many(prompts),
}));

export const promptVersionsRelations = relations(promptVersions, ({ one, many }) => ({
  prompt: one(prompts, {
    fields: [promptVersions.promptId],
    references: [prompts.id],
  }),
  createdByUser: one(users, {
    fields: [promptVersions.createdBy],
    references: [users.id],
  }),
  analysis: many(promptAnalysis),
}));

export const promptAnalysisRelations = relations(promptAnalysis, ({ one }) => ({
  prompt: one(prompts, {
    fields: [promptAnalysis.promptId],
    references: [prompts.id],
  }),
  version: one(promptVersions, {
    fields: [promptAnalysis.versionId],
    references: [promptVersions.id],
  }),
}));

export const workspacesRelations = relations(workspaces, ({ one, many }) => ({
  owner: one(users, {
    fields: [workspaces.ownerId],
    references: [users.id],
  }),
  members: many(workspaceMembers),
}));

export const workspaceMembersRelations = relations(workspaceMembers, ({ one }) => ({
  workspace: one(workspaces, {
    fields: [workspaceMembers.workspaceId],
    references: [workspaces.id],
  }),
  user: one(users, {
    fields: [workspaceMembers.userId],
    references: [users.id],
  }),
}));

export const sharedLinksRelations = relations(sharedLinks, ({ one }) => ({
  prompt: one(prompts, {
    fields: [sharedLinks.promptId],
    references: [prompts.id],
  }),
  createdByUser: one(users, {
    fields: [sharedLinks.createdBy],
    references: [users.id],
  }),
}));
