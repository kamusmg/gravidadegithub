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
├── _lixo/                                        # Backups de segurança de modificações locais
├── dotfiles/
│   ├── powershell/
│   │   └── Microsoft.PowerShell_profile.ps1 # Profile customizado (aliases, atalhos, clipwatch)
│   └── starship/
│       └── starship.toml                     # Configuração do prompt Starship
├── plugins/
│   └── gravidade-plugin/                     # Plugin principal registrado no agy
│       ├── hooks/                            # Hooks executados no ciclo do agy
│       └── skills/                           # Skills com instruções de contexto
├── setup.ps1                                 # Script automatizado de instalação/vinculação (portátil)
└── README.md                                 # Instruções de uso e instalação (esta página)
```

---

## 🚀 Como Instalar e Configurar de Novo (Restauração Rápida)

Se você precisar formatar o computador ou instalar essas configurações em uma nova máquina, siga estes passos simples:

### 1. Clonar o Repositório
Clone o repositório na pasta de sua preferência. O instalador agora é portátil e detecta o diretório de execução automaticamente. Exemplo de clonagem padrão:

```powershell
git clone https://github.com/kamusmg/gravidadegithub.git "D:\projetos D\Gravidade Github"
```

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

### 2. Colar Imagens no Chat e Terminal (`clipwatch` / `start-print`)
Existem duas formas de colar capturas de tela como links Markdown (`![image](file:///...)`):

* **Atalho no Desktop (Mais Prático! 🖥️):**
  - Use o atalho **`Toggle ClipWatch`** criado na sua Área de Trabalho para ativar e desativar o monitoramento com apenas dois cliques.
  - Ao ativar, prints copiados são convertidos para Markdown (ideal para colar no chat da IA via `Ctrl+V`).
  - Ao desativar, seu clipboard volta ao normal, permitindo colar imagens normais no Windows (Discord, Slack, Paint, etc.).
  - Um popup na tela de 2 segundos avisará o status atual do monitoramento.

* **Dentro do chat (Modo Comando/Terminal):**
  1. Digite no terminal antes de iniciar a IA:
     ```powershell
     clipwatch
     # ou
     start-print
     # ou
     print
     ```
  2. Tire seu print ou copie qualquer imagem (`Win+Shift+S`).
  3. Vá no chat do assistente e aperte **`Ctrl+V`**. A imagem será convertida e colada automaticamente.

* **Diretamente no prompt do PowerShell (Atalho local):**
  - Copie uma imagem para a área de transferência.
  - No prompt de comando do PowerShell (fora do chat), pressione **`Alt+V`**. O link Markdown apontando para o arquivo salvo localmente será inserido na posição atual do seu cursor.

### 3. Atalhos de Desenvolvedor no PowerShell
- `g` $\rightarrow$ `git`
- `k` $\rightarrow$ `kubectl`
- `h` $\rightarrow$ `helm` *(seguro contra erros de AllScope)*
- `d` $\rightarrow$ `docker`
- `gs` $\rightarrow$ `git status` rápido
- `gl` $\rightarrow$ `git log` formatado de 20 linhas em grafo
- `dps` $\rightarrow$ `docker ps` formatado e limpo
- `aliases` $\rightarrow$ Lista todos os atalhos ativos

### 4. Automação de Tarefas com o Ralph (Custom Skills)
O ambiente conta com o ecossistema de automação **Ralph** registrado como **Custom Skills** (como `ralph-implement`, `ralph-test`, `ralph-review`, etc.).

* **Flexibilidade de Tarefas:** A skill `ralph-implement` foi estendida para aceitar tanto tickets do Jira (ex: `CC-1234`) quanto descrições de tarefas genéricas em texto livre (ex: *"Ralph, implemente a funcionalidade X..."*). Isso permite utilizar o loop de TDD do Ralph em qualquer tipo de projeto ou repositório.
* **Como ativar:** Não é necessário digitar comandos complexos. Basta pedir em linguagem de conversação no chat do assistente:
  * *"Quero implementar com o Ralph no card CC-1234"* ou *"Ralph, implemente a funcionalidade X"*
  * *"Executa o teste Ralph"*
  * *"Revisa as alterações com o Ralph"*
* **Como cancelar:** Se precisar abortar ou cancelar uma execução do Ralph em andamento, você pode pedir a qualquer momento no chat:
  * *"Cancela o Ralph"* (aciona a skill `ralph-cancel`).

### 5. Comandos Especiais no Chat (Slash Commands)
Dentro do chat do Antigravity CLI (`agy`), você pode utilizar os seguintes comandos iniciando com `/` para controle de fluxo e sessões:

*   **/rename "\<Novo Nome>"** (ou **/title**): Renomeia a conversa ativa atual para um nome descritivo (ex: `/rename "Gravidade Github"`). Isso facilita encontrar e continuar a sessão depois.
*   **/switch** (ou **/resume**): Abre a lista interativa de conversas salvas no seu histórico para você alternar ou continuar outra sessão.
*   **/goal "\<objetivo>"**: Inicia um modo de tarefa de longo prazo. A IA planejará e executará as ações de forma autônoma e profunda, sem parar até atingir o objetivo proposto.
*   **/schedule**: Configura uma tarefa recorrente (cron) ou um timer de execução única em segundo plano.
*   **/grill-me**: Abre uma sessão interativa de perguntas e respostas para refinar a arquitetura e tomar decisões de design de um plano de implementação.

