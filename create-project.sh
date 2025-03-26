#!/bin/bash

# Farben für Ausgabe
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}TechDocs Projektstruktur wird erstellt...${NC}"

# Hauptverzeichnisse erstellen
mkdir -p techdocs
cd techdocs

# Unterverzeichnisse erstellen
echo -e "${GREEN}Erstelle Verzeichnisstruktur...${NC}"
mkdir -p server/routes server/controllers server/models server/middleware
mkdir -p client/public client/src/components client/src/store
mkdir -p content uploads

# package.json erstellen
echo -e "${GREEN}Erstelle package.json...${NC}"
cat > package.json << 'EOF'
{
  "name": "techdocs",
  "version": "1.0.0",
  "description": "Ein Framework für IT-Dokumentation und Cheat Sheets",
  "main": "server/server.js",
  "scripts": {
    "start": "node server/server.js",
    "dev": "nodemon server/server.js",
    "install-all": "npm install && cd client && npm install",
    "client": "cd client && npm start",
    "server": "nodemon server/server.js",
    "dev-full": "concurrently \"npm run server\" \"npm run client\""
  },
  "keywords": ["documentation", "cheatsheet", "markdown", "knowledge-base"],
  "author": "",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^7.5.0",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "marked": "^9.0.0",
    "highlight.js": "^11.8.0",
    "multer": "^1.4.5-lts.1",
    "morgan": "^1.10.0",
    "helmet": "^7.0.0",
    "compression": "^1.7.4",
    "express-rate-limit": "^6.9.0",
    "jsonwebtoken": "^9.0.1",
    "bcrypt": "^5.1.1",
    "slugify": "^1.6.6"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "concurrently": "^8.2.1"
  }
}
EOF

# server.js erstellen
echo -e "${GREEN}Erstelle server.js...${NC}"
cat > server/server.js << 'EOF'
// Erforderliche Module importieren
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');
const morgan = require('morgan');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const dotenv = require('dotenv');

// Umgebungsvariablen laden
dotenv.config();

// Express-App initialisieren
const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());
app.use(morgan('dev'));
app.use(helmet());
app.use(compression());

// Rate Limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 Minuten
  max: 100 // Limit jede IP auf 100 Anfragen pro Zeitfenster
});
app.use('/api/', limiter);

// Routen importieren
const documentationRoutes = require('./routes/documentation');
const categoryRoutes = require('./routes/categories');
const searchRoutes = require('./routes/search');
const authRoutes = require('./routes/auth');

// Routen verwenden
app.use('/api/docs', documentationRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/search', searchRoutes);
app.use('/api/auth', authRoutes);

// Statische Dateien für Markdown-Content
app.use('/content', express.static(path.join(__dirname, '../content')));

// Frontend im Produktionsmodus bereitstellen
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, '../client/build')));
  
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, '../client/build/index.html'));
  });
}

// MongoDB-Verbindung herstellen
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/techdocs', {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => console.log('MongoDB verbunden'))
.catch(err => console.error('MongoDB Verbindungsfehler:', err));

// Server starten
app.listen(PORT, () => {
  console.log(`Server läuft auf Port ${PORT}`);
});
EOF

# Model-Dateien erstellen
echo -e "${GREEN}Erstelle Model-Dateien...${NC}"

cat > server/models/Document.js << 'EOF'
const mongoose = require('mongoose');
const slugify = require('slugify');

const DocumentSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Bitte einen Titel angeben'],
    trim: true,
    maxlength: [100, 'Titel darf nicht mehr als 100 Zeichen haben']
  },
  slug: {
    type: String,
    unique: true
  },
  content: {
    type: String,
    required: [true, 'Bitte Inhalt angeben']
  },
  contentType: {
    type: String,
    enum: ['markdown', 'html'],
    default: 'markdown'
  },
  category: {
    type: mongoose.Schema.ObjectId,
    ref: 'Category',
    required: [true, 'Bitte eine Kategorie angeben']
  },
  tags: [String],
  createdBy: {
    type: mongoose.Schema.ObjectId,
    ref: 'User'
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  },
  isPublic: {
    type: Boolean,
    default: true
  }
}, {
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Slug vor dem Speichern erstellen
DocumentSchema.pre('save', function(next) {
  this.slug = slugify(this.title, { lower: true });
  next();
});

// Volltextsuche konfigurieren
DocumentSchema.index({
  title: 'text',
  content: 'text',
  tags: 'text'
});

module.exports = mongoose.model('Document', DocumentSchema);
EOF

cat > server/models/Category.js << 'EOF'
const mongoose = require('mongoose');
const slugify = require('slugify');

const CategorySchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Bitte einen Namen angeben'],
    unique: true,
    trim: true,
    maxlength: [50, 'Name darf nicht mehr als 50 Zeichen haben']
  },
  slug: {
    type: String,
    unique: true
  },
  description: {
    type: String,
    maxlength: [500, 'Beschreibung darf nicht mehr als 500 Zeichen haben']
  },
  parentCategory: {
    type: mongoose.Schema.ObjectId,
    ref: 'Category',
    default: null
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtuelle Dokumente (Rückbezug) für Kategorien
CategorySchema.virtual('documents', {
  ref: 'Document',
  localField: '_id',
  foreignField: 'category',
  justOne: false
});

// Slug vor dem Speichern erstellen
CategorySchema.pre('save', function(next) {
  this.slug = slugify(this.name, { lower: true });
  next();
});

module.exports = mongoose.model('Category', CategorySchema);
EOF

cat > server/models/User.js << 'EOF'
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const UserSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Bitte einen Namen angeben']
  },
  email: {
    type: String,
    required: [true, 'Bitte eine E-Mail angeben'],
    unique: true,
    match: [
      /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
      'Bitte eine gültige E-Mail angeben'
    ]
  },
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
  },
  password: {
    type: String,
    required: [true, 'Bitte ein Passwort angeben'],
    minlength: 6,
    select: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Passwort verschlüsseln
UserSchema.pre('save', async function(next) {
  if (!this.isModified('password')) {
    next();
  }
  
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

// JWT Token signieren
UserSchema.methods.getSignedJwtToken = function() {
  return jwt.sign(
    { id: this._id },
    process.env.JWT_SECRET || 'techdocs_jwt_secret',
    { expiresIn: process.env.JWT_EXPIRE || '30d' }
  );
};

// Passwort vergleichen
UserSchema.methods.matchPassword = async function(enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', UserSchema);
EOF

# Controller-Dateien erstellen
echo -e "${GREEN}Erstelle Controller-Dateien...${NC}"

cat > server/controllers/documentationController.js << 'EOF'
const Document = require('../models/Document');
const path = require('path');
const fs = require('fs');
const marked = require('marked');

// Alle Dokumente abrufen
exports.getAllDocuments = async (req, res) => {
  try {
    let query;
    
    // Kopie der Query-Parameter erstellen
    const reqQuery = { ...req.query };
    
    // Felder zum Ausschließen
    const removeFields = ['select', 'sort', 'page', 'limit'];
    removeFields.forEach(param => delete reqQuery[param]);
    
    // Query-String erstellen
    let queryStr = JSON.stringify(reqQuery);
    
    // Operatoren für Filterung hinzufügen ($gt, $gte, etc.)
    queryStr = queryStr.replace(/\b(gt|gte|lt|lte|in)\b/g, match => `$${match}`);
    
    // Query ausführen
    query = Document.find(JSON.parse(queryStr)).populate('category', 'name slug');
    
    // Auswahl spezifischer Felder
    if (req.query.select) {
      const fields = req.query.select.split(',').join(' ');
      query = query.select(fields);
    }
    
    // Sortierung
    if (req.query.sort) {
      const sortBy = req.query.sort.split(',').join(' ');
      query = query.sort(sortBy);
    } else {
      query = query.sort('-createdAt');
    }
    
    // Paginierung
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 10;
    const startIndex = (page - 1) * limit;
    const endIndex = page * limit;
    const total = await Document.countDocuments();
    
    query = query.skip(startIndex).limit(limit);
    
    // Ergebnisse abrufen
    const documents = await query;
    
    // Paginierungsergebnis
    const pagination = {};
    
    if (endIndex < total) {
      pagination.next = {
        page: page + 1,
        limit
      };
    }
    
    if (startIndex > 0) {
      pagination.prev = {
        page: page - 1,
        limit
      };
    }
    
    res.status(200).json({
      success: true,
      count: documents.length,
      pagination,
      data: documents
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};

// Einzelnes Dokument abrufen
exports.getDocument = async (req, res) => {
  try {
    const document = await Document.findById(req.params.id).populate('category', 'name slug');
    
    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Dokument nicht gefunden'
      });
    }
    
    res.status(200).json({
      success: true,
      data: document
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};

// Dokument per Slug abrufen
exports.getDocumentBySlug = async (req, res) => {
  try {
    const document = await Document.findOne({ slug: req.params.slug }).populate('category', 'name slug');
    
    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Dokument nicht gefunden'
      });
    }
    
    // Markdown zu HTML konvertieren, wenn nötig
    if (document.contentType === 'markdown') {
      document.renderedContent = marked.parse(document.content);
    }
    
    res.status(200).json({
      success: true,
      data: document
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};

// Neues Dokument erstellen
exports.createDocument = async (req, res) => {
  try {
    // Benutzer hinzufügen, wenn authentifiziert
    if (req.user) {
      req.body.createdBy = req.user.id;
    }
    
    const document = await Document.create(req.body);
    
    res.status(201).json({
      success: true,
      data: document
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};

// Dokument aktualisieren
exports.updateDocument = async (req, res) => {
  try {
    let document = await Document.findById(req.params.id);
    
    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Dokument nicht gefunden'
      });
    }
    
    // Aktualisierungsdatum setzen
    req.body.updatedAt = Date.now();
    
    document = await Document.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });
    
    res.status(200).json({
      success: true,
      data: document
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};

// Dokument löschen
exports.deleteDocument = async (req, res) => {
  try {
    const document = await Document.findById(req.params.id);
    
    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Dokument nicht gefunden'
      });
    }
    
    await document.remove();
    
    res.status(200).json({
      success: true,
      data: {}
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};

// Markdown-Datei importieren
exports.importMarkdownFile = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ 
        success: false, 
        message: 'Bitte eine Markdown-Datei hochladen' 
      });
    }
    
    const filePath = req.file.path;
    const fileContent = fs.readFileSync(filePath, 'utf8');
    
    // Titel aus dem Dateinamen extrahieren
    const fileName = path.basename(req.file.originalname, path.extname(req.file.originalname));
    const title = fileName.replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
    
    const newDocument = {
      title,
      content: fileContent,
      contentType: 'markdown',
      category: req.body.category,
      tags: req.body.tags ? req.body.tags.split(',') : []
    };
    
    if (req.user) {
      newDocument.createdBy = req.user.id;
    }
    
    const document = await Document.create(newDocument);
    
    // Temporäre Datei löschen
    fs.unlinkSync(filePath);
    
    res.status(201).json({
      success: true,
      data: document
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};
EOF

cat > server/controllers/categoryController.js << 'EOF'
const Category = require('../models/Category');

// Alle Kategorien abrufen
exports.getAllCategories = async (req, res) => {
  try {
    let query;
    
    // Kategorien mit Unterkategorien und Dokumenten abrufen
    if (req.query.populate) {
      query = Category.find().populate({
        path: 'documents',
        select: 'title slug updatedAt'
      });
    } else {
      query = Category.find();
    }
    
    // Nur Hauptkategorien abrufen
    if (req.query.parentOnly === 'true') {
      query = query.where('parentCategory').equals(null);
    }
    
    const categories = await query;
    
    res.status(200).json({
      success: true,
      count: categories.length,
      data: categories
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};

// Einzelne Kategorie abrufen
exports.getCategory = async (req, res) => {
  try {
    const category = await Category.findById(req.params.id).populate({
      path: 'documents',
      select: 'title slug updatedAt'
    });
    
    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Kategorie nicht gefunden'
      });
    }
    
    res.status(200).json({
      success: true,
      data: category
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};

// Kategorie per Slug abrufen
exports.getCategoryBySlug = async (req, res) => {
  try {
    const category = await Category.findOne({ slug: req.params.slug }).populate({
      path: 'documents',
      select: 'title slug updatedAt'
    });
    
    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Kategorie nicht gefunden'
      });
    }
    
    res.status(200).json({
      success: true,
      data: category
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};

// Neue Kategorie erstellen
exports.createCategory = async (req, res) => {
  try {
    const category = await Category.create(req.body);
    
    res.status(201).json({
      success: true,
      data: category
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};

// Kategorie aktualisieren
exports.updateCategory = async (req, res) => {
  try {
    const category = await Category.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });
    
    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Kategorie nicht gefunden'
      });
    }
    
    res.status(200).json({
      success: true,
      data: category
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};

// Kategorie löschen
exports.deleteCategory = async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);
    
    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Kategorie nicht gefunden'
      });
    }
    
    await category.remove();
    
    res.status(200).json({
      success: true,
      data: {}
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};
EOF

cat > server/controllers/searchController.js << 'EOF'
const Document = require('../models/Document');

// Volltextsuche
exports.searchDocuments = async (req, res) => {
  try {
    if (!req.query.q) {
      return res.status(400).json({
        success: false,
        message: 'Bitte einen Suchbegriff angeben'
      });
    }
    
    const query = req.query.q;
    
    const documents = await Document.find({
      $text: { $search: query }
    }, {
      score: { $meta: 'textScore' }
    })
    .select('title slug category tags updatedAt')
    .populate('category', 'name slug')
    .sort({ score: { $meta: 'textScore' } });
    
    res.status(200).json({
      success: true,
      count: documents.length,
      data: documents
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};
EOF

cat > server/controllers/authController.js << 'EOF'
const User = require('../models/User');

// Benutzer registrieren
exports.register = async (req, res) => {
  try {
    const { name, email, password, role } = req.body;
    
    // Benutzer erstellen
    const user = await User.create({
      name,
      email,
      password,
      role
    });
    
    sendTokenResponse(user, 200, res);
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};

// Benutzer anmelden
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Validation
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Bitte E-Mail und Passwort angeben'
      });
    }
    
    // Benutzer suchen
    const user = await User.findOne({ email }).select('+password');
    
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Ungültige Anmeldeinformationen'
      });
    }
    
    // Passwort überprüfen
    const isMatch = await user.matchPassword(password);
    
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Ungültige Anmeldeinformationen'
      });
    }
    
    sendTokenResponse(user, 200, res);
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};

// Token mit Cookie senden
const sendTokenResponse = (user, statusCode, res) => {
  // Token erstellen
  const token = user.getSignedJwtToken();
  
  const options = {
    expires: new Date(Date.now() + process.env.JWT_COOKIE_EXPIRE * 24 * 60 * 60 * 1000 || 30 * 24 * 60 * 60 * 1000),
    httpOnly: true
  };
  
  if (process.env.NODE_ENV === 'production') {
    options.secure = true;
  }
  
  res
    .status(statusCode)
    .cookie('token', token, options)
    .json({
      success: true,
      token
    });
};

// Aktuellen Benutzer abrufen
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    
    res.status(200).json({
      success: true,
      data: user
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message
    });
  }
};

// Abmelden / Cookie löschen
exports.logout = async (req, res) => {
  res.cookie('token', 'none', {
    expires: new Date(Date.now() + 10 * 1000),
    httpOnly: true
  });
  
  res.status(200).json({
    success: true,
    data: {}
  });
};
EOF

# Middleware-Dateien erstellen
echo -e "${GREEN}Erstelle Middleware-Dateien...${NC}"

cat > server/middleware/auth.js << 'EOF'
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Schütze Routen
exports.protect = async (req, res, next) => {
  let token;
  
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    // Token aus dem Header extrahieren
    token = req.headers.authorization.split(' ')[1];
  } else if (req.cookies.token) {
    // Token aus dem Cookie extrahieren
    token = req.cookies.token;
  }
  
  // Prüfen, ob Token existiert
  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Kein Zugriff auf diese Route'
    });
  }
  
  try {
    // Token verifizieren
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'techdocs_jwt_secret');
    
    req.user = await User.findById(decoded.id);
    
    next();
  } catch (err) {
    return res.status(401).json({
      success: false,
      message: 'Kein Zugriff auf diese Route'
    });
  }
};

// Rollen-Autorisierung
exports.authorize = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Die Rolle ${req.user.role} ist nicht berechtigt, auf diese Route zuzugreifen`
      });
    }
    next();
  };
};
EOF

# Routen-Dateien erstellen
echo -e "${GREEN}Erstelle Routen-Dateien...${NC}"

cat > server/routes/documentation.js << 'EOF'
const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');

// Controller-Funktionen importieren
const {
  getAllDocuments,
  getDocument,
  getDocumentBySlug,
  createDocument,
  updateDocument,
  deleteDocument,
  importMarkdownFile
} = require('../controllers/documentationController');

// Authentifizierungs-Middleware importieren
const { protect, authorize } = require('../middleware/auth');

// Multer-Konfiguration für Datei-Uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../../uploads'));
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB max
  fileFilter: (req, file, cb) => {
    // Nur Markdown-Dateien akzeptieren
    if (path.extname(file.originalname).toLowerCase() === '.md') {
      return cb(null, true);
    }
    
    cb(new Error('Nur Markdown-Dateien (.md) sind erlaubt'));
  }
});

// Routen definieren
router
  .route('/')
  .get(getAllDocuments)
  .post(protect, authorize('admin'), createDocument);

router
  .route('/:id')
  .get(getDocument)
  .put(protect, authorize('admin'), updateDocument)
  .delete(protect, authorize('admin'), deleteDocument);

router.get('/slug/:slug', getDocumentBySlug);

router.post(
  '/import',
  protect,
  authorize('admin'),
  upload.single('file'),
  importMarkdownFile
);

module.exports = router;
EOF

cat > server/routes/categories.js << 'EOF'
const express = require('express');
const router = express.Router();

// Controller-Funktionen importieren
const {
  getAllCategories,
  getCategory,
  getCategoryBySlug,
  createCategory,
  updateCategory,
  deleteCategory
} = require('../controllers/categoryController');

// Authentifizierungs-Middleware importieren
const { protect, authorize } = require('../middleware/auth');

// Routen definieren
router
  .route('/')
  .get(getAllCategories)
  .post(protect, authorize('admin'), createCategory);

router
  .route('/:id')
  .get(getCategory)
  .put(protect, authorize('admin'), updateCategory)
  .delete(protect, authorize('admin'), deleteCategory);

router.get('/slug/:slug', getCategoryBySlug);

module.exports = router;
EOF

cat > server/routes/search.js << 'EOF'
const express = require('express');
const router = express.Router();

// Controller-Funktionen importieren
const { searchDocuments } = require('../controllers/searchController');

// Routen definieren
router.get('/', searchDocuments);

module.exports = router;
EOF

cat > server/routes/auth.js << 'EOF'
const express = require('express');
const router = express.Router();

// Controller-Funktionen importieren
const {
  register,
  login,
  getMe,
  logout
} = require('../controllers/authController');

// Authentifizierungs-Middleware importieren
const { protect } = require('../middleware/auth');

// Routen definieren
router.post('/register', register);
router.post('/login', login);
router.get('/me', protect, getMe);
router.get('/logout', logout);

module.exports = router;
EOF

# .env.example erstellen
echo -e "${GREEN}Erstelle .env.example...${NC}"

cat > .env.example << 'EOF'
NODE_ENV=development
PORT=5000
MONGODB_URI=mongodb://localhost:27017/techdocs
JWT_SECRET=dein_geheimer_jwt_schluessel
JWT_EXPIRE=30d
JWT_COOKIE_EXPIRE=30
EOF

# README.md erstellen
echo -e "${GREEN}Erstelle README.md...${NC}"

cat > README.md << 'EOF'
# TechDocs

Ein Node.js-Framework für IT-Dokumentation und Cheat Sheets.

## Funktionen

- Markdown-basierte Dokumentationen und Cheat Sheets
- Kategorisierung und Tagging von Inhalten
- Volltextsuche
- Responsive Benutzeroberfläche
- Benutzerauthentifizierung und Rollenbasierte Zugriffskontrolle
- API-Endpunkte für alle Funktionen

## Installation

1. Repository klonen
   ```
   git clone https://github.com/yourusername/techdocs.git
   cd techdocs
   ```

2. Abhängigkeiten installieren
   ```
   npm install
   ```

3. Umgebungsvariablen konfigurieren
   ```
   cp .env.example .env
   ```
   Anschließend die Werte in der .env-Datei anpassen.

4. Datenbank starten
   Stellen Sie sicher, dass MongoDB auf Ihrem System läuft.

5. Server starten
   ```
   npm run dev
   ```

6. Öffnen Sie http://localhost:5000 in Ihrem Browser

## Verzeichnisstruktur

- server/ - Backend-Code
  - server.js - Hauptserver-Datei
  - routes/ - API-Routen
  - controllers/ - Controller-Logik
  - models/ - Datenbankmodelle
  - middleware/ - Middlewares
- client/ - Frontend-Code
  - public/ - Statische Dateien
  - src/ - React-Frontend
  - components/ - UI-Komponenten
  - styles/ - CSS/SCSS-Dateien
- content/ - Dokumentationsdateien (Markdown)

## API-Dokumentation

### Authentifizierung

- POST /api/auth/register - Neuen Benutzer registrieren
- POST /api/auth/login - Benutzer anmelden
- GET /api/auth/me - Aktuellen Benutzer abrufen
- GET /api/auth/logout - Benutzer abmelden

### Dokumente

- GET /api/docs - Alle Dokumente abrufen
- GET /api/docs/:id - Einzelnes Dokument abrufen
- GET /api/docs/slug/:slug - Dokument per Slug abrufen
- POST /api/docs - Neues Dokument erstellen
- PUT /api/docs/:id - Dokument aktualisieren
- DELETE /api/docs/:id - Dokument löschen
- POST /api/docs/import - Markdown-Datei importieren

### Kategorien

- GET /api/categories - Alle Kategorien abrufen
- GET /api/categories/:id - Einzelne Kategorie abrufen
- GET /api/categories/slug/:slug - Kategorie per Slug abrufen
- POST /api/categories - Neue Kategorie erstellen
- PUT /api/categories/:id - Kategorie aktualisieren
- DELETE /api/categories/:id - Kategorie löschen

### Suche

- GET /api/search?q=suchbegriff - Dokumente durchsuchen

## Lizenz

MIT
EOF

# Installation anbieten
echo -e "${GREEN}Projektstruktur wurde erfolgreich erstellt!${NC}"
echo -e "${YELLOW}Möchten Sie die Abhängigkeiten jetzt installieren? (j/n)${NC}"
read -r installDeps

if [ "$installDeps" = "j" ] || [ "$installDeps" = "J" ]; then
  echo -e "${GREEN}Installiere Abhängigkeiten...${NC}"
  npm install
  
  # .env-Datei erstellen
  cp .env.example .env
  echo -e "${GREEN}Die Datei .env wurde erstellt. Bitte passen Sie die Werte an.${NC}"
  
  echo -e "${GREEN}Installation abgeschlossen!${NC}"
  echo -e "${YELLOW}Sie können den Server jetzt mit 'npm run dev' starten.${NC}"
else
  echo -e "${YELLOW}Um die Abhängigkeiten später zu installieren, führen Sie 'npm install' aus.${NC}"
fi

echo -e "${GREEN}TechDocs wurde erfolgreich eingerichtet!${NC}"
