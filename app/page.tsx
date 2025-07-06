import { Button } from '@/components/ui/button';
import { ThemeToggle } from '@/components/theme-toggle';
import { Sparkles, Zap, Target, Shield } from 'lucide-react';

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 dark:from-gray-900 dark:to-gray-800">
      {/* Header */}
      <header className="container mx-auto px-4 py-6">
        <nav className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <Sparkles className="h-8 w-8 text-blue-600 dark:text-blue-400" />
            <span className="text-2xl font-bold text-gray-900 dark:text-white">Prompt Booster</span>
          </div>
          <div className="flex items-center space-x-4">
            <ThemeToggle />
            <Button variant="ghost">Sign In</Button>
            <Button>Get Started</Button>
          </div>
        </nav>
      </header>

      {/* Hero Section */}
      <main className="container mx-auto px-4 py-16">
        <div className="text-center max-w-4xl mx-auto">
          <h1 className="text-5xl font-bold text-gray-900 dark:text-white mb-6">
            Supercharge Your AI Prompts with{' '}
            <span className="text-blue-600 dark:text-blue-400">Intelligent Analysis</span>
          </h1>
          <p className="text-xl text-gray-600 dark:text-gray-300 mb-8 leading-relaxed">
            Transform your prompts into powerful AI instructions with our advanced optimization platform. 
            Get real-time analysis, bias detection, and clarity scoring to maximize your AI interactions.
          </p>
          <div className="flex justify-center space-x-4 mb-12">
            <Button size="lg" className="px-8 py-3">
              Start Optimizing
            </Button>
            <Button variant="outline" size="lg" className="px-8 py-3">
              View Demo
            </Button>
          </div>
        </div>

        {/* Features Grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8 mt-16">
          <div className="bg-white dark:bg-gray-800 rounded-lg p-6 shadow-lg">
            <div className="w-12 h-12 bg-blue-100 dark:bg-blue-900 rounded-lg flex items-center justify-center mb-4">
              <Zap className="h-6 w-6 text-blue-600 dark:text-blue-400" />
            </div>
            <h3 className="text-lg font-semibold mb-2 dark:text-white">Real-time Analysis</h3>
            <p className="text-gray-600 dark:text-gray-300">
              Get instant feedback on your prompts with AI-powered analysis and suggestions.
            </p>
          </div>

          <div className="bg-white dark:bg-gray-800 rounded-lg p-6 shadow-lg">
            <div className="w-12 h-12 bg-green-100 dark:bg-green-900 rounded-lg flex items-center justify-center mb-4">
              <Target className="h-6 w-6 text-green-600 dark:text-green-400" />
            </div>
            <h3 className="text-lg font-semibold mb-2 dark:text-white">Clarity Scoring</h3>
            <p className="text-gray-600 dark:text-gray-300">
              Measure prompt clarity and effectiveness with our advanced scoring system.
            </p>
          </div>

          <div className="bg-white dark:bg-gray-800 rounded-lg p-6 shadow-lg">
            <div className="w-12 h-12 bg-purple-100 dark:bg-purple-900 rounded-lg flex items-center justify-center mb-4">
              <Shield className="h-6 w-6 text-purple-600 dark:text-purple-400" />
            </div>
            <h3 className="text-lg font-semibold mb-2 dark:text-white">Bias Detection</h3>
            <p className="text-gray-600 dark:text-gray-300">
              Identify and eliminate bias in your prompts for more ethical AI interactions.
            </p>
          </div>

          <div className="bg-white dark:bg-gray-800 rounded-lg p-6 shadow-lg">
            <div className="w-12 h-12 bg-orange-100 dark:bg-orange-900 rounded-lg flex items-center justify-center mb-4">
              <Sparkles className="h-6 w-6 text-orange-600 dark:text-orange-400" />
            </div>
            <h3 className="text-lg font-semibold mb-2 dark:text-white">Template Library</h3>
            <p className="text-gray-600 dark:text-gray-300">
              Access a curated collection of high-performing prompt templates.
            </p>
          </div>
        </div>

        {/* Demo Section */}
        <div className="mt-20 bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-8">
          <h2 className="text-3xl font-bold text-center mb-8 dark:text-white">
            See Prompt Booster in Action
          </h2>
          <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-6 mb-6">
            <h3 className="text-lg font-semibold mb-3 dark:text-white">Sample Prompt:</h3>
            <div className="bg-white dark:bg-gray-600 border-2 border-dashed border-gray-300 dark:border-gray-500 rounded-lg p-4 min-h-[120px] flex items-center justify-center">
              <p className="text-gray-500 dark:text-gray-300 italic">
                &ldquo;Write a comprehensive guide that covers the essential aspects of machine learning, 
                including algorithms, data preprocessing, and model evaluation techniques.&rdquo;
              </p>
            </div>
          </div>
          
          <div className="grid md:grid-cols-3 gap-6">
            <div className="text-center">
              <div className="text-3xl font-bold text-green-600 dark:text-green-400 mb-2">85%</div>
              <div className="text-sm text-gray-600 dark:text-gray-400">Clarity Score</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-blue-600 dark:text-blue-400 mb-2">92%</div>
              <div className="text-sm text-gray-600 dark:text-gray-400">Completeness</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-purple-600 dark:text-purple-400 mb-2">Low</div>
              <div className="text-sm text-gray-600 dark:text-gray-400">Bias Risk</div>
            </div>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12 mt-20">
        <div className="container mx-auto px-4 text-center">
          <div className="flex items-center justify-center space-x-2 mb-4">
            <Sparkles className="h-6 w-6" />
            <span className="text-xl font-semibold">Prompt Booster</span>
          </div>
          <p className="text-gray-400">
            AI-powered prompt optimization platform for better results.
          </p>
        </div>
      </footer>
    </div>
  );
}
