# SSH-CONFI — Configurador SSH para VPS

Automatize a criação de chaves SSH, configure aliases no Windows e acesse suas VPS Linux sem digitar a senha do servidor a cada conexão.

## Funcionalidades
- Chave Ed25519 exclusiva para cada alias, sem sobrescrever chaves existentes.
- Configuração automática de `~/.ssh/config` e backup do arquivo anterior.
- Exportação assistida da chave **pública** para `authorized_keys`, sem duplicação.
- Verificação de autenticação SSH sem senha antes de declarar sucesso.
- Mensagens de diagnóstico e comando manual de instalação da chave.

## Requisitos

Windows com PowerShell 5.1+ e OpenSSH Client (`ssh` e `ssh-keygen`). Na VPS, é necessário SSH acessível, um usuário autorizado e autenticação por chave pública habilitada. Para a primeira exportação, normalmente será solicitada a senha SSH.

## Instalar e executar

Abra o PowerShell:

```powershell
git clone https://github.com/thuf86/ssh-confi.git
cd ssh-confi
powershell -NoProfile -ExecutionPolicy Bypass -File .\Configurar-SSH.ps1
```

Responda às perguntas: alias (`portal1`), IP ou domínio, usuário SSH (`root` ou outro) e porta (`22` por padrão).

## Exportar chave para o servidor

O próprio script mostra um comando adaptado ao servidor e oferece instalação automática. Exemplo manual, substituindo os dados de exemplo:

```powershell
Get-Content -Raw "$HOME\.ssh\id_ed25519_portal1.pub" | ssh -p 22 root@203.0.113.10 'umask 077; mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys; chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys; while IFS= read -r key; do grep -qxF "$key" ~/.ssh/authorized_keys || printf "%s\n" "$key" >> ~/.ssh/authorized_keys; done'
```

O IP `203.0.113.10` é ilustrativo. Confirme a fingerprint do host antes de aceitar a conexão. Informe a senha do usuário SSH quando solicitada, uma única vez para autorizar a instalação da chave pública.

## Acessar sem senha

```powershell
ssh portal1
```

Teste explícito:

```powershell
ssh -o BatchMode=yes -o NumberOfPasswordPrompts=0 portal1 "echo SSH_OK"
```

Para diagnosticar falhas: `ssh -v portal1`. Verifique IP, porta, firewall, `PubkeyAuthentication`, usuário e permissões do `authorized_keys`.

## Segurança e limitações

A chave **privada** fica no computador local; nunca a publique no GitHub nem a copie para a VPS. A chave é gerada sem passphrase para permitir autenticação não interativa, o que exige proteção rigorosa do computador. Para maior segurança, prefira passphrase e `ssh-agent`. O script não modifica o `sshd_config` nem desativa autenticação por senha: faça isso somente após validar o acesso e um método de recuperação. O acesso depende das permissões e configurações reais do servidor.

## Arquivos
- [Configurar-SSH.ps1](./Configurar-SSH.ps1) — assistente interativo.
- [.gitignore](./.gitignore) — proteção contra publicação acidental de chaves.
