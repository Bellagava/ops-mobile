const sqlite3 = require('sqlite3').verbose();
const http = require('http');

console.log('🔍 TESTE DE CONECTIVIDADE - BANCO, BACKEND E FRONTEND\n');

// 1. Teste do Banco de Dados
console.log('1️⃣ TESTANDO BANCO DE DADOS...');
const db = new sqlite3.Database('./backend/database.db', (err) => {
  if (err) {
    console.log('❌ Erro ao conectar com o banco:', err.message);
    return;
  }
  console.log('✅ Conexão com banco SQLite estabelecida');
  
  // Verificar tabelas
  db.all("SELECT name FROM sqlite_master WHERE type='table'", [], (err, rows) => {
    if (err) {
      console.log('❌ Erro ao listar tabelas:', err.message);
      return;
    }
    console.log('📋 Tabelas encontradas:', rows.map(row => row.name).join(', '));
    
    // Contar registros
    db.get("SELECT COUNT(*) as count FROM users", [], (err, row) => {
      if (err) {
        console.log('❌ Erro ao contar usuários:', err.message);
      } else {
        console.log(`👥 Usuários cadastrados: ${row.count}`);
      }
    });
    
    db.get("SELECT COUNT(*) as count FROM Ocorrencia", [], (err, row) => {
      if (err) {
        console.log('❌ Erro ao contar ocorrências:', err.message);
      } else {
        console.log(`📝 Ocorrências registradas: ${row.count}`);
      }
    });
  });
});

// 2. Teste do Backend (servidor)
console.log('\n2️⃣ TESTANDO BACKEND...');
const testBackend = () => {
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/localidade/findAll',
    method: 'GET'
  };

  const req = http.request(options, (res) => {
    console.log('✅ Backend respondendo na porta 3000');
    console.log(`📊 Status: ${res.statusCode}`);
    
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      try {
        const localidades = JSON.parse(data);
        console.log(`🏢 Localidades disponíveis: ${localidades.length}`);
      } catch (e) {
        console.log('⚠️ Resposta não é JSON válido');
      }
    });
  });

  req.on('error', (err) => {
    console.log('❌ Backend não está rodando:', err.message);
    console.log('💡 Execute: cd backend && npm start');
  });

  req.setTimeout(5000, () => {
    console.log('❌ Timeout - Backend não respondeu em 5 segundos');
    req.destroy();
  });

  req.end();
};

setTimeout(testBackend, 1000);

// 3. Informações do Frontend
console.log('\n3️⃣ CONFIGURAÇÃO DO FRONTEND...');
console.log('📱 Framework: Flutter');
console.log('🌐 URLs configuradas:');
console.log('   - Android: http://10.0.2.2:3000');
console.log('   - iOS: http://localhost:3000');
console.log('   - Web/Desktop: http://localhost:3000');

console.log('\n📋 DEPENDÊNCIAS FLUTTER:');
console.log('   ✅ http: ^1.1.0 (requisições HTTP)');
console.log('   ✅ sqflite: ^2.3.0 (banco local)');
console.log('   ✅ shared_preferences: ^2.2.2 (sessão)');

console.log('\n🔧 PARA TESTAR COMPLETAMENTE:');
console.log('1. Inicie o backend: cd backend && npm start');
console.log('2. Abra test_server.html no navegador');
console.log('3. Execute o app Flutter');

setTimeout(() => {
  db.close();
  process.exit(0);
}, 3000);