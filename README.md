# 🔐 SSH-CONFI

**Gerenciador SSH para VPS Linux — Windows / PowerShell**

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-2671BE?logo=powershell&logoColor=white) ![OpenSSH](https://img.shields.io/badge/OpenSSH-Ed25519-2E7D32) ![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D4?logo=windows) ![Licença MIT](https://img.shields.io/badge/Licen%C3%A7a-MIT-yellow)

O **SSH-CONFI** configura aliases SSH, gera chaves exclusivas e orienta a instalação da chave pública no servidor para acesso sem digitar a senha a cada conexão.

## ✨ Funcionalidades

- Cadastro interativo de VPS: alias, IP/domínio, usuário e porta.
- Geração de chave Ed25519 por servidor, preservando chaves existentes.
- Configuração de `$HOME\.ssh\config` com backup automático.
- Exportação assistida da chave pública para `authorized_keys`.
- Teste de autenticação por chave sem solicitar senha.
- Diagnóstico de falhas, sem alterar configurações de segurança do servidor.

## 🚀 Instalação rápida

**Requisitos:** Windows, PowerShell 5.1+ e OpenSSH Client; Git para clonar o projeto.

```powershell
git clone https://github.com/thuf86/ssh-confi.git
cd ssh-confi
powershell -NoProfile -ExecutionPolicy Bypass -File .\Configurar-SSH.ps1
```

Exemplo de respostas: alias `portal1`, endereço `203.0.113.10` (ilustrativo), usuário `root`, porta `22`. Confirme a identidade do servidor antes de aceitar sua chave de host.

## 🔑 Exportação da chave pública

O script apresenta um comando pronto e pergunta se deseja executar a exportação. A senha SSH poderá ser solicitada **uma última vez**. Exemplo manual (substitua usuário e IP):

```powershell
Get-Content -Raw "$HOME\.ssh\id_ed25519_portal1.pub" | ssh -p 22 root@203.0.113.10 'umask 077; mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys; chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys; while IFS= read -r key; do grep -qxF "$key" ~/.ssh/authorized_keys || printf "%s\n" "$key" >> ~/.ssh/authorized_keys; done'
```

**Nunca exporte a chave privada.** Somente o arquivo `.pub` deve ser enviado ao servidor.

## 💻 Conexão

```powershell
ssh portal1
```

Para testar sem prompt de senha:

```powershell
ssh -o BatchMode=yes -o NumberOfPasswordPrompts=0 portal1 "echo SSH_OK"
```

## 📁 Estrutura do repositório

```text
ssh-confi/
├── Configurar-SSH.ps1
├── README.md
├── LICENSE
├── .gitignore
└── docs/
    ├── INSTALACAO.md
    ├── SEGURANCA.md
    └── SOLUCAO-DE-PROBLEMAS.md
```

## 📚 Documentação

- [Instalação e execução](docs/INSTALACAO.md)
- [Segurança e boas práticas](docs/SEGURANCA.md)
- [Solução de problemas](docs/SOLUCAO-DE-PROBLEMAS.md)

## 🛡️ Segurança

As chaves são geradas sem passphrase para permitir conexão não interativa. Proteja o computador e considere `ssh-agent` com passphrase para servidores sensíveis. Não desative login por senha na VPS até confirmar acesso alternativo e recuperação. A operação real depende das permissões, rede e configuração SSH do servidor.

## 📄 Licença

Distribuído sob a [Licença MIT](LICENSE).
