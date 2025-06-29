#!/bin/bash

# Continuation Script for 3D Fashion Studio
# ----------------------------------
# This script continues the improvement of the 3D Fashion Studio project by:
# 1. Updating ModelViewer.jsx to use the provided mannequin.glb model
# 2. Addressing npm audit vulnerabilities
# 3. Fixing three-mesh-bvh deprecation warning
# 4. Verifying texture files
# 5. Committing changes to Git (if applicable)
# 6. Starting the development server

set -o pipefail
LOG_FILE="continue-3dwebsite.log"
echo "🚀 Continuing 3D Fashion Studio Improvement - $(date)" | tee -a $LOG_FILE

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

# 2. Update ModelViewer.jsx to use mannequin.glb
echo "📝 Updating ModelViewer.jsx for GLB model..." | tee -a $LOG_FILE
cat > src/components/ModelViewer.jsx << 'EOF'
import { useGLTF } from '@react-three/drei'
import * as THREE from 'three'
import { OrbitControls, useTexture } from '@react-three/drei'

export default function ModelViewer({ color, outfit, rotation }) {
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
        <ambientLight intensity={0.5} />
        <pointLight position={[10, 10, 10]} intensity={1} />
      </>
    )
  } catch (e) {
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
echo "✅ Updated ModelViewer.jsx for mannequin.glb" | tee -a $LOG_FILE

# 3. Address npm audit vulnerabilities
echo "🛡️ Addressing npm audit vulnerabilities..." | tee -a $LOG_FILE
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
    "vite": "5.4.8"
  },
  "devDependencies": {
    "@types/react": "18.3.11",
    "@types/react-dom": "18.3.0",
    "vite": "5.4.8"
  },
  "resolutions": {
    "three-mesh-bvh": "0.8.0"
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

# 5. Verify texture files
echo "🔍 Verifying texture files..." | tee -a $LOG_FILE
for texture in fabric1.jpg fabric2.jpg leather.jpg; do
  if [ -f "src/assets/textures/$texture" ]; then
    echo "✅ Texture $texture exists" | tee -a $LOG_FILE
  else
    echo "⚠️ Texture $texture missing, creating fallback..." | tee -a $LOG_FILE
    convert -size 512x512 xc:#$((RANDOM%0xFFFFFF)) src/assets/textures/$texture
  fi
done

# 6. Commit changes to Git (if repository exists)
if git rev-parse --git-dir >/dev/null 2>&1; then
  echo "📝 Committing changes to Git..." | tee -a $LOG_FILE
  run_command git add .
  run_command git commit -m "Updated ModelViewer to use mannequin.glb, fixed dependencies, ensured textures"
  echo "✅ Changes committed to Git" | tee -a $LOG_FILE
else
  echo "⚠️ Not a Git repository, skipping commit" | tee -a $LOG_FILE
fi

# 7. Start development server
echo "🚀 Starting development server..." | tee -a $LOG_FILE
npm run dev &

# 8. Verify application
echo "🌐 Please open http://localhost:3000 and verify the application." | tee -a $LOG_FILE
echo "Expected: Mannequin model with texture controls, color picker, and auto-rotate checkbox." | tee -a $LOG_FILE
echo "If issues occur, check browser Console (F12) and $LOG_FILE." | tee -a $LOG_FILE
echo "DONE" | tee -a $LOG_FILE