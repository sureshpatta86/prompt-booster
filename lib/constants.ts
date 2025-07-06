/**
 * Application Constants
 * All static constants used throughout the application
 */

// Routes
export const ROUTES = {
  HOME: '/',
  AUTH: {
    SIGNIN: '/signin',
    SIGNUP: '/signup',
    VERIFY: '/verify',
  },
  DASHBOARD: {
    HOME: '/dashboard',
    PROMPTS: '/dashboard/prompts',
    TEMPLATES: '/dashboard/templates',
    ANALYSIS: '/dashboard/analysis',
    SETTINGS: '/dashboard/settings',
  },
  API: {
    AUTH: '/api/auth',
    PROMPTS: '/api/prompts',
    ANALYSIS: '/api/analysis',
    TEMPLATES: '/api/templates',
    HEALTH: '/api/health',
  },
} as const;

// HTTP Status Codes
export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  UNPROCESSABLE_ENTITY: 422,
  TOO_MANY_REQUESTS: 429,
  INTERNAL_SERVER_ERROR: 500,
  BAD_GATEWAY: 502,
  SERVICE_UNAVAILABLE: 503,
} as const;

// Error Messages
export const ERROR_MESSAGES = {
  GENERIC: 'Something went wrong. Please try again.',
  NETWORK: 'Network error. Please check your connection.',
  UNAUTHORIZED: 'You are not authorized to perform this action.',
  NOT_FOUND: 'The requested resource was not found.',
  VALIDATION: 'Please check your input and try again.',
  RATE_LIMIT: 'Too many requests. Please wait and try again.',
} as const;

// Success Messages
export const SUCCESS_MESSAGES = {
  SAVED: 'Changes saved successfully!',
  CREATED: 'Created successfully!',
  DELETED: 'Deleted successfully!',
  UPDATED: 'Updated successfully!',
  COPIED: 'Copied to clipboard!',
} as const;

// Validation Rules
export const VALIDATION = {
  PASSWORD: {
    MIN_LENGTH: 8,
    MAX_LENGTH: 128,
    PATTERN: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/,
  },
  EMAIL: {
    PATTERN: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  },
  PROMPT: {
    MIN_LENGTH: 10,
    MAX_LENGTH: 5000,
  },
  TITLE: {
    MIN_LENGTH: 3,
    MAX_LENGTH: 100,
  },
} as const;

// UI Constants
export const UI = {
  DEBOUNCE_DELAY: 300,
  ANIMATION_DURATION: 200,
  TOAST_DURATION: 3000,
  SIDEBAR_WIDTH: 280,
  HEADER_HEIGHT: 64,
  MOBILE_BREAKPOINT: 768,
} as const;

// File Upload
export const FILE_UPLOAD = {
  MAX_SIZE: 5 * 1024 * 1024, // 5MB
  ALLOWED_TYPES: ['text/plain', 'application/json'],
  ALLOWED_EXTENSIONS: ['.txt', '.json', '.md'],
} as const;

// Pagination
export const PAGINATION = {
  DEFAULT_PAGE_SIZE: 20,
  MAX_PAGE_SIZE: 100,
  PAGE_SIZE_OPTIONS: [10, 20, 50, 100],
} as const;

// Analytics Events
export const ANALYTICS_EVENTS = {
  PROMPT_CREATED: 'prompt_created',
  PROMPT_ANALYZED: 'prompt_analyzed',
  TEMPLATE_USED: 'template_used',
  USER_SIGNED_UP: 'user_signed_up',
  USER_SIGNED_IN: 'user_signed_in',
} as const;

// Theme
export const THEME = {
  LIGHT: 'light',
  DARK: 'dark',
  SYSTEM: 'system',
} as const;

// Local Storage Keys
export const STORAGE_KEYS = {
  THEME: 'theme',
  SIDEBAR_COLLAPSED: 'sidebar-collapsed',
  RECENT_PROMPTS: 'recent-prompts',
  USER_PREFERENCES: 'user-preferences',
} as const;
