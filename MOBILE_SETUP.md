# Configuração para Mobile

## Problema Resolvido ✅

O problema era que `localhost:3000` não funciona no mobile. Agora o app detecta automaticamente:

- **Emulador Android**: Usa `10.0.2.2:3000`
- **Simulador iOS**: Usa `localhost:3000`
- **Dispositivo Físico**: Precisa do IP da sua máquina

## Para Dispositivo Físico

Se estiver usando um celular real, descubra o IP da sua máquina:

1. **Windows**: `ipconfig` no cmd
2. **Procure por**: IPv4 Address (ex: 192.168.1.100)
3. **Edite**: `lib/config/api_config.dart`
4. **Altere**: `return 'http://SEU_IP:3000';`

## Teste Rápido

1. Inicie o servidor: `npm start` na pasta backend
2. Execute o app: `flutter run`
3. Teste criar uma ocorrência

## Se ainda não funcionar

- Verifique se o servidor está rodando
- Confirme se o firewall não está bloqueando
- Teste com o IP da máquina em vez de localhost