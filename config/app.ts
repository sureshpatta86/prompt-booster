/**
 * Application Configuration
 * Central place for all app constants and configuration
 */

export const APP_CONFIG = {
  name: 'Prompt Booster',
  description: 'AI-powered prompt optimization platform',
  version: '1.0.0',
  url: process.env.NEXTAUTH_URL || 'http://localhost:3000',
} as const;

export const API_CONFIG = {
  baseUrl: '/api',
  endpoints: {
    auth: '/api/auth',
    prompts: '/api/prompts',
    analysis: '/api/analysis',
    templates: '/api/templates',
  },
} as const;

export const DATABASE_CONFIG = {
  url: process.env.DATABASE_URL,
  maxConnections: 10,
  ssl: process.env.NODE_ENV === 'production',
} as const;

export const REDIS_CONFIG = {
  url: process.env.REDIS_URL,
  ttl: 60 * 60, // 1 hour
} as const;

export const AI_CONFIG = {
  openai: {
    apiKey: process.env.OPENAI_API_KEY,
    model: 'gpt-4-turbo-preview',
    maxTokens: 4096,
  },
} as const;

// Feature flags
export const FEATURES = {
  analytics: true,
  collaboration: false,
  advancedAnalysis: true,
  templateLibrary: true,
} as const;

// UI Constants
export const UI_CONFIG = {
  maxPromptLength: 5000,
  defaultTheme: 'light',
  supportedLanguages: ['en', 'es', 'fr', 'de'],
  pagination: {
    defaultPageSize: 20,
    maxPageSize: 100,
  },
} as const;
