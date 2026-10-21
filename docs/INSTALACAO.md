# Instalação no Windows

## Pré-requisitos

PowerShell 5.1 ou superior, Git e OpenSSH Client. Confirme:

```powershell
ssh -V
ssh-keygen -?
git --version
```

Se o OpenSSH Client não estiver instalado, adicione-o nas **Configurações > Sistema > Recursos opcionais** do Windows.

## Instalar

```powershell
git clone https://github.com/thuf86/ssh-confi.git
cd ssh-confi
powershell -NoProfile -ExecutionPolicy Bypass -File .\Configurar-SSH.ps1
```

Informe alias, endereço da VPS, usuário e porta. O assistente gera a chave, cria a configuração e mostra o comando de exportação. Verifique a fingerprint SSH antes de confiar no servidor.

## Conexão

```powershell
ssh portal1
```

Para cadastrar mais servidores, execute o script novamente e escolha outro alias.
