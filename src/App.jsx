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
