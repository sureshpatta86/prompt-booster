# Prompt Booster

AI-powered prompt optimization platform built with Next.js 15, Drizzle ORM, and TypeScript.

## Features

- 🚀 **Real-time Prompt Analysis** - Get instant feedback on your AI prompts
- 🎯 **Clarity Scoring** - Measure prompt effectiveness with advanced algorithms
- 🛡️ **Bias Detection** - Identify and eliminate bias in your prompts
- 📚 **Template Library** - Access curated high-performing prompt templates
- 👥 **Team Collaboration** - Work together on prompt optimization
- 🔐 **Secure Authentication** - OAuth 2.0 with role-based access control

## Tech Stack

### Frontend
- **Next.js 15** - React framework with App Router
- **TypeScript** - Type-safe development
- **Tailwind CSS** - Utility-first styling
- **Radix UI** - Accessible component primitives
- **Lucide React** - Beautiful icons
- **Monaco Editor** - Advanced code editor for prompts

### Backend
- **Drizzle ORM** - Type-safe database toolkit
- **PostgreSQL** - Production database
- **NextAuth.js** - Authentication solution
- **OpenAI API** - AI-powered prompt analysis
- **Redis** - Caching and session storage

### DevOps
- **Docker** - Containerization
- **GitHub Actions** - CI/CD pipeline
- **Azure Container Apps** - Production hosting

## Getting Started

### Prerequisites

- Node.js 20.0.0 or higher
- PostgreSQL database
- Redis (optional, for caching)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd prompt-booster
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env.local
   # Or use the automated setup script
   ./scripts/setup/setup-secrets.sh
   ```
   
   Update the following variables in `.env.local`:
   - `DATABASE_URL` - Your PostgreSQL connection string
   - `NEXTAUTH_SECRET` - Random secret for NextAuth.js
   - `OPENAI_API_KEY` - Your OpenAI API key

4. **Set up the database**
   ```bash
   # Generate database migrations
   npm run db:generate
   
   # Apply migrations
   npm run db:migrate
   
   # Seed the database with initial data
   npm run db:seed
   ```

5. **Start the development server**
   ```bash
   npm run dev
   ```

   Open [http://localhost:3000](http://localhost:3000) in your browser.

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint
- `npm run type-check` - Run TypeScript type checking
- `npm run test` - Run tests
- `npm run db:generate` - Generate database migrations
- `npm run db:migrate` - Apply database migrations
- `npm run db:studio` - Open Drizzle Studio
- `npm run db:seed` - Seed database with initial data

## Project Structure

```
├── app/                    # Next.js App Router pages
├── components/            # Reusable UI components
│   └── ui/               # Base UI components
├── drizzle/              # Database schema and migrations
│   ├── migrations/       # Database migration files
│   ├── schema.ts         # Database schema definition
│   ├── db.ts            # Database connection
│   └── seed.ts          # Database seeding script
├── hooks/                # Custom React hooks
├── lib/                  # Utility functions and configurations
├── public/               # Static assets
└── types/                # TypeScript type definitions
```

## Database Schema

The application uses PostgreSQL with the following main entities:

- **Users** - User accounts and authentication
- **Prompts** - User-created prompts and templates
- **Categories** - Prompt categorization system
- **PromptVersions** - Version control for prompts
- **PromptAnalysis** - AI analysis results
- **Workspaces** - Team collaboration spaces
- **SharedLinks** - Secure prompt sharing

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Documentation

For detailed documentation, see the [docs](./docs/) directory:

- 📁 **[Setup & Configuration](./docs/setup/)** - Environment setup and configuration guides
- 📁 **[Deployment](./docs/deployment/)** - Production deployment guides and troubleshooting
- 📁 **[Development](./docs/development/)** - Development guides and project architecture

Quick links:
- [Documentation Index](./docs/README.md) - Complete documentation overview
- [Deployment Guide](./docs/deployment/DEPLOYMENT_GUIDE.md) - Deploy to production
- [Setup Guide](./docs/setup/GITHUB_SETUP.md) - Get started with development

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@promptbooster.com or join our Discord community.
