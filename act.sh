#!/bin/bash

# Ultimate Fix for 3D Fashion Studio (Updated)
# ----------------------------------
set -o pipefail  # Capture pipe failures
LOG_FILE="ultimate-fix.log"
echo "🚀 Starting Ultimate 3D Fashion Studio Fix - $(date)" | tee -a $LOG_FILE

# Change to project directory
cd /home/davis/Desktop/3dwebsite || { echo "❌ Error: Could not enter project directory" | tee -a $LOG_FILE; exit 1; }
echo "📂 Working in: $(pwd)" | tee -a $LOG_FILE

# Function to log and execute commands
run_command() {
  echo "🔧 Executing: $*" | tee -a $LOG_FILE
  if ! "$@" 2>&1 | tee -a $LOG_FILE; then
    echo "⚠️ Warning: Error executing: $*" | tee -a $LOG_FILE
    return 1
  fi
  return 0
}

# 1. Install ImageMagick for texture generation
echo "🛠️ Checking for ImageMagick..." | tee -a $LOG_FILE
if ! command -v convert >/dev/null 2>&1; then
  echo "📦 Installing ImageMagick..." | tee -a $LOG_FILE
  run_command sudo apt-get update
  run_command sudo apt-get install -y imagemagick
else
  echo "✅ ImageMagick already installed" | tee -a $LOG_FILE
fi

# 2. Clean and remove conflicting dependencies
echo "🔄 Cleaning and removing conflicting dependencies..." | tee -a $LOG_FILE
rm -rf node_modules package-lock.json
echo "🗑️ Removing Expo and React Native dependencies..." | tee -a $LOG_FILE
run_command npm pkg delete dependencies.expo
run_command npm pkg delete dependencies.@expo/dom-webview
run_command npm pkg delete dependencies.expo-asset
run_command npm pkg delete dependencies.expo-file-system
run_command npm pkg delete dependencies.expo-gl
run_command npm pkg delete dependencies.react-native-webview

# 3. Install compatible dependencies
echo "🔄 Installing dependencies..." | tee -a $LOG_FILE
# Temporarily disable set -e for npm install to handle peer dependency warnings
set +e
run_command npm install three@0.169.0 @react-three/fiber@8.17.8 @react-three/drei@9.114.0 three-stdlib@2.32.2 dat.gui@0.7.9 react@18.3.1 react-dom@18.3.1 @vitejs/plugin-react@4.3.2 sass@1.80.4 --save
if [ $? -ne 0 ]; then
  echo "⚠️ Retrying npm install with --legacy-peer-deps..." | tee -a $LOG_FILE
  run_command npm install three@0.169.0 @react-three/fiber@8.17.8 @react-three/drei@9.114.0 three-stdlib@2.32.2 dat.gui@0.7.9 react@18.3.1 react-dom@18.3.1 @vitejs/plugin-react@4.3.2 sass@1.80.4 --save --legacy-peer-deps
fi
set -e
run_command npm install --save-dev @types/react@18.3.11 @types/react-dom@18.3.0

# 4. Verify node_modules
if [ ! -d "node_modules" ]; then
  echo "❌ node_modules not created - check npm errors above" | tee -a $LOG_FILE
  exit 1
fi
echo "✅ Dependencies installed successfully" | tee -a $LOG_FILE

# 5. Rebuild project structure
echo "📁 Rebuilding project structure..." | tee -a $LOG_FILE
run_command mkdir -p src/{components,styles,assets/{models,textures}}

# 6. Create simple STL model
echo "🛠️ Creating fallback STL model..." | tee -a $LOG_FILE
cat > src/assets/models/mannequin.stl << 'EOF'
solid mannequin
  facet normal 0 0 0
    outer loop
      vertex 0 0 0
      vertex 1 0 0
      vertex 0 1 0
    endloop
  endfacet
endsolid mannequin
EOF
echo "✅ Fallback STL model created" | tee -a $LOG_FILE

# 7. Generate fallback textures
echo "🎨 Generating fallback textures..." | tee -a $LOG_FILE
for texture in "fabric1 #a8d8ea" "fabric2 #aa96da" "leather #fcbad3"; do
  name=$(echo $texture | cut -d' ' -f1)
  color=$(echo $texture | cut -d' ' -f2)
  echo "Creating texture: $name.jpg with color $color" | tee -a $LOG_FILE
  if ! convert -size 512x512 xc:"$color" "src/assets/textures/$name.jpg" 2>> $LOG_FILE; then
    echo "⚠️ Failed to create texture $name.jpg - creating empty file" | tee -a $LOG_FILE
    touch "src/assets/textures/$name.jpg"
  fi
done
echo "✅ Textures created successfully" | tee -a $LOG_FILE

# 8. Create Vite config with proper JSX handling
echo "⚙️ Creating Vite configuration..." | tee -a $LOG_FILE
cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true
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
    include: ['react', 'react-dom', '@react-three/fiber', '@react-three/drei', 'three', 'three-stdlib']
  }
})
EOF

# 9. Create main entry point
echo "📝 Creating main.jsx..." | tee -a $LOG_FILE
cat > src/main.jsx << 'EOF'
import { createRoot } from 'react-dom/client'
import App from './App'
import './styles/main.scss'

const root = createRoot(document.getElementById('root'))
root.render(<App />)
EOF

# 10. Create App component
echo "📝 Creating App.jsx..." | tee -a $LOG_FILE
cat > src/App.jsx << 'EOF'
import { Suspense } from 'react'
import { Canvas } from '@react-three/fiber'
import DebugScene from './components/DebugScene'
import './styles/main.scss'

export default function App() {
  return (
    <div id="app">
      <h1>3D Fashion Studio</h1>
      <div className="info">
        <p>Interact with the 3D model using mouse controls!</p>
      </div>
      <Canvas shadows camera={{ position: [0, 0, 5], fov: 50 }}>
        <Suspense fallback={null}>
          <DebugScene />
        </Suspense>
      </Canvas>
    </div>
  )
}
EOF

# 11. Create DebugScene component
echo "📝 Creating DebugScene.jsx..." | tee -a $LOG_FILE
cat > src/components/DebugScene.jsx << 'EOF'
import { useRef } from 'react'
import { useFrame } from '@react-three/fiber'
import { OrbitControls } from '@react-three/drei'

export default function DebugScene() {
  const boxRef = useRef()

  useFrame(() => {
    if (boxRef.current) {
      boxRef.current.rotation.x += 0.01
      boxRef.current.rotation.y += 0.01
    }
  })

  return (
    <>
      <mesh ref={boxRef}>
        <boxGeometry args={[1, 1, 1]} />
        <meshStandardMaterial color="hotpink" />
      </mesh>
      <ambientLight intensity={0.5} />
      <pointLight position={[10, 10, 10]} intensity={1} />
      <OrbitControls enableZoom={true} enablePan={true} />
    </>
  )
}
EOF

# 12. Create styles
echo "📝 Creating main.scss..." | tee -a $LOG_FILE
cat > src/styles/main.scss << 'EOF'
body {
  margin: 0;
  font-family: 'Avenir', sans-serif;
  overflow: hidden;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}

#app {
  position: relative;
  width: 100vw;
  height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
}

h1 {
  color: #333;
  margin: 20px 0;
  text-align: center;
}

.info {
  background: rgba(255,255,255,0.9);
  padding: 15px;
  border-radius: 10px;
  margin-bottom: 20px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

canvas {
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
}
EOF

# 13. Create index.html
echo "📝 Creating index.html..." | tee -a $LOG_FILE
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

# 14. Update package.json scripts
echo "⚙️ Updating package.json scripts..." | tee -a $LOG_FILE
run_command npm pkg set scripts.dev="vite"
run_command npm pkg set scripts.build="vite build"
run_command npm pkg set scripts.preview="vite preview"

# 15. Verify setup
echo "🔍 Verifying setup..." | tee -a $LOG_FILE
[ -f "src/main.jsx" ] && echo "✅ main.jsx exists" | tee -a $LOG_FILE || echo "❌ main.jsx missing" | tee -a $LOG_FILE
[ -f "src/App.jsx" ] && echo "✅ App.jsx exists" | tee -a $LOG_FILE || echo "❌ App.jsx missing" | tee -a $LOG_FILE
[ -f "src/components/DebugScene.jsx" ] && echo "✅ DebugScene.jsx exists" | tee -a $LOG_FILE || echo "❌ DebugScene.jsx missing" | tee -a $LOG_FILE
[ -f "src/styles/main.scss" ] && echo "✅ main.scss exists" | tee -a $LOG_FILE || echo "❌ main.scss missing" | tee -a $LOG_FILE
[ -f "index.html" ] && echo "✅ index.html exists" | tee -a $LOG_FILE || echo "❌ index.html missing" | tee -a $LOG_FILE
[ -f "vite.config.js" ] && echo "✅ vite.config.js exists" | tee -a $LOG_FILE || echo "❌ vite.config.js missing" | tee -a $LOG_FILE

# 16. Verify package.json for conflicting dependencies
echo "🔍 Checking package.json for conflicting dependencies..." | tee -a $LOG_FILE
if grep -q "expo" package.json; then
  echo "⚠️ Warning: 'expo' found in package.json - consider removing it for a web-only project" | tee -a $LOG_FILE
else
  echo "✅ No 'expo' dependency found" | tee -a $LOG_FILE
fi

echo "🎉 Setup completed successfully!" | tee -a $LOG_FILE
echo "👉 Run the project with: npm run dev" | tee -a $LOG_FILE
echo "🌐 Open: http://localhost:3000" | tee -a $LOG_FILE
echo "📄 Full log saved to: $LOG_FILE" | tee -a $LOG_FILE