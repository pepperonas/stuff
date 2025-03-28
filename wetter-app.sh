#!/bin/bash

# Farbdefinitionen für bessere Lesbarkeit
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Wetter-App Setup Skript ===${NC}"
echo -e "${YELLOW}Dieses Skript erstellt eine React Wetter-App mit allen benötigten Komponenten${NC}"
echo ""

# Projektordner erstellen
echo -e "${GREEN}Erstelle Projektordner 'weather'...${NC}"
mkdir -p weather
cd weather

# package.json erstellen
echo -e "${GREEN}Erstelle package.json...${NC}"
cat > package.json << 'EOF'
{
  "name": "weather",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1",
    "axios": "^1.6.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  },
  "devDependencies": {
    "tailwindcss": "^3.3.5",
    "postcss": "^8.4.31",
    "autoprefixer": "^10.4.16"
  }
}
EOF

# Tailwind und PostCSS Konfigurationsdateien erstellen
echo -e "${GREEN}Erstelle tailwind.config.js...${NC}"
cat > tailwind.config.js << 'EOF'
module.exports = {
  content: ["./src/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

echo -e "${GREEN}Erstelle postcss.config.js...${NC}"
cat > postcss.config.js << 'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# Erstelle src Ordner und Unterordner
echo -e "${GREEN}Erstelle Projektstruktur...${NC}"
mkdir -p src/components

# Erstelle index.js
echo -e "${GREEN}Erstelle src/index.js...${NC}"
cat > src/index.js << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

# Erstelle index.css
echo -e "${GREEN}Erstelle src/index.css...${NC}"
cat > src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #f0f9ff;
}
EOF

# Erstelle App.js
echo -e "${GREEN}Erstelle src/App.js...${NC}"
cat > src/App.js << 'EOF'
import React, { useState, useEffect } from 'react';
import axios from 'axios';
import WeatherCard from './components/WeatherCard';
import SearchBar from './components/SearchBar';
import Forecast from './components/Forecast';
import LoadingSpinner from './components/LoadingSpinner';

function App() {
  const [weather, setWeather] = useState(null);
  const [forecast, setForecast] = useState(null);
  const [location, setLocation] = useState('Berlin');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  
  const API_KEY = 'DEIN_API_KEY'; // Hier muss ein gültiger API-Key eingetragen werden
  const API_URL = 'https://api.openweathermap.org/data/2.5';

  useEffect(() => {
    fetchWeather(location);
  }, []);

  const fetchWeather = async (city) => {
    setLoading(true);
    setError('');
    try {
      // Aktuelles Wetter abrufen
      const weatherResponse = await axios.get(
        `${API_URL}/weather?q=${city}&units=metric&lang=de&appid=${API_KEY}`
      );
      
      // 5-Tage-Vorhersage abrufen
      const forecastResponse = await axios.get(
        `${API_URL}/forecast?q=${city}&units=metric&lang=de&appid=${API_KEY}`
      );
      
      setWeather(weatherResponse.data);
      
      // Gruppiere Vorhersagedaten nach Tagen
      const dailyData = forecastResponse.data.list.reduce((acc, item) => {
        const date = new Date(item.dt * 1000).toDateString();
        if (!acc[date]) {
          acc[date] = [];
        }
        acc[date].push(item);
        return acc;
      }, {});
      
      setForecast(Object.values(dailyData).slice(0, 5));
      setLocation(city);
    } catch (err) {
      setError('Stadt nicht gefunden oder API-Fehler. Bitte versuche es erneut.');
      console.error('Fehler beim Abrufen des Wetters:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container mx-auto px-4 py-8 max-w-5xl">
      <h1 className="text-4xl font-bold text-center text-blue-800 mb-8">
        Wetter App
      </h1>
      
      <SearchBar onSearch={fetchWeather} />
      
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mt-4 mb-4">
          {error}
        </div>
      )}
      
      {loading ? (
        <LoadingSpinner />
      ) : (
        <>
          {weather && <WeatherCard weather={weather} />}
          
          {forecast && (
            <div className="mt-8">
              <h2 className="text-2xl font-semibold text-blue-700 mb-4">
                5-Tage-Vorhersage für {location}
              </h2>
              <Forecast forecast={forecast} />
            </div>
          )}
        </>
      )}
    </div>
  );
}

export default App;
EOF

# Erstelle Komponenten
echo -e "${GREEN}Erstelle Komponenten...${NC}"

# WeatherCard.js
echo -e "${GREEN}Erstelle src/components/WeatherCard.js...${NC}"
cat > src/components/WeatherCard.js << 'EOF'
import React from 'react';

function WeatherCard({ weather }) {
  const iconUrl = `https://openweathermap.org/img/wn/${weather.weather[0].icon}@2x.png`;
  
  return (
    <div className="bg-white rounded-lg shadow-lg p-6 mt-6">
      <div className="flex flex-col md:flex-row items-center justify-between">
        <div className="flex items-center mb-4 md:mb-0">
          <img 
            src={iconUrl} 
            alt={weather.weather[0].description} 
            className="w-24 h-24"
          />
          <div className="ml-4">
            <h2 className="text-3xl font-bold">{weather.name}</h2>
            <p className="text-gray-600 capitalize">{weather.weather[0].description}</p>
          </div>
        </div>
        
        <div className="text-center md:text-right">
          <p className="text-5xl font-bold">{Math.round(weather.main.temp)}°C</p>
          <p className="text-gray-600">
            Gefühlt: {Math.round(weather.main.feels_like)}°C
          </p>
        </div>
      </div>
      
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6 text-center">
        <div className="bg-blue-50 p-3 rounded-lg">
          <p className="text-gray-500">Luftfeuchtigkeit</p>
          <p className="text-xl font-semibold">{weather.main.humidity}%</p>
        </div>
        <div className="bg-blue-50 p-3 rounded-lg">
          <p className="text-gray-500">Wind</p>
          <p className="text-xl font-semibold">{Math.round(weather.wind.speed * 3.6)} km/h</p>
        </div>
        <div className="bg-blue-50 p-3 rounded-lg">
          <p className="text-gray-500">Max. Temp.</p>
          <p className="text-xl font-semibold">{Math.round(weather.main.temp_max)}°C</p>
        </div>
        <div className="bg-blue-50 p-3 rounded-lg">
          <p className="text-gray-500">Min. Temp.</p>
          <p className="text-xl font-semibold">{Math.round(weather.main.temp_min)}°C</p>
        </div>
      </div>
    </div>
  );
}

export default WeatherCard;
EOF

# SearchBar.js
echo -e "${GREEN}Erstelle src/components/SearchBar.js...${NC}"
cat > src/components/SearchBar.js << 'EOF'
import React, { useState } from 'react';

function SearchBar({ onSearch }) {
  const [city, setCity] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    if (city.trim()) {
      onSearch(city);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="flex w-full max-w-md mx-auto">
      <input
        type="text"
        value={city}
        onChange={(e) => setCity(e.target.value)}
        placeholder="Stadt eingeben..."
        className="flex-grow px-4 py-2 rounded-l-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
      <button
        type="submit"
        className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-r-lg transition duration-300"
      >
        Suchen
      </button>
    </form>
  );
}

export default SearchBar;
EOF

# Forecast.js
echo -e "${GREEN}Erstelle src/components/Forecast.js...${NC}"
cat > src/components/Forecast.js << 'EOF'
import React from 'react';

function Forecast({ forecast }) {
  // Hilfsfunktion, um den Wochentag zu erhalten
  const getDayName = (dateStr) => {
    const date = new Date(dateStr);
    return date.toLocaleDateString('de-DE', { weekday: 'long' });
  };

  // Hilfsfunktion, um die durchschnittliche Temperatur zu berechnen
  const getAverageTemp = (dayData) => {
    const sum = dayData.reduce((acc, item) => acc + item.main.temp, 0);
    return Math.round(sum / dayData.length);
  };

  // Hilfsfunktion, um das häufigste Wettersymbol zu erhalten
  const getMostFrequentIcon = (dayData) => {
    const iconCount = {};
    dayData.forEach(item => {
      const icon = item.weather[0].icon;
      iconCount[icon] = (iconCount[icon] || 0) + 1;
    });
    
    let mostFrequentIcon = '';
    let maxCount = 0;
    
    Object.entries(iconCount).forEach(([icon, count]) => {
      if (count > maxCount) {
        mostFrequentIcon = icon;
        maxCount = count;
      }
    });
    
    return mostFrequentIcon;
  };

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
      {forecast.map((dayData, index) => {
        const date = new Date(dayData[0].dt * 1000);
        const dayName = getDayName(date);
        const avgTemp = getAverageTemp(dayData);
        const icon = getMostFrequentIcon(dayData);
        const iconUrl = `https://openweathermap.org/img/wn/${icon}@2x.png`;
        const description = dayData[0].weather[0].description;
        
        return (
          <div 
            key={index} 
            className="bg-white rounded-lg shadow-md p-4 flex flex-col items-center"
          >
            <h3 className="font-semibold text-lg mb-2">{dayName}</h3>
            <p className="text-gray-500 text-sm">
              {date.toLocaleDateString('de-DE')}
            </p>
            <img 
              src={iconUrl} 
              alt={description}
              className="w-16 h-16 my-2" 
            />
            <p className="capitalize text-sm text-gray-600 mb-2">{description}</p>
            <p className="text-2xl font-bold">{avgTemp}°C</p>
          </div>
        );
      })}
    </div>
  );
}

export default Forecast;
EOF

# LoadingSpinner.js
echo -e "${GREEN}Erstelle src/components/LoadingSpinner.js...${NC}"
cat > src/components/LoadingSpinner.js << 'EOF'
import React from 'react';

function LoadingSpinner() {
  return (
    <div className="flex justify-center items-center py-12">
      <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
      <p className="ml-3 text-blue-500 font-medium">Lade Wetterdaten...</p>
    </div>
  );
}

export default LoadingSpinner;
EOF

# Erstelle public Ordner und HTML-Datei
echo -e "${GREEN}Erstelle public/index.html...${NC}"
mkdir -p public
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="de">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta
      name="description"
      content="Wetter-App mit React erstellt"
    />
    <title>Wetter App</title>
  </head>
  <body>
    <noscript>Sie müssen JavaScript aktivieren, um diese App zu nutzen.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF

# Erstellung eines README.md mit Anweisungen
echo -e "${GREEN}Erstelle README.md...${NC}"
cat > README.md << 'EOF'
# Wetter-App

Eine einfache Wetter-App, die aktuelle Wetterdaten und eine 5-Tage-Vorhersage anzeigt. Gebaut mit React und Tailwind CSS.

## Installation

1. Installieren Sie die Abhängigkeiten:
   ```
   npm install
   ```

2. Tragen Sie Ihren OpenWeatherMap API-Key in die Datei `src/App.js` ein:
   ```javascript
   const API_KEY = 'DEIN_API_KEY'; // Hier Ihren API-Key eintragen
   ```

3. Starten Sie die Entwicklungsumgebung:
   ```
   npm start
   ```

## Features

- Anzeige des aktuellen Wetters für eine Stadt
- 5-Tage-Wettervorhersage
- Suche nach Städten
- Responsive Design

## API

Diese App verwendet die [OpenWeatherMap API](https://openweathermap.org/api). Sie benötigen einen API-Key, den Sie nach Registrierung auf deren Webseite erhalten.
EOF

# Erstelle .gitignore-Datei
echo -e "${GREEN}Erstelle .gitignore...${NC}"
cat > .gitignore << 'EOF'
# dependencies
/node_modules
/.pnp
.pnp.js

# testing
/coverage

# production
/build

# misc
.DS_Store
.env.local
.env.development.local
.env.test.local
.env.production.local

npm-debug.log*
yarn-debug.log*
yarn-error.log*
EOF

echo -e "${BLUE}=== Setup abgeschlossen ===${NC}"
echo -e "${YELLOW}Um die Wetter-App zu starten:${NC}"
echo "1. Navigiere zum Projektordner: cd weather"
echo "2. Installiere die Abhängigkeiten: npm install"
echo "3. Trage deinen OpenWeatherMap API-Key in src/App.js ein"
echo "4. Starte die App: npm start"
echo ""
echo -e "${GREEN}Viel Spaß mit deiner neuen Wetter-App!${NC}"