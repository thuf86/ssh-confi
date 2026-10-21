# Segurança SSH

- **Nunca compartilhe chaves privadas** nem arquivos de `~/.ssh` em repositórios.
- A primeira conexão deve verificar a fingerprint do host por canal confiável.
- A chave Ed25519 é exclusiva por alias e o arquivo `config` é copiado antes de alteração.
- A versão atual cria chaves sem passphrase para uso não interativo. Isso aumenta o impacto de roubo do dispositivo; use criptografia de disco e controles de acesso.
- Para servidores críticos, use chaves com passphrase e `ssh-agent`, preferencialmente com contas de menor privilégio.
- Não desabilite autenticação por senha ou acesso administrativo antes de confirmar um método de recuperação.
- O script não modifica firewall nem configuração do daemon SSH remoto.
- Se a chave for comprometida, remova sua linha de `~/.ssh/authorized_keys` na VPS e gere outra chave.
