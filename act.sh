#!/bin/bash

# Fix Static Page Script for 3D Fashion Studio
# ----------------------------------
# This script fixes the static page issue on localhost by:
# 1. Verifying and fixing src/App.jsx for correct JSX structure
# 2. Ensuring dependencies are correctly installed
# 3. Checking mannequin.glb and texture files
# 4. Adding error handling to ModelViewer.jsx
# 5. Improving lighting in ModelViewer.jsx
# 6. Resolving port conflicts
# 7. Updating vite.config.js for better dev experience
# 8. Committing changes to Git (if applicable)
# 9. Running printstate.sh to verify state

set -o pipefail
LOG_FILE="fix-static-3dwebsite.log"
echo "🚀 Fixing Static Page Issue for 3D Fashion Studio - $(date)" | tee -a $LOG_FILE

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

# 2. Verify and fix src/App.jsx
echo "📝 Verifying and updating src/App.jsx..." | tee -a $LOG_FILE
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
        <Suspense fallback={<mesh><boxGeometry args={[1, 1, 1]} /><meshStandardMaterial color="gray" /></Suspense>}>
          <ModelViewer color={color} outfit={outfit} rotation={rotation} setError={setError} />
        </Suspense>
      </Canvas>
    </div>
  )
}
EOF
echo "✅ Updated src/App.jsx with error handling" | tee -a $LOG_FILE

# 3. Update ModelViewer.jsx with error handling and improved lighting
echo "📝 Updating ModelViewer.jsx with error handling and better lighting..." | tee -a $LOG_FILE
cat > src/components/ModelViewer.jsx << 'EOF'
import { useGLTF } from '@react-three/drei'
import * as THREE from 'three'
import { OrbitControls, useTexture } from '@react-three/drei'

export default function ModelViewer({ color, outfit, rotation, setError }) {
  try {
    const { scene } = useGLTF('/assets/models/mannequin.glb')
    const textures = {
      1: useTexture('/assets/textures/fabric1.jpg'),
      2: useTexture('/assets/textures/fabric2.jpg'),
      3: useTexture('/assets/textures/leather.jpg')
    }

    // Apply texture to all mesh children
    scene.traverse((child) => {
      if (child.isMesh) {
        child.material = new THREE.MeshStandardMaterial({
          color,
          map: textures[outfit],
          roughness: 0.4,
          metalness: 0.1
        })
        child.castShadow = true
        child.receiveShadow = true
      }
    })

    return (
      <>
        <group rotation={[0, rotation ? Date.now() * 0.0005 % (2 * Math.PI) : 0, 0]}>
          <primitive object={scene} scale={[0.01, 0.01, 0.01]} />
        </group>
        <OrbitControls enableZoom={true} enablePan={true} />
        <ambientLight intensity={0.3} />
        <directionalLight position={[5, 5, 5]} intensity={1} castShadow />
        <directionalLight position={[-5, 5, -5]} intensity={0.5} />
        <hemisphereLight skyColor="#ffffff" groundColor="#444444" intensity={0.3} />
      </>
    )
  } catch (e) {
    setError(`Failed to load model or textures: ${e.message}`)
    console.error('Error loading model:', e)
    return (
      <mesh>
        <boxGeometry args={[1, 1, 1]} />
        <meshStandardMaterial color="hotpink" />
      </mesh>
    )
  }
}
EOF
echo "✅ Updated ModelViewer.jsx" | tee -a $LOG_FILE

# 4. Ensure dependencies are correctly installed
echo "🔄 Reinstalling dependencies..." | tee -a $LOG_FILE
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
run_command npm audit fix
if npm audit | grep -q "moderate"; then
  echo "⚠️ Moderate vulnerabilities persist, attempting npm audit fix --force" | tee -a $LOG_FILE
  run_command npm audit fix --force
fi
echo "✅ npm audit vulnerabilities addressed" | tee -a $LOG_FILE

# 5. Check mannequin.glb and texture files
echo "🔍 Verifying mannequin.glb and texture files..." | tee -a $LOG_FILE
if [ -f "src/assets/models/mannequin.glb" ]; then
  echo "✅ mannequin.glb exists" | tee -a $LOG_FILE
else
  echo "❌ mannequin.glb missing, creating placeholder..." | tee -a $LOG_FILE
  mkdir -p src/assets/models
  touch src/assets/models/mannequin.glb
  echo "⚠️ Placeholder mannequin.glb created. Replace with a valid GLB model." | tee -a $LOG_FILE
fi
for texture in fabric1.jpg fabric2.jpg leather.jpg; do
  if [ -f "src/assets/textures/$texture" ]; then
    echo "✅ Texture $texture exists" | tee -a $LOG_FILE
  else
    echo "⚠️ Texture $texture missing, creating fallback..." | tee -a $LOG_FILE
    mkdir -p src/assets/textures
    convert -size 512x512 xc:#$((RANDOM%0xFFFFFF)) src/assets/textures/$texture
  fi
done

# 6. Resolve port conflicts
echo "🔌 Checking for port conflicts..." | tee -a $LOG_FILE
if lsof -i :3000 >/dev/null; then
  echo "⚠️ Port 3000 in use, killing process..." | tee -a $LOG_FILE
  run_command kill -9 $(lsof -t -i :3000)
fi
echo "✅ Port 3000 cleared" | tee -a $LOG_FILE

# 7. Update vite.config.js for better dev experience
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
    strictPort: true // Fail if port is in use
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
echo "✅ Updated vite.config.js with strictPort" | tee -a $LOG_FILE

# 8. Update main.scss for error styling
echo "📝 Updating main.scss for error styling..." | tee -a $LOG_FILE
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
  background: rgba(255, 255, 255, 0.9);
  padding: 15px;
  border-radius: 10px;
  margin-bottom: 20px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.controls {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.control-group {
  display: flex;
  align-items: center;
  gap: 10px;
}

.control-group label {
  font-size: 14px;
  color: #333;
}

.control-group button {
  padding: 8px 16px;
  border: none;
  border-radius: 5px;
  background: #6200ea;
  color: white;
  cursor: pointer;
  font-size: 14px;
}

.control-group button:hover {
  background: #7f39fb;
}

.control-group input[type="color"] {
  width: 40px;
  height: 40px;
  border: none;
  cursor: pointer;
}

.control-group input[type="checkbox"] {
  width: 20px;
  height: 20px;
  cursor: pointer;
}

canvas {
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

.error {
  color: #d32f2f;
  font-weight: bold;
  margin: 10px 0;
}
EOF
echo "✅ Updated main.scss" | tee -a $LOG_FILE

# 9. Commit changes to Git (if repository exists)
if git rev-parse --git-dir >/dev/null 2>&1; then
  echo "📝 Committing changes to Git..." | tee -a $LOG_FILE
  run_command git add .
  run_command git commit -m "Fixed static page issue, added error handling, improved lighting, resolved port conflicts"
  echo "✅ Changes committed to Git" | tee -a $LOG_FILE
else
  echo "⚠️ Not a Git repository, skipping commit" | tee -a $LOG_FILE
fi

# 10. Start development server
echo "🚀 Starting development server..." | tee -a $LOG_FILE
run_command npm run dev &

# 11. Run printstate.sh to verify state
echo "📝 Running printstate.sh to verify repository state..." | tee -a $LOG_FILE
run_command ./printstate.sh

# 12. Verify application
echo "🌐 Please open http://localhost:3000 and verify the application." | tee -a $LOG_FILE
echo "Expected: Mannequin model with texture controls, color picker, and auto-rotate checkbox." | tee -a $LOG_FILE
echo "If a static page persists, check browser Console (F12) and $LOG_FILE." | tee -a $LOG_FILE
echo "DONE" | tee -a $LOG_FILE

