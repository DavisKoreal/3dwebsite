#!/bin/bash

# Enhanced 3D Fashion Studio Setup Script with Robust Error Handling
# ----------------------------------------------------------------
set -e  # Exit on error
set -o pipefail  # Capture pipe failures

LOG_FILE="setup.log"
echo "🚀 Starting 3D Fashion Studio Setup - $(date)" | tee -a $LOG_FILE

# Change to project directory
cd /home/davis/Desktop/3dwebsite || { echo "❌ Error: Could not enter project directory"; exit 1; }
echo "📂 Working in: $(pwd)" | tee -a $LOG_FILE

# Function to log and execute commands with error handling
run_command() {
  echo "🔧 Executing: $*" | tee -a $LOG_FILE
  if ! "$@" 2>&1 | tee -a $LOG_FILE; then
    echo "❌ Error executing: $*" | tee -a $LOG_FILE
    return 1
  fi
  return 0
}

# Install dependencies
echo "📦 Installing dependencies..." | tee -a $LOG_FILE
run_command npm install three @react-three/fiber @react-three/drei three-stl-loader dat.gui --save
run_command npm install @vitejs/plugin-react sass --save-dev

# Verify installations
if [ ! -d "node_modules" ]; then
  echo "❌ node_modules not created - check npm errors above" | tee -a $LOG_FILE
  exit 1
fi
echo "✅ Dependencies installed successfully" | tee -a $LOG_FILE

# Create directory structure
echo "📁 Creating project structure..." | tee -a $LOG_FILE
run_command mkdir -p src/{components,styles,assets/{models,textures}}

# Create model file with fallback
echo "🛠️ Creating 3D model..." | tee -a $LOG_FILE
cat > src/assets/models/mannequin.stl << 'EOL'
solid mannequin
  facet normal 0 0 0
    outer loop
      vertex 0 0 0
      vertex 1 0 0
      vertex 0 1 0
    endloop
  endfacet
endsolid mannequin
EOL
echo "✅ Basic model created" | tee -a $LOG_FILE

# Function to create colored texture fallbacks
create_color_texture() {
  name=$1
  hex=$2
  convert -size 512x512 xc:"$hex" "src/assets/textures/$name.jpg"
}

# Create textures with fallbacks
echo "🎨 Creating textures..." | tee -a $LOG_FILE
create_color_texture "fabric1" "#a8d8ea"
create_color_texture "fabric2" "#aa96da"
create_color_texture "leather" "#fcbad3"
echo "✅ Textures created successfully" | tee -a $LOG_FILE

# Function to create files with verification
create_file() {
  echo "📝 Creating $1" | tee -a $LOG_FILE
  mkdir -p "$(dirname "$1")"
  cat > "$1" << EOF
$2
EOF
  if [ ! -f "$1" ]; then
    echo "❌ Failed to create $1" | tee -a $LOG_FILE
    return 1
  fi
  return 0
}

# Create React components
create_file src/components/ModelViewer.jsx '
import { useRef, useState, useEffect } from "react"
import { useLoader } from "@react-three/fiber"
import { STLLoader } from "three-stl-loader"
import { OrbitControls, useTexture } from "@react-three/drei"

export default function ModelViewer() {
  const [color, setColor] = useState("#ff6b6b")
  const [rotation, setRotation] = useState(false)
  const [outfit, setOutfit] = useState(1)
  
  // Initialize GUI
  useEffect(() => {
    const gui = new window.dat.GUI()
    gui.addColor({ color }, "color").onChange(setColor)
    gui.add({ rotation }, "rotation").onChange(setRotation)
    gui.add({ outfit }, "outfit", 1, 3, 1).onChange(setOutfit)
    
    return () => gui.destroy()
  }, [])

  try {
    // Load 3D model
    const geometry = useLoader(STLLoader, "/assets/models/mannequin.stl")
    
    // Load textures
    const textures = {
      1: useTexture("/assets/textures/fabric1.jpg"),
      2: useTexture("/assets/textures/fabric2.jpg"),
      3: useTexture("/assets/textures/leather.jpg")
    }

    return (
      <>
        <group rotation={[0, rotation ? Math.PI : 0, 0]}>
          <mesh geometry={geometry} castShadow receiveShadow>
            <meshStandardMaterial 
              color={color} 
              map={textures[outfit]}
              roughness={0.4}
              metalness={0.1}
            />
          </mesh>
        </group>
        <OrbitControls enableZoom={true} enablePan={true} />
        <ambientLight intensity={0.5} />
        <directionalLight position={[10, 10, 5]} intensity={1} castShadow />
      </>
    )
  } catch (e) {
    console.error("Model loading failed:", e)
    return (
      <mesh>
        <boxGeometry args={[1, 1, 1]} />
        <meshBasicMaterial color="hotpink" />
      </mesh>
    )
  }
}
'

create_file src/App.jsx '
import { Canvas } from "@react-three/fiber"
import { Suspense } from "react"
import ModelViewer from "./components/ModelViewer"
import "./styles/main.scss"

export default function App() {
  return (
    <div id="app">
      <h1>3D Fashion Studio</h1>
      <div className="info">
        <p>Use the controls panel to:</p>
        <ul>
          <li>Change outfit colors</li>
          <li>Switch between fabrics</li>
          <li>Rotate the model</li>
        </ul>
      </div>
      
      <Canvas shadows camera={{ position: [0, 0, 5], fov: 50 }}>
        <Suspense fallback={null}>
          <ModelViewer />
        </Suspense>
      </Canvas>
    </div>
  )
}
'

create_file src/styles/main.scss '
body {
  margin: 0;
  font-family: "Avenir", sans-serif;
  overflow: hidden;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  color: #333;
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
  margin: 20px 0;
  text-align: center;
  font-size: 2.5rem;
  color: #2c3e50;
}

.info {
  background: rgba(255, 255, 255, 0.85);
  padding: 15px;
  border-radius: 10px;
  max-width: 500px;
  text-align: center;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  z-index: 100;
  margin-bottom: 20px;
}

.info p {
  margin: 0 0 10px 0;
  font-weight: 500;
}

.info ul {
  text-align: left;
  padding-left: 20px;
  margin: 0;
}

.info li {
  margin-bottom: 5px;
}

canvas {
  border-radius: 10px;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
}
'

create_file src/js/main.js '
import { createRoot } from "react-dom/client"
import App from "../App"
import "./styles/main.scss"

const container = document.getElementById("root")
const root = createRoot(container)
root.render(<App />)
'

create_file index.html '
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
  <script type="module" src="/src/js/main.js"></script>
</body>
</html>
'

create_file vite.config.js '
import { defineConfig } from "vite"
import react from "@vitejs/plugin-react"

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true
  },
  resolve: {
    alias: {
      "@": "/src"
    }
  }
})
'

# Final verification
echo "🔍 Verifying setup..." | tee -a $LOG_FILE
[ -f "src/assets/models/mannequin.stl" ] && echo "✅ Model file exists" | tee -a $LOG_FILE
[ -f "src/assets/textures/fabric1.jpg" ] && echo "✅ Texture 1 exists" | tee -a $LOG_FILE
[ -f "src/assets/textures/fabric2.jpg" ] && echo "✅ Texture 2 exists" | tee -a $LOG_FILE
[ -f "src/assets/textures/leather.jpg" ] && echo "✅ Leather texture exists" | tee -a $LOG_FILE

echo "🎉 Setup completed successfully!" | tee -a $LOG_FILE
echo "👉 Run the project with: npm run dev" | tee -a $LOG_FILE
echo "📄 Full log saved to: $LOG_FILE" | tee -a $LOG_FILE