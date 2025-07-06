# Tests Directory

This directory contains all test files organized by testing type and scope.

## 📁 Directory Structure

### 🧪 [Unit Tests](./unit/)
Tests for individual components, functions, and modules in isolation:
- [`setup.test.tsx`](./unit/setup.test.tsx) - Application setup and configuration tests

### 🔗 [Integration Tests](./integration/)
Tests for interactions between multiple components or modules:
- *Ready for integration test files*

### 🌐 [End-to-End Tests](./e2e/)
Tests for complete user workflows and application behavior:
- *Ready for E2E test files*

## 🚀 Running Tests

### All Tests
```bash
npm test                 # Run all tests
npm run test:watch       # Run tests in watch mode
npm run test:coverage    # Run tests with coverage report
```

### Specific Test Types
```bash
# Unit tests only
npm test -- tests/unit

# Integration tests only  
npm test -- tests/integration

# E2E tests only
npm test -- tests/e2e

# Specific test file
npm test -- tests/unit/setup.test.tsx
```

## 🛠️ Testing Setup

### Configuration
- **Jest**: Main testing framework
- **React Testing Library**: Component testing utilities
- **jsdom**: Browser environment simulation
- **TypeScript**: Full TypeScript support in tests

### Test Patterns
Jest automatically finds tests using these patterns:
- `tests/**/*.test.(ts|tsx|js|jsx)`
- `tests/**/*.spec.(ts|tsx|js|jsx)`
- Any file in `__tests__` folders

## 📝 Writing Tests

### Unit Test Example
```typescript
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

describe('Component Name', () => {
  it('should render correctly', () => {
    render(<Component />);
    expect(screen.getByText('Expected Text')).toBeInTheDocument();
  });
});
```

### Integration Test Example
```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { ThemeProvider } from '@/components/layout/providers';

describe('Theme Integration', () => {
  it('should toggle theme correctly', () => {
    render(
      <ThemeProvider>
        <ThemeToggle />
      </ThemeProvider>
    );
    // Test theme switching logic
  });
});
```

## 🎯 Testing Guidelines

### Unit Tests
- Test individual components in isolation
- Mock external dependencies
- Focus on component behavior and props
- Test edge cases and error conditions

### Integration Tests
- Test component interactions
- Test data flow between components
- Test hooks and context providers
- Test API integrations

### E2E Tests
- Test complete user workflows
- Test critical app functionality
- Test across different browsers/devices
- Test authentication flows

## 📊 Coverage Goals

- **Unit Tests**: 80%+ coverage for components and utilities
- **Integration Tests**: Cover critical user paths
- **E2E Tests**: Cover main application workflows

## 🔧 Testing Utils

Create reusable testing utilities in:
- `tests/utils/` - Custom test utilities
- `tests/mocks/` - Mock data and functions
- `tests/fixtures/` - Test data fixtures

---

For more information about testing in Next.js applications, see the [Next.js Testing Documentation](https://nextjs.org/docs/app/building-your-application/testing).
