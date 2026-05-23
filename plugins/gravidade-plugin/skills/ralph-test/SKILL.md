---
name: ralph-test
description: >
  Autonomous TDD loop. Writes tests first, then implements until all tests pass and coverage target is met. Input — description of what to test or spec file. Use for test-first development.
---

# Ralph Loop v2 — Test (TDD)

Loop autonomo de TDD: escreve testes primeiro, depois implementa ate todos passarem.

## Input

O usuario fornece:
- Descricao do que testar: "testes para o modulo de pagamento"
- Arquivo de spec: "seguir spec em TEST_PLAN.md"
- Coverage target opcional: "90% coverage"

## Primeira Iteracao (interativa — VOCE FAZ ISSO AGORA)

### 1. Criar branch (se nao existir)
```bash
git checkout -b test/<descricao-curta>
```

### 2. Analisar o codigo a ser testado

- Leia os modulos/funcoes que precisam de testes
- Identifique edge cases, error paths, happy paths
- Verifique testes existentes (evitar duplicacao)
- Rode testes atuais (baseline)

### 3. Criar state files

Crie o diretorio: `.claude/ralph-state/test-<descricao-slug>/`

**progress.md:**
```markdown
# Progress — Tests: <descricao>

## Test Suites a Criar
- [ ] Suite 1: <modulo/funcao> — happy path
- [ ] Suite 2: <modulo/funcao> — error handling
- [ ] Suite 3: <modulo/funcao> — edge cases
- [ ] ...

## Coverage
- Target: <N>%
- Atual: <baseline>%

## Status
- Total: N suites
- Feitas: 0
- Pendentes: N
```

**journal.md:**
```markdown
# Ralph Journal — Tests: <descricao>

Task: <descricao dos testes>
Tipo: test
Inicio: <data/hora>
Baseline coverage: <N>%
Target coverage: <N>%
```

**prompt.md:**
```markdown
Voce esta em um loop TDD para: <descricao>.

## Fluxo TDD por suite

1. Leia progress.md — identifique a proxima suite pendente
2. **Red**: Escreva os testes da suite (devem FALHAR porque a implementacao pode estar incompleta)
   - Se os testes ja passam (implementacao existente), marque como feito e va pro proximo
3. **Green**: Implemente/corrija o codigo minimo para os testes passarem
4. **Refactor**: Limpe se necessario, mantendo testes verdes
5. Commite:
   - Testes: test(<scope>): add tests for <funcao>
   - Implementacao (se alterou): feat/fix(<scope>): <o que mudou>
6. Atualize progress.md e journal.md
7. Se TODAS as suites [x] E coverage >= target:
   - Output: <promise>DONE</promise>

## Regras
- 1 suite por iteracao
- Testes primeiro, implementacao depois
- Nomes de teste descritivos em 3a pessoa: "returns error when input is null"
- Table-driven tests quando houver variacoes de input/output
- Nunca mock o banco — use testes de integracao quando aplicavel
- Testes devem ser independentes entre si (sem ordem)
```

### 4. Implementar a primeira suite de testes

Siga o fluxo TDD:
1. Escreva os testes (Red)
2. Implemente/corrija o necessario (Green)
3. Refatore (Refactor)
4. Commite
5. Atualize progress.md e journal.md

### 5. Lancar o loop local (In-Session)

Apos completar o primeiro criterio, crie o arquivo `.gemini/ralph-loop.local.md` para iniciar o loop in-session:

```markdown
---
iteration: 1
max_iterations: 10
completion_promise: DONE
task_type: test
task_input: "<DESCRICAO_DO_QUE_TESTAR>"
---
Continue working on writing and passing tests. Output <promise>DONE</promise> when complete.
```

O hook de Stop do Antigravity detectará este arquivo e manterá o agente em loop automático até que você retorne `<promise>DONE</promise>`.

Informe ao usuario:
- "Ralph Loop local de testes ativado"
- "O loop continuará no chat atual até ser finalizado com o envio de <promise>DONE</promise>"
- "Você pode cancelar excluindo o arquivo `.gemini/ralph-loop.local.md`"
