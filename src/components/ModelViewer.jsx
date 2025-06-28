import { useRef, useState, useEffect } from 'react'
import { useLoader } from '@react-three/fiber'
import { STLLoader } from 'three-stl-loader'
import { OrbitControls, useTexture } from '@react-three/drei'

export default function ModelViewer() {
  const [color, setColor] = useState('#ff6b6b')
  const [rotation, setRotation] = useState(false)
  const [outfit, setOutfit] = useState(1)
  
  useEffect(() => {
    const gui = new (require('dat.gui')).GUI()
    gui.addColor({ color }, 'color').onChange(setColor)
    gui.add({ rotation }, 'rotation').onChange(setRotation)
    gui.add({ outfit }, 'outfit', 1, 3, 1).onChange(setOutfit)
    return () => gui.destroy()
  }, [])

  try {
    const geometry = useLoader(STLLoader, '/assets/models/mannequin.stl')
    const textures = {
      1: useTexture('/assets/textures/fabric1.jpg'),
      2: useTexture('/assets/textures/fabric2.jpg'),
      3: useTexture('/assets/textures/leather.jpg')
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
        <OrbitControls />
      </>
    )
  } catch (e) {
    console.error('Error loading model:', e)
    return (
      <mesh>
        <boxGeometry args={[1, 1, 1]} />
        <meshBasicMaterial color="hotpink" />
      </mesh>
    )
  }
}
