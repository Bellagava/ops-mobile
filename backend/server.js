const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const sqlite3 = require('sqlite3').verbose();

const app = express();
const PORT = 8080;

app.use(cors());
app.use(express.json());

// Inicializar banco de dados
const db = new sqlite3.Database('database.db');

db.serialize(() => {
  db.run(`CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    rm TEXT UNIQUE NOT NULL,
    senha TEXT NOT NULL
  )`);
  
  db.run(`CREATE TABLE IF NOT EXISTS Ocorrencia (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    dataOcorrencia DATETIME DEFAULT CURRENT_TIMESTAMP,
    descricao TEXT NOT NULL,
    localidade_id INTEGER NOT NULL,
    statusOcorrencia TEXT NOT NULL,
    usuario_id INTEGER NOT NULL
  )`);
});

// Login
app.post('/api/auth/login', (req, res) => {
  const { rm, senha } = req.body;
  
  db.get('SELECT * FROM users WHERE rm = ?', [rm], async (err, user) => {
    if (err) return res.status(500).json({ error: 'Erro no servidor' });
    if (!user) return res.status(401).json({ error: 'RM não encontrado' });
    
    const validPassword = await bcrypt.compare(senha, user.senha);
    if (!validPassword) return res.status(401).json({ error: 'Senha incorreta' });
    
    res.json({ 
      message: 'Login realizado com sucesso', 
      id: user.id,
      rm: user.rm 
    });
  });
});

// Rota para login de usuário (compatibilidade)
app.post('/usuario/login', (req, res) => {
  const { rm, senha } = req.body;
  
  db.get('SELECT * FROM users WHERE rm = ?', [rm], async (err, user) => {
    if (err) return res.status(500).json({ error: 'Erro no servidor' });
    if (!user) return res.status(401).json({ error: 'RM não encontrado' });
    
    const validPassword = await bcrypt.compare(senha, user.senha);
    if (!validPassword) return res.status(401).json({ error: 'Senha incorreta' });
    
    res.json({ 
      message: 'Login realizado com sucesso', 
      id: user.id,
      rm: user.rm 
    });
  });
});

// Registro
app.post('/api/auth/register', async (req, res) => {
  const { rm, senha } = req.body;
  
  const hashedPassword = await bcrypt.hash(senha, 10);
  
  db.run('INSERT INTO users (rm, senha) VALUES (?, ?)', [rm, hashedPassword], function(err) {
    if (err) {
      if (err.code === 'SQLITE_CONSTRAINT') {
        return res.status(400).json({ error: 'RM já cadastrado' });
      }
      return res.status(500).json({ error: 'Erro no servidor' });
    }
    res.status(201).json({ message: 'Usuário cadastrado com sucesso' });
  });
});

// Rota para buscar localidades
app.get('/localidade/findAll', (req, res) => {
  const localidades = [];
  
  // Coordenação
  localidades.push({ id: 1, nome: 'Coordenação' });
  
  // Térreo com 4 laboratórios
  for (let lab = 1; lab <= 4; lab++) {
    localidades.push({
      id: lab + 1,
      nome: `Térreo - Lab ${lab}`
    });
  }
  
  // 4 andares com 4 laboratórios cada
  for (let andar = 1; andar <= 4; andar++) {
    for (let lab = 1; lab <= 4; lab++) {
      const id = (andar * 10) + lab + 5;
      localidades.push({
        id: id,
        nome: `Andar ${andar} - Lab ${lab}`
      });
    }
  }
  
  res.json(localidades);
});

// Rota para salvar ocorrência
app.post('/ocorrencia', (req, res) => {
  const { localidade_id, descricao, statusOcorrencia, usuario_id } = req.body;
  
  console.log('Dados recebidos:', { localidade_id, descricao, statusOcorrencia, usuario_id });
  
  if (!localidade_id || !descricao || !statusOcorrencia || !usuario_id) {
    return res.status(400).json({ error: 'Todos os campos são obrigatórios' });
  }
  
  db.run(
    'INSERT INTO Ocorrencia (localidade_id, descricao, statusOcorrencia, usuario_id) VALUES (?, ?, ?, ?)',
    [localidade_id, descricao, statusOcorrencia, usuario_id],
    function(err) {
      if (err) {
        console.error('Erro ao inserir ocorrência:', err);
        return res.status(500).json({ error: 'Erro ao salvar ocorrência' });
      }
      console.log('Ocorrência salva com sucesso, ID:', this.lastID);
      res.status(201).json({ 
        message: 'Ocorrência criada com sucesso',
        id: this.lastID 
      });
    }
  );
});

// Rota para salvar ocorrência (compatibilidade)
app.post('/ocorrencia/save', (req, res) => {
  const { localidade_id, descricao, statusOcorrencia, usuario_id } = req.body;
  
  console.log('Dados recebidos:', { localidade_id, descricao, statusOcorrencia, usuario_id });
  
  if (!localidade_id || !descricao || !statusOcorrencia || !usuario_id) {
    return res.status(400).json({ error: 'Todos os campos são obrigatórios' });
  }
  
  db.run(
    'INSERT INTO Ocorrencia (localidade_id, descricao, statusOcorrencia, usuario_id) VALUES (?, ?, ?, ?)',
    [localidade_id, descricao, statusOcorrencia, usuario_id],
    function(err) {
      if (err) {
        console.error('Erro ao inserir ocorrência:', err);
        return res.status(500).json({ error: 'Erro ao salvar ocorrência' });
      }
      console.log('Ocorrência salva com sucesso, ID:', this.lastID);
      res.status(201).json({ 
        message: 'Ocorrência criada com sucesso',
        id: this.lastID 
      });
    }
  );
});

// Rota para buscar ocorrências de um usuário específico
app.get('/usuario/:userId/ocorrencias', (req, res) => {
  const { userId } = req.params;
  
  const query = `
    SELECT o.*, l.nome as localidade_nome, u.rm as usuario_rm
    FROM Ocorrencia o
    LEFT JOIN users u ON o.usuario_id = u.id
    WHERE o.usuario_id = ?
    ORDER BY o.dataOcorrencia DESC
  `;
  
  db.all(query, [userId], (err, rows) => {
    if (err) {
      console.error('Erro ao buscar ocorrências do usuário:', err);
      return res.status(500).json({ error: 'Erro ao buscar ocorrências' });
    }
    
    const ocorrencias = rows.map(row => ({
      id: row.id,
      descricao: row.descricao,
      statusOcorrencia: row.statusOcorrencia,
      dataOcorrencia: row.dataOcorrencia,
      localidade_id: row.localidade_id,
      localidade_nome: row.localidade_nome || `Localidade ${row.localidade_id}`,
      usuario_id: row.usuario_id,
      usuario_rm: row.usuario_rm
    }));
    
    res.json(ocorrencias);
  });
});

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});