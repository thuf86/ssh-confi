# Solução de problemas

## Permission denied (publickey)
Confira se a chave pública foi adicionada ao `~/.ssh/authorized_keys` do **usuário correto** e se o servidor permite `PubkeyAuthentication`.

## Connection timed out / refused
Confira IP, DNS, porta, regras do firewall e status do serviço SSH.

## Host key verification failed
Não ignore o alerta. Confirme a fingerprint do servidor por outro canal antes de alterar `known_hosts`.

## Diagnóstico detalhado

```powershell
ssh -v portal1
ssh -o BatchMode=yes -o NumberOfPasswordPrompts=0 portal1 "echo SSH_OK"
```

## Alias já existe
O script evita duplicar aliases no arquivo de configuração. Escolha outro nome ou revise manualmente `$HOME\.ssh\config` após criar backup.

## Exportação falhou
Use o comando exibido pelo script e confira se a autenticação por senha está habilitada para a primeira instalação. Nunca envie a chave privada ao servidor.
