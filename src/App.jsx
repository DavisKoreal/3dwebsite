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
