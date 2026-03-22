/**
 * Environment Configuration
 * Type-safe environment variable handling
 */

import { z } from 'zod';

const envSchema = z.object({
  // App
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  
  // URLs
  NEXTAUTH_URL: z.string().url().optional(),
  
  // Database
  DATABASE_URL: z.string().min(1),
  
  // Authentication
  NEXTAUTH_SECRET: z.string().min(1),
  
  // External APIs
  OPENAI_API_KEY: z.string().min(1),
  
  // Optional services
  REDIS_URL: z.string().optional(),
  
  // OAuth (optional)
  GITHUB_CLIENT_ID: z.string().optional(),
  GITHUB_CLIENT_SECRET: z.string().optional(),
  GOOGLE_CLIENT_ID: z.string().optional(),
  GOOGLE_CLIENT_SECRET: z.string().optional(),
});

export type Env = z.infer<typeof envSchema>;

function getRequiredSecret(name: 'NEXTAUTH_SECRET' | 'OPENAI_API_KEY'): string {
  const value = process.env[name];

  if (!value || value.trim().length === 0) {
    throw new Error(`Missing required secret environment variable: ${name}`);
  }

  const insecurePlaceholders = new Set(['changeme', 'default', 'secret', 'password', 'token']);
  if (insecurePlaceholders.has(value.trim().toLowerCase())) {
    throw new Error(`Insecure placeholder value provided for environment variable: ${name}`);
  }

  return value;
}

// Validate environment variables at startup
function validateEnv(): Env {
  try {
    return envSchema.parse({
      ...process.env,
      NEXTAUTH_SECRET: getRequiredSecret('NEXTAUTH_SECRET'),
      OPENAI_API_KEY: getRequiredSecret('OPENAI_API_KEY'),
    });
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
