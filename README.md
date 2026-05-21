# Gravidade Github (Configurações Personalizadas para o Antigravity CLI)

Este repositório contém todo o ambiente personalizado de desenvolvimento adaptado para o **Antigravity CLI (agy)** (o assistente de IA baseado no Google Gemini para terminal) e as configurações de dotfiles para PowerShell no Windows.

Ele inclui:
- **43 Skills Customizadas** migradas e refinadas.
- **14 Hooks do Sistema** convertidos e otimizados para execução no Windows.
- **Integração com PowerShell** via Profile, adicionando atalhos inteligentes de bypass de permissão e utilitários.
- **Monitor de Imagens do Clipboard (`clipwatch`)** para colagem rápida de capturas de tela diretamente no chat da IA via `Ctrl+V`.

---

## 📁 Estrutura de Pastas

```text
├── dotfiles/
│   ├── powershell/
│   │   └── Microsoft.PowerShell_profile.ps1 # Profile customizado (aliases, atalhos, clipwatch)
│   └── starship/
│       └── starship.toml                     # Configuração do prompt Starship
├── plugins/
│   └── gravidade-plugin/                     # Plugin principal registrado no agy
│       ├── hooks/                            # Hooks executados no ciclo do agy
│       └── skills/                           # Skills com instruções de contexto
├── setup.ps1                                 # Script automatizado de instalação/vinculação
└── README.md                                 # Instruções de uso e instalação (esta página)
```

---

## 🚀 Como Instalar e Configurar de Novo (Restauração Rápida)

Se você precisar formatar o computador ou instalar essas configurações em uma nova máquina, siga estes passos simples:

### 1. Clonar o Repositório
Clone o repositório na pasta de sua preferência. O padrão configurado no script é `D:\projetos D\Gravidade Github`:

```powershell
git clone https://github.com/kamusmg/gravidadegithub.git "D:\projetos D\Gravidade Github"
```

*(Nota: Se clonar em outro diretório, lembre-se de atualizar o caminho da variável `$RepoDir` na linha 6 do [setup.ps1](file:///D:/projetos%20D/Gravidade%20Github/setup.ps1) antes de executar).*

### 2. Executar o Script de Configuração
Abra o **Windows PowerShell** e execute o script de instalação para vincular o plugin à pasta global do Antigravity CLI (`~/.gemini/config/plugins`) e configurar o profile:

```powershell
# Acesse o diretório
cd "D:\projetos D\Gravidade Github"

# Execute o instalador (caso necessário, libere a política de execução)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup.ps1
```

### 3. Recarregar o Terminal
Recarregue o perfil do PowerShell na janela aberta ou simplesmente feche e abra o terminal de novo:

```powershell
. $PROFILE
```

---

## 🛠️ Recursos e Atalhos Disponíveis

### 1. Bypass de Confirmação de Permissões
Para iniciar o assistente ignorando os avisos de segurança de leitura/escrita de arquivos:
- `yolo -c` (Continua a conversa mais recente no modo YOLO/Bypass).
- `bp` ou `yolo` (Inicia uma nova sessão no modo YOLO/Bypass).
- `by pass permissions on` (O comando completo simulando comportamento clássico).

### 2. Colar Imagens no Chat (`clipwatch`)
Para colar capturas de tela e prints diretamente no chat:
1. Digite no terminal:
   ```powershell
   clipwatch
   ```
2. Tire seu print ou copie qualquer imagem (`Win+Shift+S`).
3. Vá na janela da conversa do assistente e aperte **`Ctrl+V`**. O monitor converterá a imagem automaticamente para o link Markdown `![image](file:///...)` que o Gemini lê localmente.

### 3. Atalhos de Desenvolvedor no PowerShell
- `g` $\rightarrow$ `git`
- `k` $\rightarrow$ `kubectl`
- `h` $\rightarrow$ `helm` *(seguro contra erros de AllScope)*
- `d` $\rightarrow$ `docker`
- `gs` $\rightarrow$ `git status` rápido
- `gl` $\rightarrow$ `git log` formatado de 20 linhas em grafo
- `dps` $\rightarrow$ `docker ps` formatado e limpo
- `aliases` $\rightarrow$ Lista todos os atalhos ativos
