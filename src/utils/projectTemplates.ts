import type { ProjectTemplate } from '../types/projectBuilder';

export const PROJECT_TEMPLATES: ProjectTemplate[] = [
  {
    id: 'react-vite',
    name: 'React + Vite',
    description: 'Modern React app with Vite, TypeScript, and Tailwind CSS',
    icon: '⚛️',
    installCmd: 'npm',
    buildCmd: 'npm run build',
    devCmd: 'npm run dev',
    testCmd: 'npm run test',
    lintCmd: 'npm run lint',
    files: [
      {
        path: 'package.json',
        content: `{
  "name": "{{name}}",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "preview": "vite preview",
    "lint": "eslint .",
    "test": "vitest"
  },
  "dependencies": {
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  },
  "devDependencies": {
    "@eslint/js": "^9.17.0",
    "@types/react": "^19.0.2",
    "@types/react-dom": "^19.0.2",
    "@vitejs/plugin-react": "^4.3.4",
    "eslint": "^9.17.0",
    "eslint-plugin-react-hooks": "^5.0.0",
    "globals": "^15.14.0",
    "typescript": "~5.7.2",
    "typescript-eslint": "^8.18.2",
    "vite": "^6.0.5",
    "vitest": "^3.0.4",
    "tailwindcss": "^4.0.0",
    "@tailwindcss/vite": "^4.0.0"
  }
}`,
      },
      {
        path: 'tsconfig.json',
        content: `{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedSideEffectImports": true
  },
  "include": ["src"]
}`,
      },
      {
        path: 'vite.config.ts',
        content: `import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [react(), tailwindcss()],
})`,
      },
      {
        path: 'src/main.tsx',
        content: `import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)`,
      },
      {
        path: 'src/index.css',
        content: `@import "tailwindcss";`,
      },
      {
        path: 'src/App.tsx',
        content: `function App() {
  return (
    <div className="min-h-screen bg-gray-900 text-white flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-4xl font-bold mb-4">{{name}}</h1>
        <p className="text-gray-400">Built with Agent Office</p>
      </div>
    </div>
  )
}

export default App`,
      },
      {
        path: 'index.html',
        content: `<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>{{name}}</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>`,
      },
    ],
  },
  {
    id: 'nextjs',
    name: 'Next.js',
    description: 'Full-stack React framework with SSR, API routes, and file-based routing',
    icon: '▲',
    installCmd: 'npm',
    buildCmd: 'npm run build',
    devCmd: 'npm run dev',
    testCmd: 'npm run test',
    lintCmd: 'npm run lint',
    files: [
      {
        path: 'package.json',
        content: `{
  "name": "{{name}}",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "test": "vitest"
  },
  "dependencies": {
    "next": "^15.1.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  },
  "devDependencies": {
    "@types/node": "^22.10.0",
    "@types/react": "^19.0.2",
    "@types/react-dom": "^19.0.2",
    "typescript": "^5.7.2",
    "vitest": "^3.0.4"
  }
}`,
      },
      {
        path: 'tsconfig.json',
        content: `{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}`,
      },
      {
        path: 'next.config.ts',
        content: `import type { NextConfig } from 'next'

const nextConfig: NextConfig = {}

export default nextConfig`,
      },
      {
        path: 'src/app/layout.tsx',
        content: `import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: '{{name}}',
  description: 'Built with Agent Office',
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}`,
      },
      {
        path: 'src/app/globals.css',
        content: `@import "tailwindcss";`,
      },
      {
        path: 'src/app/page.tsx',
        content: `export default function Home() {
  return (
    <div className="min-h-screen bg-gray-900 text-white flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-4xl font-bold mb-4">{{name}}</h1>
        <p className="text-gray-400">Built with Agent Office</p>
      </div>
    </div>
  )
}`,
      },
    ],
  },
  {
    id: 'fullstack',
    name: 'Full-Stack (React + Express)',
    description: 'Complete full-stack app with React frontend and Express.js backend',
    icon: '🔧',
    installCmd: 'npm',
    buildCmd: 'npm run build',
    devCmd: 'npm run dev',
    testCmd: 'npm run test',
    lintCmd: 'npm run lint',
    files: [
      {
        path: 'package.json',
        content: `{
  "name": "{{name}}",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "concurrently \\"npm run dev:server\\" \\"npm run dev:client\\"",
    "dev:server": "tsx watch server/index.ts",
    "dev:client": "vite",
    "build": "tsc -b && vite build",
    "start": "node dist/server/index.js",
    "lint": "eslint .",
    "test": "vitest"
  },
  "dependencies": {
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "express": "^4.21.0",
    "cors": "^2.8.5"
  },
  "devDependencies": {
    "@types/express": "^5.0.0",
    "@types/cors": "^2.8.17",
    "@types/react": "^19.0.2",
    "@types/react-dom": "^19.0.2",
    "@vitejs/plugin-react": "^4.3.4",
    "concurrently": "^9.1.0",
    "tsx": "^4.19.0",
    "typescript": "~5.7.2",
    "vite": "^6.0.5",
    "vitest": "^3.0.4"
  }
}`,
      },
      {
        path: 'tsconfig.json',
        content: `{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src", "server"]
}`,
      },
      {
        path: 'server/index.ts',
        content: `import express from 'express'
import cors from 'cors'

const app = express()
const PORT = process.env.PORT || 3001

app.use(cors())
app.use(express.json())

app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
})

app.listen(PORT, () => {
  console.log(\`Server running on http://localhost:\${PORT}\`)
})`,
      },
      {
        path: 'src/main.tsx',
        content: `import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)`,
      },
      {
        path: 'src/index.css',
        content: `@import "tailwindcss";`,
      },
      {
        path: 'src/App.tsx',
        content: `import { useEffect, useState } from 'react'

function App() {
  const [health, setHealth] = useState<string>('loading...')

  useEffect(() => {
    fetch('http://localhost:3001/api/health')
      .then(r => r.json())
      .then(d => setHealth(d.status))
      .catch(() => setHealth('error'))
  }, [])

  return (
    <div className="min-h-screen bg-gray-900 text-white flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-4xl font-bold mb-4">{{name}}</h1>
        <p className="text-gray-400">API Status: {health}</p>
      </div>
    </div>
  )
}

export default App`,
      },
      {
        path: 'index.html',
        content: `<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>{{name}}</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>`,
      },
      {
        path: 'vite.config.ts',
        content: `import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': 'http://localhost:3001'
    }
  }
})`,
      },
    ],
  },
  {
    id: 'blank',
    name: 'Blank Project',
    description: 'Empty project — let the AI build everything from scratch',
    icon: '📄',
    installCmd: 'npm',
    buildCmd: 'npm run build',
    devCmd: 'npm run dev',
    testCmd: 'npm run test',
    lintCmd: 'npm run lint',
    files: [],
  },
];

export function getTemplate(id: string): ProjectTemplate | undefined {
  return PROJECT_TEMPLATES.find(t => t.id === id);
}

export function scaffoldTemplate(template: ProjectTemplate, projectName: string) {
  return template.files.map(f => ({
    path: f.path,
    content: f.content.replace(/\{\{name\}\}/g, projectName),
  }));
}
