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
      <Canvas shadows camera={{ position: [0, 0, 5], fov: 50 }>
        <Suspense fallback={null}>
          <ModelViewer color={color} outfit={outfit} rotation={rotation} />
        </Suspense>
      </Canvas>
    </div>
  )
}
