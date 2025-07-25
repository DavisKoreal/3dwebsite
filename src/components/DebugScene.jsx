
import { useRef } from 'react';
import { useFrame, useLoader } from '@react-three/fiber';
import { OrbitControls } from '@react-three/drei';
import { STLLoader } from 'three-stdlib';

export default function DebugScene() {
  const meshRef = useRef();
  const geometry = useLoader(STLLoader, '/assets/models/mannequin.stl');

  useFrame(() => {
    if (meshRef.current) {
      meshRef.current.rotation.x += 0.01;
      meshRef.current.rotation.y += 0.01;
    }
  });

  return (
    <>
      <mesh ref={meshRef} geometry={geometry}>
        <meshStandardMaterial color="hotpink" />
      </mesh>
      <ambientLight intensity={0.5} />
      <pointLight position={[10, 10, 10]} intensity={1} />
      <OrbitControls enableZoom={true} enablePan={true} />
    </>
  );
}