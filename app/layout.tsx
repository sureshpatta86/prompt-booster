import '../styles/globals.css';
import type { Metadata } from 'next';
import { Providers } from '@/components/layout/providers';

export const metadata: Metadata = {
  title: 'Prompt Booster - AI Prompt Optimization Platform',
  description: 'Enhance your AI prompts with intelligent analysis and optimization',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className="font-sans">
        <Providers>
          {children}
        </Providers>
      </body>
    </html>
  );
}
