/**
 * Global Type Definitions
 * Shared types used across the application
 */

import { LucideIcon } from 'lucide-react';

// Database Models
export interface User {
  id: string;
  name: string | null;
  email: string;
  emailVerified: Date | null;
  image: string | null;
  role: UserRole;
  createdAt: Date;
  updatedAt: Date;
}

export interface Prompt {
  id: string;
  title: string;
  content: string;
  description: string | null;
  userId: string;
  categoryId: string | null;
  isTemplate: boolean;
  isPublic: boolean;
  tags: string[];
  metadata: Record<string, any> | null;
  createdAt: Date;
  updatedAt: Date;
  user: User;
  category: Category | null;
  versions: PromptVersion[];
  analyses: PromptAnalysis[];
}

export interface PromptVersion {
  id: string;
  promptId: string;
  version: number;
  content: string;
  changes: string | null;
  createdBy: string;
  createdAt: Date;
  prompt: Prompt;
  user: User;
}

export interface PromptAnalysis {
  id: string;
  promptId: string;
  analysisType: AnalysisType;
  score: number;
  feedback: string;
  suggestions: string[];
  metadata: Record<string, any> | null;
  createdAt: Date;
  prompt: Prompt;
}

export interface Category {
  id: string;
  name: string;
  description: string | null;
  color: string;
  createdAt: Date;
  updatedAt: Date;
  prompts: Prompt[];
}

// Enums
export type UserRole = 'ADMIN' | 'EDITOR' | 'VIEWER';
export type AnalysisType = 'CLARITY' | 'BIAS' | 'COMPLETENESS' | 'EFFECTIVENESS';
export type PromptStatus = 'DRAFT' | 'PUBLISHED' | 'ARCHIVED';

// API Types
export interface ApiResponse<T = any> {
  data: T;
  message?: string;
  success: boolean;
}

export interface ApiError {
  message: string;
  code?: string;
  details?: Record<string, any>;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
    totalPages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
}

// Form Types
export interface CreatePromptForm {
  title: string;
  content: string;
  description?: string;
  categoryId?: string;
  tags: string[];
  isTemplate: boolean;
  isPublic: boolean;
}

export interface UpdatePromptForm extends Partial<CreatePromptForm> {
  id: string;
}

export interface AuthForm {
  email: string;
  password: string;
}

export interface SignUpForm extends AuthForm {
  name: string;
  confirmPassword: string;
}

// UI Types
export interface NavItem {
  title: string;
  href: string;
  icon?: LucideIcon;
  badge?: string | number;
  disabled?: boolean;
  external?: boolean;
}

export interface BreadcrumbItem {
  title: string;
  href?: string;
}

export interface TableColumn<T = any> {
  key: keyof T;
  title: string;
  sortable?: boolean;
  render?: (value: any, row: T) => React.ReactNode;
}

export interface FilterOption {
  label: string;
  value: string | number;
  count?: number;
}

// Analysis Types
export interface AnalysisResult {
  type: AnalysisType;
  score: number;
  feedback: string;
  suggestions: string[];
  details: {
    strengths: string[];
    weaknesses: string[];
    recommendations: string[];
  };
}

export interface PromptMetrics {
  clarity: number;
  bias: number;
  completeness: number;
  effectiveness: number;
  overallScore: number;
}

// Search and Filter Types
export interface SearchFilters {
  query?: string;
  category?: string;
  tags?: string[];
  isTemplate?: boolean;
  isPublic?: boolean;
  userId?: string;
  dateRange?: {
    from: Date;
    to: Date;
  };
}

export interface SortOption {
  field: string;
  direction: 'asc' | 'desc';
}

// Workspace Types
export interface Workspace {
  id: string;
  name: string;
  description: string | null;
  ownerId: string;
  isPublic: boolean;
  createdAt: Date;
  updatedAt: Date;
  members: WorkspaceMember[];
}

export interface WorkspaceMember {
  id: string;
  workspaceId: string;
  userId: string;
  role: WorkspaceRole;
  joinedAt: Date;
  user: User;
  workspace: Workspace;
}

export type WorkspaceRole = 'OWNER' | 'ADMIN' | 'MEMBER' | 'VIEWER';

// Utility Types
export type WithRequired<T, K extends keyof T> = T & { [P in K]-?: T[P] };
export type WithOptional<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;
export type Nullable<T> = T | null;
export type Optional<T> = T | undefined;
