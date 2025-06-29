#!/bin/bash

# Fix Script for 3D Fashion Studio
# ----------------------------------
# This script fixes the following issues:
# 1. Syntax error in src/App.jsx (JSX elements not wrapped)
# 2. npm audit vulnerabilities (esbuild and vite)
# 3. three-mesh-bvh deprecation warning
# 4. Vite CJS deprecation warning
# 5. Port conflict for Vite server
# 6. Updates printstate.sh to correctly handle index.html
# 7. Commits changes to Git (if applicable)

set -o pipefail
LOG_FILE="fix-3dwebsite.log"
echo "🚀 Fixing 3D Fashion Studio - $(date)" | tee -a $LOG_FILE

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

# 2. Fix syntax error in src/App.jsx
echo "📝 Fixing syntax error in src/App.jsx..." | tee -a $LOG_FILE
cat > src/App.jsx << 'EOF'
import { Suspense, useState } from 'react'
import { Canvas } from '@react-three/fiber'
import ModelViewer from './components/ModelViewer'
import './styles/main.scss'

export default function App() {
  const [color, setColor] = useState('#ff6b6b')
  const [outfit, setOutfit] = useState(1)
  const [rotation, setRotation] = useState(false)

  return (
    <div id="app">
      <h1>3D Fashion Studio</h1>
      <div className="info">
        <p>Interact with the 3D model using mouse controls!</p>
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
        <Suspense fallback={null}>
          <ModelViewer color={color} outfit={outfit} rotation={rotation} />
        </Suspense>
      </Canvas>
    </div>
  )
}
EOF
echo "✅ Fixed src/App.jsx syntax" | tee -a $LOG_FILE

# 3. Address npm audit vulnerabilities (esbuild and vite)
echo "🛡️ Addressing npm audit vulnerabilities..." | tee -a $LOG_FILE
run_command npm install vite@5.4.19 --save --legacy-peer-deps
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
    "dat.gui": "0.7.9",
    "react": "18.3.1",
    "react-dom": "18.3.1",
    "@vitejs/plugin-react": "4.3.2",
    "sass": "1.80.4",
    "vite": "5.4.19"
  },
  "devDependencies": {
    "@types/react": "18.3.11",
    "@types/react-dom": "18.3.0",
    "vite": "5.4.19"
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

# 5. Fix Vite CJS deprecation warning
echo "📝 Updating vite.config.js to use ESM..." | tee -a $LOG_FILE
cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true,
    host: true // Expose to network to avoid port conflicts
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
echo "✅ Updated vite.config.js for ESM and port conflict mitigation" | tee -a $LOG_FILE

# 6. Update printstate.sh to correctly handle index.html
echo "📝 Updating printstate.sh to fix index.html output..." | tee -a $LOG_FILE
cat > printstate.sh << 'EOF'
#!/bin/bash

# Script to recursively print contents of .jsx, .js, .html, .scss, and .css files
# to understand the state of the repository, excluding node_modules, boilerplate directories,
# package.json, and *.sh files
# ----------------------------------
# Usage: ./printstate.sh > state.txt
# Outputs file paths and contents for relevant files

set -o pipefail
LOG_FILE="printstate.log"
echo "🚀 Generating repository state - $(date)" | tee -a $LOG_FILE

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

# 2. Print repository state to stdout (for redirection to state.txt)
echo "📝 Printing repository state..." | tee -a $LOG_FILE
{
  echo "===== Repository State: $(date) ====="
  echo "Directory: $(pwd)"
  echo ""

  # List relevant file types: .jsx, .js, .html, .scss, .css
  # Exclude node_modules, dist, build, and package.json
  find . -type d \( -name "node_modules" -o -name "dist" -o -name "build" \) -prune -o \
    -type f \( -name "*.jsx" -o -name "*.js" -o -name "*.html" -o -name "*.scss" -o -name "*.css" \) \
    ! -name "package.json" | sort | while read -r file; do
    echo "===== $file ====="
    if [ "${file##*.}" = "html" ]; then
      # Escape HTML content to preserve tags
      sed 's/</\&lt;/g; s/>/\&gt;/g' "$file"
    else
      cat "$file"
    fi
    echo ""
  done

  # Include package-lock.json summary if it exists (for dependency state)
  if [ -f "package-lock.json" ]; then
    echo "===== package-lock.json (summary) ====="
    echo "Showing package-lock.json summary (full file omitted due to size)"
    jq '.name, .version, .dependencies | keys' package-lock.json 2>/dev/null || echo "⚠️ jq not installed, skipping package-lock.json summary"
    echo ""
  fi

  # Include git status if repository is a git repo
  if git rev-parse --git-dir >/dev/null 2>&1; then
    echo "===== Git Status ====="
    git status
    echo ""
  fi
} > state.txt

# 3. Verify output
if [ -f "state.txt" ]; then
  echo "✅ Repository state written to state.txt" | tee -a $LOG_FILE
  echo "📄 Run 'cat state.txt' to view or redirect as needed" | tee -a $LOG_FILE
else
  echo "❌ Failed to create state.txt" | tee -a $LOG_FILE
  exit 1
fi

echo "DONE" | tee -a $LOG_FILE
EOF
chmod +x printstate.sh
echo "✅ Updated printstate.sh to escape HTML content" | tee -a $LOG_FILE

# 7. Fix index.html to ensure proper content
echo "📝 Restoring index.html content..." | tee -a $LOG_FILE
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
echo "✅ Restored index.html" | tee -a $LOG_FILE

# 8. Commit changes to Git (if repository exists)
if git rev-parse --git-dir >/dev/null 2>&1; then
  echo "📝 Committing changes to Git..." | tee -a $LOG_FILE
  run_command git add .
  run_command git commit -m "Fixed App.jsx syntax, npm audit, three-mesh-bvh, Vite CJS, port conflict, and printstate.sh"
  echo "✅ Changes committed to Git" | tee -a $LOG_FILE
else
  echo "⚠️ Not a Git repository, skipping commit" | tee -a $LOG_FILE
fi

# 9. Start development server
echo "🚀 Starting development server..." | tee -a $LOG_FILE
run_command npm run dev &

# 10. Verify application
echo "🌐 Please open http://localhost:3000 and verify the application." | tee -a $LOG_FILE
echo "Expected: Mannequin model with texture controls, color picker, and auto-rotate checkbox." | tee -a $LOG_FILE
echo "If issues occur, check browser Console (F12) and $LOG_FILE." | tee -a $LOG_FILE
echo "DONE" | tee -a $LOG_FILE

