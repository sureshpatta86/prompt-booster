# Changelog

All notable changes to the Prompt Booster project will be documented in this file.

## [1.1.0] - 2025-07-03

### Updated
- **Next.js**: 14.2.3 → 15.0.3 (Latest stable version with improved performance)
- **React Query**: 5.35.1 → 5.59.16 (Better caching and state management)
- **Drizzle ORM**: 0.30.10 → 0.33.0 (Enhanced PostgreSQL support)
- **Drizzle Kit**: 0.21.4 → 0.26.2 (Improved migration system)
- **OpenAI**: 4.47.1 → 4.67.3 (Latest API features)
- **Zustand**: 4.5.2 → 5.0.1 (Breaking changes with improved TypeScript support)
- **TypeScript**: 5.4.5 → 5.6.3 (Latest language features)
- **ESLint**: 8.57.0 → 9.14.0 (New flat config system)
- **All Radix UI packages** to latest versions (Improved accessibility)
- **All type definitions** to latest versions

### Added
- `npm run update-packages` - Script to check and update all packages
- `npm run check-updates` - Script to check for available updates
- Updated Next.js config for v15 compatibility (remotePatterns instead of domains)

### Fixed
- Next.js 15 compatibility issues
- Drizzle Kit configuration for latest version
- Image optimization configuration

## [1.0.0] - 2025-07-03

### Added
- Initial project setup with Next.js 14, TypeScript, and Tailwind CSS
- Drizzle ORM with PostgreSQL database schema
- Authentication system with NextAuth.js
- Beautiful responsive home page
- Radix UI component system
- AI prompt analysis infrastructure
- Comprehensive documentation
- Azure deployment configuration
