#!/bin/bash
# brain-buster Quiz App Setup-Skript

echo "🧠 brain-buster Quiz App - Projekteinrichtung 🧠"
echo "=============================================="

# Erstelle das Hauptprojektverzeichnis
mkdir -p brain-buster
cd brain-buster

# Initialisiere das Frontend-Projekt mit Vite und React
echo "📦 Frontend-Projekt wird erstellt..."
npm create vite@latest frontend -- --template react-ts
cd frontend

# Installiere notwendige Frontend-Abhängigkeiten
echo "📦 Frontend-Abhängigkeiten werden installiert..."
npm install \
  react-router-dom \
  tailwindcss \
  postcss \
  autoprefixer \
  framer-motion \
  simple-peer \
  socket.io-client \
  chart.js \
  react-chartjs-2 \
  daisyui \
  localforage \
  uuid

# Konfiguriere Tailwind CSS
npx tailwindcss init -p

# Erstelle die Frontend-Ordnerstruktur
mkdir -p src/components/ui
mkdir -p src/components/game
mkdir -p src/components/multiplayer
mkdir -p src/components/stats
mkdir -p src/pages
mkdir -p src/hooks
mkdir -p src/utils
mkdir -p src/store
mkdir -p src/assets/images
mkdir -p src/assets/sounds
mkdir -p src/types

# Wechsel zurück zum Hauptprojektverzeichnis
cd ..

# Initialisiere das Backend-Projekt
echo "📦 Backend-Projekt wird erstellt..."
mkdir -p backend
cd backend

# Initialisiere das Node.js-Projekt
npm init -y

# Installiere notwendige Backend-Abhängigkeiten
echo "📦 Backend-Abhängigkeiten werden installiert..."
npm install \
  express \
  cors \
  dotenv \
  socket.io \
  uuid

# Installiere Entwicklungsabhängigkeiten
npm install --save-dev \
  typescript \
  ts-node \
  nodemon \
  @types/express \
  @types/cors \
  @types/node

# Erstelle die Backend-Ordnerstruktur
mkdir -p src/controllers
mkdir -p src/routes
mkdir -p src/services
mkdir -p src/models
mkdir -p src/config
mkdir -p src/types

# Erstelle eine einfache TypeScript-Konfiguration
echo '{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}' > tsconfig.json

# Erstelle eine nodemon-Konfiguration
echo '{
  "watch": ["src"],
  "ext": "ts",
  "exec": "ts-node src/server.ts"
}' > nodemon.json

# Aktualisiere package.json mit Skripten
npm pkg set scripts.start="node dist/server.js"
npm pkg set scripts.dev="nodemon"
npm pkg set scripts.build="tsc"

# Wechsel zurück zum Hauptprojektverzeichnis
cd ..

# Erstelle eine Docker-Datei für die Bereitstellung
echo "🐳 Docker-Konfiguration wird erstellt..."
echo 'version: "3.8"

services:
  frontend:
    build:
      context: ./frontend
    ports:
      - "5173:5173"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    depends_on:
      - backend

  backend:
    build:
      context: ./backend
    ports:
      - "3000:3000"
    volumes:
      - ./backend:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development' > docker-compose.yml

# Erstelle eine README-Datei
echo "📝 README wird erstellt..."
echo '# brain-buster Quiz App

Eine moderne Quiz-App mit Multiplayer-Unterstützung via WebRTC.

## Features

- 🎮 Modernes UI-Design
- 📱 Mobile-ready Responsive Design
- 🎯 Speicherung von Spielständen (richtige/falsche Antworten, Siege/Niederlagen)
- 📊 Umfangreiche Statistiken
- 🔄 Import/Export von Spielständen
- 👥 Multiplayer-Modus über WebRTC
- ✨ Animationen für ein besseres Spielerlebnis

## Schnellstart

### Voraussetzungen

- Node.js (v14 oder höher)
- npm (v7 oder höher)

### Installation und Ausführung

1. **Frontend starten:**
   ```
   cd frontend
   npm install
   npm run dev
   ```

2. **Backend starten:**
   ```
   cd backend
   npm install
   npm run dev
   ```

## Projektstruktur

- `frontend/`: React-basiertes Frontend
- `backend/`: Express-basierter Server für WebRTC-Signalisierung

## Lizenz

MIT
' > README.md

echo "✅ brain-buster-Projekt wurde erfolgreich eingerichtet!"
echo "📂 Wechsle in das Projektverzeichnis mit: cd brain-buster"
echo "▶️ Starte das Frontend mit: cd frontend && npm run dev"
echo "▶️ Starte das Backend mit: cd backend && npm run dev"
