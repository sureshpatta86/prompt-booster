/**
 * Environment Configuration
 * Type-safe environment variable handling

import { z } from 'zod';

const nonPlaceholderSecret = z
  .string()
  .min(1)
  .refine((value) => {
    const normalized = value.trim().toLowerCase();
    return ![
      'changeme',
      'change-me',
      'default',
      'secret',
      'password',
    ].includes(normalized);
  }, 'Must not use a placeholder secret value');

const envSchema = z.object({
  // App
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  
  // URLs
  NEXTAUTH_URL: z.string().url().optional(),
  
  DATABASE_URL: z.string().min(1),
  
  // Authentication
  NEXTAUTH_SECRET: nonPlaceholderSecret,
  
  // External APIs
  OPENAI_API_KEY: z.string().min(1),
  OPENAI_API_KEY: z.string().min(1),
  
  // Optional services
  
  // OAuth (optional)
  GITHUB_CLIENT_ID: z.string().optional(),
  GITHUB_CLIENT_SECRET: nonPlaceholderSecret.optional(),
  GOOGLE_CLIENT_ID: z.string().optional(),
  GOOGLE_CLIENT_SECRET: nonPlaceholderSecret.optional(),
});

export type Env = z.infer<typeof envSchema>;
export type Env = z.infer<typeof envSchema>;

// Validate environment variables at startup
function validateEnv(): Env {
  try {
    return envSchema.parse(process.env);
  } catch (error) {
    console.error('❌ Invalid environment variables:', error);
    process.exit(1);
  }
}

export const env = validateEnv();

// Helper to check if we're in a specific environment
export const isDevelopment = env.NODE_ENV === 'development';
export const isProduction = env.NODE_ENV === 'production';
export const isTest = env.NODE_ENV === 'test';
