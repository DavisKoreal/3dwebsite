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
