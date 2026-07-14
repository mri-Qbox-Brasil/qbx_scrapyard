# qbx_scrapyard — Manual

Ferro-velho: uma lista rotativa de veículos aceitos é sorteada pelo servidor, e o jogador desmancha esses veículos na zona de entrega em troca de materiais.

---

## Sumário

1. [Dependências](#dependências)
2. [Instalação](#instalação)
3. [Configuração](#configuração)
4. [Fluxo de uso](#fluxo-de-uso)
5. [Lista de veículos](#lista-de-veículos)
6. [Recompensas](#recompensas)
7. [Integrações](#integrações)
8. [Entrypoints para outros recursos](#entrypoints-para-outros-recursos)
9. [Localização](#localização)
10. [Estrutura de arquivos](#estrutura-de-arquivos)

---

## Dependências

| Recurso | Obrigatório | Observação |
|---|---|---|
| `qbx_core` | Sim | `GetPlayer`, `Notify`, `GetVehiclesByName` (marca/modelo no e-mail), módulo `lib` |
| `ox_lib` | Sim | Locale, `lib.zones`, `lib.progressBar`, `lib.callback`, `lib.playAnim` |
| `oxmysql` | Sim | Consulta a tabela `player_vehicles` para bloquear veículos de jogadores |
| `ox_inventory` | Sim | Entrega dos materiais (`AddItem`) |
| `ox_target` | Não | Cria o NPC e a interação de e-mail quando a convar `UseTarget` está em `true` |
| `qb-phone` | Não | Recebe o e-mail com a lista de veículos aceitos |

---

## Instalação

1. Copie a pasta `qbx_scrapyard` para `resources/`.
2. Adicione ao `server.cfg`:
   ```
   ensure qbx_scrapyard
   ```
3. Cadastre no `ox_inventory` os itens de recompensa: `metalscrap`, `plastic`, `copper`, `iron`, `aluminum`, `steel`, `glass` e `rubber`.
4. **Conflitos** — o recurso declara `provide 'qb-scrapyard'`. Não rode junto com o `qb-scrapyard`.

Não há SQL próprio; a tabela `player_vehicles` já faz parte do QBox.

---

## Configuração

### `config/client.lua`

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `useTarget` | bool | Sim | Lido da convar `UseTarget`. `true` cria um NPC com `ox_target` para pedir a lista; `false` usa zona com tecla `E` |
| `debugPoly` | bool | Sim | Desenha as zonas para depuração |
| `useBlips` | bool | Sim | Cria os blips das duas localizações |
| `locations.main.coords` | vec4 | Sim | Onde o jogador pede a lista de veículos (e onde o NPC é criado no modo target) |
| `locations.main.blipName` | string | Sim | Nome do blip. Padrão: `Scrap Yard` |
| `locations.main.blipIcon` | number | Sim | Sprite do blip. Padrão: `380` |
| `locations.main.pedModel` | string | Sim | Modelo do NPC criado quando `useTarget = true`. Padrão: `a_m_m_hillbilly_01` |
| `locations.deliver.coords` | vec3 | Sim | Zona de entrega onde o veículo é desmanchado |
| `locations.deliver.blipName` | string | Sim | Nome do blip. Padrão: `Scrap Yard Delivery` |
| `locations.deliver.blipIcon` | number | Sim | Sprite do blip. Padrão: `810` |

### `config/server.lua`

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `items` | array de strings | Sim | Pool de materiais sorteados a cada veículo desmanchado |
| `vehicles` | array de strings | Sim | Pool de modelos (spawn names) de onde a lista rotativa é sorteada. Precisa ter pelo menos 40 modelos distintos |

> A geração da lista sorteia 40 modelos **distintos**. Se o pool tiver menos de 40 modelos únicos, o laço não termina — mantenha o `vehicles` com pelo menos 40 entradas diferentes.

---

## Fluxo de uso

1. O jogador vai até `locations.main` e pede a lista de veículos aceitos (tecla `E` ou target no NPC).
2. Após 15 a 20 segundos, chega um e-mail com marca e modelo de todos os veículos da lista atual.
3. Ele leva um veículo da lista até a zona de entrega (`locations.deliver`), no banco do motorista, e pressiona `E`.
4. Uma barra de progresso de 28 a 37 segundos roda com a animação de mecânico.
5. Ao terminar, o servidor apaga o veículo, credita os materiais e remove aquele modelo da lista.

O código recusa a operação se: o jogador não é o motorista, o modelo não está na lista atual, ou a placa existe na tabela `player_vehicles` (veículo de jogador).

---

## Lista de veículos

O servidor sorteia 40 modelos distintos do pool `vehicles`, envia a lista para todos os clientes e a regenera **a cada 60 minutos** (`SetInterval`). A primeira geração acontece 2 segundos após o start do recurso, e cada jogador que loga recebe a lista atual.

Desmanchar um veículo remove aquele modelo da lista até a próxima rotação.

---

## Recompensas

Por veículo desmanchado:

- De 2 a 4 sorteios em `items`, cada um com 25 a 45 unidades.
- 1/8 de chance de receber de 10 a 20 unidades de `rubber` (o item bônus está fixo no código do servidor, não vem do config).

---

## Integrações

### ox_target

Com a convar `UseTarget` em `true`, o recurso cria o NPC `pedModel` em `locations.main` e adiciona a opção de pedir a lista por e-mail. Sem target, a mesma ação fica numa zona com `[E]`. A zona de entrega usa `lib.zones.box` com `[E]` nos dois modos.

### qb-phone

A lista de veículos é enviada via `qb-phone:server:sendNewMail`, com remetente, assunto e corpo vindos do locale (`email.*`). Sem o `qb-phone`, o evento não é tratado e o jogador só recebe a notificação de "e-mail enviado".

---

## Entrypoints para outros recursos

### Callback `qbx_scrapyard:server:checkVehicleOwner`

Retorna `true` se a placa existe na tabela `player_vehicles`.

```lua
-- cliente
local isOwned = lib.callback.await('qbx_scrapyard:server:checkVehicleOwner', false, plate)
```

### Eventos internos

| Evento | Lado | Descrição |
|---|---|---|
| `qbx_scrapyard:client:setNewVehicles` | Cliente | Recebe a lista atual de veículos aceitos |
| `qbx_scrapyard:server:scrapVehicle` | Servidor | Recebe o índice na lista e o netId do veículo; apaga o veículo e credita os materiais |

---

## Localização

Strings via `ox_lib` locale, em `locales/`:

`en`, `pt-br`, `pt`, `es`, `fr`, `nl`, `de`, `cs`, `tr`

Idioma ativo pela convar:

```
setr ox:locale "pt-br"
```

Os nomes dos blips vêm do `config/client.lua`, não do locale.

---

## Estrutura de arquivos

```
qbx_scrapyard/
├── client/
│   └── main.lua          — blips, zonas/NPC, validação do veículo, animação e barra de progresso
├── server/
│   └── main.lua          — geração da lista rotativa, callback de propriedade, entrega dos materiais
├── config/
│   ├── client.lua        — localizações, blips, NPC e modo de interação
│   └── server.lua        — pool de materiais e pool de veículos
├── locales/
│   ├── en.json
│   └── cs / de / es / fr / nl / pt / pt-br / tr .json
└── fxmanifest.lua
```
