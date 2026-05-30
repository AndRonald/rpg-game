<div align="center">

# ⚔️ Expotech Game

Jogo cooperativo local 2D desenvolvido em Godot 4, onde dois jogadores competem para ver quem elimina mais inimigos.

[![Godot](https://img.shields.io/badge/Godot-4.x-blue?style=flat-square&logo=godot-engine)](https://godotengine.org)
[![GDScript](https://img.shields.io/badge/GDScript-language-darkblue?style=flat-square&logo=godot-engine)](https://godotengine.org)
[![Itch.io](https://img.shields.io/badge/Play-Itch.io-red?style=flat-square&logo=itch.io)](https://itch.io)

</div>

---

## Equipe — Grupo Matemáticos

| Nome | RA |
|---|---|
| Pedro Augusto Brito Castilho Pereira | 100954 |
| Ronald Viana Araújo | 102648 |

---

## Sobre o Projeto

Jogo de arena top-down cooperativo local desenvolvido para a **Expotech**, evento acadêmico da FECAF.

Dois jogadores se enfrentam na mesma tela utilizando dois controles USB, competindo para ver quem elimina mais inimigos. Vence quem tiver mais kills ao final.

### Funcionalidades

- Cooperativo/versus local para 2 jogadores na mesma máquina
- Suporte a dois controles USB
- Sistema de combate com animações de idle, run e attack
- Placar de kills por jogador
- Publicado e jogável direto pelo navegador no Itch.io

---

## Como Jogar

Acesse diretamente pelo navegador: **[link do itch.io]**

### Controles

| Ação | Jogador 1 |
|---|---|
| Mover | WASD |
| Atacar | Espaço |

> Suporte a 2 controles USB em breve.

---

## Como Rodar Localmente

**Pré-requisito:** Godot 4.x instalado.

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/expotech-game.git

# 2. Abra o Godot e importe a pasta do projeto

# 3. Pressione F5 para rodar
```

---

## Estrutura do Projeto

```
expotech-game/
├── scenes/
│   ├── main.tscn          ← Cena principal
│   ├── player.tscn        ← Cena do jogador
│   └── enemy.tscn         ← Cena do inimigo
├── scripts/
│   ├── player.gd          ← Lógica do jogador
│   └── enemy.gd           ← Lógica do inimigo
├── assets/
│   ├── sprites/           ← Sprites e animações
│   └── ui/                ← Elementos de interface
└── project.godot          ← Configuração do projeto
```

---

## Tecnologias

| Camada | Tecnologia |
|---|---|
| Engine | Godot 4 |
| Linguagem | GDScript |
| Assets | Tiny Swords (KenneyNL) |
| Publicação | Itch.io (HTML5) |
| Versionamento | Git + GitHub |

---

<div align="center">
  <sub>Projeto acadêmico — Grupo Matemáticos · FECAF · Expotech 2026</sub>
</div>
