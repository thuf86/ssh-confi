#Requires -Version 5.1
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
function Ask([string]$Prompt,[string]$Default='') {
  $value = Read-Host ($Prompt + $(if ($Default) {" [$Default]"} else {""}))
  if ([string]::IsNullOrWhiteSpace($value)) { return $Default }
  return $value.Trim()
}
function Assert-Exit([string]$Action) {
  if ($LASTEXITCODE -ne 0) { throw "$Action falhou (codigo $LASTEXITCODE)." }
}
try {
  foreach ($tool in @('ssh','ssh-keygen')) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) { throw "OpenSSH nao encontrado: $tool" }
  }
  $aliasName = Ask 'Alias SSH (ex.: portal1)'
  if ($aliasName -cnotmatch '^[a-zA-Z][a-zA-Z0-9_-]{0,39}$') { throw 'Alias invalido.' }
  $server = Ask 'IP ou dominio da VPS'
  if ($server -notmatch '^[a-zA-Z0-9][a-zA-Z0-9.:-]{0,252}$') { throw 'Host invalido.' }
  $username = Ask 'Usuario SSH' 'root'
  if ($username -notmatch '^[a-zA-Z_][a-zA-Z0-9_.-]*$') { throw 'Usuario invalido.' }
  $portString = Ask 'Porta SSH' '22'
  [int]$port = 0
  if (-not [int]::TryParse($portString,[ref]$port) -or $port -lt 1 -or $port -gt 65535) { throw 'Porta invalida.' }
  $sshDir = Join-Path $HOME '.ssh'
  New-Item -ItemType Directory -Force -Path $sshDir | Out-Null
  $config = Join-Path $sshDir 'config'
  $key = Join-Path $sshDir "id_ed25519_$aliasName"
  if (Test-Path $config) {
    $existing = Get-Content -Raw $config
    foreach ($line in ($existing -split "\r?\n")) {
      if ($line -match '^\s*Host\s+(.+)$') {
        $tokens = $Matches[1] -split '\s+'
        if ($tokens -contains $aliasName) { throw "Alias '$aliasName' ja existe. Nenhum arquivo foi alterado." }
      }
    }
  }
  if ((Test-Path $key) -xor (Test-Path "$key.pub")) { throw 'Par de chaves incompleto; corrija antes de continuar.' }
  if (-not (Test-Path $key)) {
    Write-Host 'Gerando chave Ed25519...' -ForegroundColor Cyan
    & ssh-keygen -t ed25519 -a 100 -f $key -N '' -C "$aliasName@$server"
    Assert-Exit 'Geracao da chave'
  } else { Write-Host 'Reutilizando chave existente.' -ForegroundColor Yellow }
  $block = @"

# ssh-confi: $aliasName
Host $aliasName
    HostName $server
    User $username
    Port $port
    IdentityFile ~/.ssh/id_ed25519_$aliasName
    IdentitiesOnly yes
    PreferredAuthentications publickey
    ServerAliveInterval 30
    ServerAliveCountMax 3
"@
  if (Test-Path $config) {
    $backup = "$config.bak-$(Get-Date -Format yyyyMMdd-HHmmss-fff)"
    Copy-Item $config $backup -ErrorAction Stop
    Write-Host "Backup: $backup"
  }
  Add-Content -Path $config -Value $block -Encoding ascii
  Write-Host "\nFingerprint da chave publica:"
  & ssh-keygen -lf "$key.pub"
  $remote = 'umask 077; mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys; chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys; while IFS= read -r key; do grep -qxF "$key" ~/.ssh/authorized_keys || printf "%s\n" "$key" >> ~/.ssh/authorized_keys; done'
  $manual = 'Get-Content -Raw "{0}" | ssh -p {1} {2}@{3} ''{4}''' -f "$key.pub",$port,$username,$server,$remote
  Write-Host "\nComando para exportar a chave publica para a VPS:" -ForegroundColor Cyan
  Write-Host $manual
  if ((Ask 'Instalar chave publica agora? (S/N)' 'S') -match '^[sS]') {
    Write-Host 'Confira a fingerprint do servidor antes de aceitar a conexao. Digite a senha SSH uma ultima vez, se solicitada.' -ForegroundColor Yellow
    Get-Content -Raw "$key.pub" | & ssh -o PreferredAuthentications=publickey,password,keyboard-interactive -p $port "$username@$server" $remote
    if ($LASTEXITCODE -ne 0) { Write-Warning 'Exportacao nao confirmada. Utilize o comando acima.' }
  }
  Write-Host "\nTestando acesso sem senha..." -ForegroundColor Cyan
  & ssh -o BatchMode=yes -o ConnectTimeout=10 -o NumberOfPasswordPrompts=0 $aliasName 'printf SSH_OK'
  if ($LASTEXITCODE -ne 0) { throw 'Teste sem senha falhou. Confira authorized_keys, sshd, rede e permissoes. Nao desative senha no servidor.' }
  Write-Host "\nSUCESSO. Acesse com: ssh $aliasName" -ForegroundColor Green
  Write-Host 'ATENCAO: chave privada sem passphrase. Proteja o computador e nunca publique ~/.ssh.'
} catch {
  Write-Error $_.Exception.Message
  exit 1
}
