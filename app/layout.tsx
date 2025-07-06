import './globals.css';
import type { Metadata } from 'next';

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
    <html lang="en">
      <body className="font-sans">
        {children}
      </body>
    </html>
  );
}
