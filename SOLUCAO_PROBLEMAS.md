# Guia de Solução de Problemas - Ocorrências

## Problema: Não consegue apertar o botão para enviar ocorrência

### Possíveis Causas e Soluções:

#### 1. **Servidor Backend não está rodando**
**Solução:**
1. Abra o terminal na pasta `backend`
2. Execute: `npm start`
3. Verifique se aparece a mensagem: "Servidor rodando na porta 3000"

**Ou use o script automático:**
- Execute o arquivo `start_server.bat`

#### 2. **Problemas de Conexão**
**Teste rápido:**
1. Abra o arquivo `test_server.html` no navegador
2. Clique em "Testar Conexão"
3. Se der erro, o servidor não está funcionando

#### 3. **Problemas no Flutter**
**Teste com a versão simplificada:**
1. Execute: `flutter run lib/test_ocorrencia.dart`
2. Teste a funcionalidade na versão simplificada

#### 4. **Campos obrigatórios não preenchidos**
**Verifique se:**
- Uma localidade foi selecionada
- A descrição do problema foi preenchida
- O usuário está logado

#### 5. **Problemas de CORS (Cross-Origin)**
**Se estiver testando no navegador:**
- O backend já tem CORS configurado
- Verifique se está usando `http://localhost:3000`

### Logs de Debug

O código foi atualizado com logs de debug. Verifique no console:
- "Enviando ocorrência: [dados]"
- "Response status: [código]"
- "Response body: [resposta]"

### Verificação do Banco de Dados

O banco já tem dados salvos (15 ocorrências encontradas), então o problema não é no banco.

### Passos para Resolver:

1. **Primeiro:** Inicie o servidor backend
   ```bash
   cd backend
   npm start
   ```

2. **Segundo:** Teste a conexão
   - Abra `test_server.html` no navegador
   - Clique em "Testar Conexão"

3. **Terceiro:** Se a conexão funcionar, teste no Flutter
   ```bash
   flutter run lib/test_ocorrencia.dart
   ```

4. **Quarto:** Se o teste funcionar, o problema está na tela principal
   - Use a versão atualizada em `lib/occorrencia.dart`

### Melhorias Implementadas:

1. ✅ Controle de loading no botão
2. ✅ Prevenção de múltiplos cliques
3. ✅ Logs de debug detalhados
4. ✅ Melhor tratamento de erros
5. ✅ Indicador visual de carregamento
6. ✅ Rota de localidades no backend

### Se ainda não funcionar:

1. Verifique se o Flutter tem permissão para fazer requisições HTTP
2. Confirme se não há firewall bloqueando a porta 3000
3. Teste em um dispositivo físico em vez do emulador
4. Verifique se há algum antivírus bloqueando as conexões

### Contato para Suporte:

Se o problema persistir, forneça:
1. Mensagens de erro no console
2. Sistema operacional
3. Versão do Flutter
4. Se está usando emulador ou dispositivo físico