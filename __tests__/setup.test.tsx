/**
 * @jest-environment jsdom
 */
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

// Basic test to ensure Jest is working
describe('Application Setup', () => {
  it('should have Jest configured correctly', () => {
    expect(true).toBe(true);
  });

  it('should have testing environment set up', () => {
    expect(typeof window).toBe('object');
    expect(typeof document).toBe('object');
  });

  it('should have environment variables available', () => {
    expect(process.env.NODE_ENV).toBeDefined();
  });
});

// Example component test (commented out until we have actual components to test)
/*
describe('Home Page', () => {
  it('renders the main heading', () => {
    render(<HomePage />);
    
    const heading = screen.getByRole('heading', {
      name: /prompt booster/i,
    });

    expect(heading).toBeInTheDocument();
  });
});
*/
