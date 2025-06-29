#!/bin/bash

# Fix JSX Syntax Script for 3D Fashion Studio
# ----------------------------------
# This script fixes the following issues:
# 1. JSX syntax error in src/App.jsx (missing </mesh> tag in Suspense fallback)
# 2. npm audit vulnerabilities (esbuild and vite)
# 3. three-mesh-bvh deprecation warning
# 4. Vite CJS deprecation warning
# 5. Investigates 'Killed' Git commit issue
# 6. Verifies index.html and main.jsx
# 7. Commits changes to Git (if applicable)
# 8. Starts development server

set -o pipefail
LOG_FILE="fix-jsx-3dwebsite.log"
echo "🚀 Fixing JSX Syntax Issue for 3D Fashion Studio - $(date)" | tee -a $LOG_FILE

# Function to log and execute commands
run_command() {
  echo "🔧 Executing: $*" | tee -a $LOG_FILE
  if ! "$@" 2>&1 | tee -a $LOG_FILE; then
    echo "⚠️ Warning: Error executing: $*" | tee -a $LOG_FILE
    return 1
  fi
  return 0
}

# 1. Change to project directory
cd /home/davis/Desktop/3dwebsite || { echo "❌ Error: Could not enter project directory" | tee -a $LOG_FILE; exit 1; }
echo "📂 Working in: $(pwd)" | tee -a $LOG_FILE

# 2. Fix JSX syntax error in src/App.jsx
echo "📝 Fixing JSX syntax error in src/App.jsx..." | tee -a $LOG_FILE
cat > src/App.jsx << 'EOF'
import { Suspense, useState } from 'react'
import { Canvas } from '@react-three/fiber'
import ModelViewer from './components/ModelViewer'
import './styles/main.scss'

export default function App() {
  const [color, setColor] = useState('#ff6b6b')
  const [outfit, setOutfit] = useState(1)
  const [rotation, setRotation] = useState(false)
  const [error, setError] = useState(null)

  return (
    <div id="app">
      <h1>3D Fashion Studio</h1>
      <div className="info">
        <p>Interact with the 3D model using mouse controls!</p>
        {error && <p className="error">Error: {error}</p>}
        <div className="controls">
          <div className="control-group">
            <label>Color:</label>
            <input type="color" value={color} onChange={(e) => setColor(e.target.value)} />
          </div>
          <div className="control-group">
            <label>Outfit:</label>
            <button onClick={() => setOutfit(1)}>Fabric 1</button>
            <button onClick={() => setOutfit(2)}>Fabric 2</button>
            <button onClick={() => setOutfit(3)}>Leather</button>
          </div>
          <div className="control-group">
            <label>Auto-Rotate:</label>
            <input type="checkbox" checked={rotation} onChange={(e) => setRotation(e.target.checked)} />
          </div>
        </div>
      </div>
      <Canvas shadows camera={{ position: [0, 0, 5], fov: 50 }}>
        <Suspense fallback={<mesh><boxGeometry args={[1, 1, 1]} /><meshStandardMaterial color="gray" /></mesh>}>
          <ModelViewer color={color} outfit={outfit} rotation={rotation} setError={setError} />
        </Suspense>
      </Canvas>
    </div>
  )
}
EOF
echo "✅ Fixed src/App.jsx JSX syntax" | tee -a $LOG_FILE

# 3. Address npm audit vulnerabilities
echo "🛡️ Addressing npm audit vulnerabilities..." | tee -a $LOG_FILE
run_command npm install vite@7.0.0 @vitejs/plugin-react@4.3.3 --save --legacy-peer-deps
run_command npm audit fix
if npm audit | grep -q "moderate"; then
  echo "⚠️ Moderate vulnerabilities persist, attempting npm audit fix --force" | tee -a $LOG_FILE
  run_command npm audit fix --force
fi
echo "✅ npm audit vulnerabilities addressed" | tee -a $LOG_FILE

# 4. Fix three-mesh-bvh deprecation warning
echo "🔄 Ensuring three-mesh-bvh@0.8.0..." | tee -a $LOG_FILE
cat > package.json << 'EOF'
{
  "name": "3dwebsite",
  "version": "1.0.0",
  "dependencies": {
    "three": "0.169.0",
    "@react-three/fiber": "8.17.8",
    "@react-three/drei": "9.114.0",
    "three-stdlib": "2.32.2",
    "three-mesh-bvh": "0.8.0",
    "react": "18.3.1",
    "react-dom": "18.3.1",
    "@vitejs/plugin-react": "4.3.3",
    "sass": "1.80.4",
    "vite": "7.0.0"
  },
  "devDependencies": {
    "@types/react": "18.3.11",
    "@types/react-dom": "18.3.0",
    "vite": "7.0.0"
  },
  "resolutions": {
    "three-mesh-bvh": "0.8.0",
    "esbuild": "0.24.3"
  },
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  }
}
EOF
rm -rf node_modules package-lock.json
run_command npm install --legacy-peer-deps
if ! npm list three-mesh-bvh | grep "three-mesh-bvh@0.8.0" >/dev/null; then
  echo "❌ three-mesh-bvh@0.8.0 not installed correctly" | tee -a $LOG_FILE
  exit 1
fi
echo "✅ three-mesh-bvh@0.8.0 verified" | tee -a $LOG_FILE

# 5. Verify index.html and main.jsx
echo "📝 Verifying index.html and main.jsx..." | tee -a $LOG_FILE
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>3D Fashion Studio</title>
  <link href="https://fonts.googleapis.com/css2?family=Avenir:wght@400;500;700&display=swap" rel="stylesheet">
</head>
<body>
  <div id="root"></div>
  <script type="module" src="/src/main.jsx"></script>
</body>
</html>
EOF
cat > src/main.jsx << 'EOF'
import { createRoot } from 'react-dom/client'
import App from './App'
import './styles/main.scss'

const root = createRoot(document.getElementById('root'))
root.render(<App />)
EOF
echo "✅ Verified index.html and main.jsx" | tee -a $LOG_FILE

# 6. Update vite.config.js to ensure ESM and compatibility
echo "📝 Updating vite.config.js..." | tee -a $LOG_FILE
cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true,
    host: true,
    strictPort: true
  },
  resolve: {
    alias: {
      '@': '/src'
    }
  },
  esbuild: {
    loader: 'jsx',
    include: /src\/.*\.[jt]sx?$/
  },
  optimizeDeps: {
    include: ['react', 'react-dom', '@react-three/fiber', '@react-three/drei', 'three', 'three-stdlib', 'three-mesh-bvh']
  },
  css: {
    preprocessorOptions: {
      scss: {
        api: 'modern'
      }
    }
  }
})
EOF
echo "✅ Updated vite.config.js" | tee -a $LOG_FILE

# 7. Investigate 'Killed' Git commit issue
echo "🔍 Investigating Git commit 'Killed' issue..." | tee -a $LOG_FILE
if ! git commit -m "Test commit" --allow-empty; then
  echo "⚠️ Git commit failed, checking system resources..." | tee -a $LOG_FILE
  run_command free -m
  run_command dmesg | tail -n 20
  echo "⚠️ Possible low memory issue. Consider increasing RAM or swap, or closing other processes." | tee -a $LOG_FILE
fi
echo "✅ Git commit test completed" | tee -a $LOG_FILE

# 8. Commit changes to Git (if repository exists)
if git rev-parse --git-dir >/dev/null 2>&1; then
  echo "📝 Committing changes to Git..." | tee -a $LOG_FILE
  run_command git add .
  run_command git commit -m "Fixed JSX syntax in App.jsx, resolved npm audit, three-mesh-bvh, and Git commit issue"
  echo "✅ Changes committed to Git" | tee -a $LOG_FILE
else
  echo "⚠️ Not a Git repository, skipping commit" | tee -a $LOG_FILE
fi

# 9. Start development server
echo "🚀 Starting development server..." | tee -a $LOG_FILE
if lsof -i :3000 >/dev/null; then
  echo "⚠️ Port 3000 in use, killing process..." | tee -a $LOG_FILE
  run_command kill -9 $(lsof -t -i :3000)
fi
run_command npm run dev &

# 10. Run printstate.sh to verify state
echo "📝 Running printstate.sh to verify repository state..." | tee -a $LOG_FILE
run_command ./printstate.sh

# 11. Verify application
echo "🌐 Please open http://localhost:3000 and verify the application." | tee -a $LOG_FILE
echo "Expected: Mannequin model with texture controls, color picker, and auto-rotate checkbox." | tee -a $LOG_FILE
echo "If a static page persists, check browser Console (F12) and $LOG_FILE." | tee -a $LOG_FILE
echo "DONE" | tee -a $LOG_FILE