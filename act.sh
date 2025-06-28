# Move index.html to root
mv public/index.html .

# Update its script reference
sed -i 's|/src/js/main.js|./src/js/main.js|' index.html

# Simplify vite.config.js
cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import { resolve } from 'path'

export default defineConfig({
  server: {
    port: 3000,
    open: true
  }
})
EOF