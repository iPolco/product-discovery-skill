# Product Discovery Skill

[![Version](https://img.shields.io/badge/version-3.8-blue.svg)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Made for Claude](https://img.shields.io/badge/made%20for-Claude%20Skills-D97706.svg)](https://docs.claude.com/en/docs/agents-and-tools/agent-skills)
[![Methodology](https://img.shields.io/badge/methodology-JTBD%20%7C%20OST%20%7C%20Lean-purple.svg)](#методологическая-база)

Claude Skill для проведения структурного Product Discovery по методологии из **18 задач в 6 блоках**. Объединяет Jobs-to-be-Done (Ulwick/Christensen), Opportunity Solution Tree (Teresa Torres), Customer Development (Steve Blank), The Mom Test (Rob Fitzpatrick), Lean Canvas (Ash Maurya), PESTEL, SWOT и Business Model Canvas.

Версия: **3.8** · см. [CHANGELOG.md](CHANGELOG.md)

## Режимы работы

| Режим | Когда использовать | Время |
|-------|---------------------|-------|
| **Light** | Idea-стадия, нет клиентов | ~45 мин |
| **Full** | Есть MVP и клиенты | ~2–3 ч |
| **Geographic Expansion** | Продукт выходит в новую гео | ~2 ч |

## Артефакты на выходе

Все артефакты складываются в `/mnt/user-data/outputs/`:

- `one-pager-[slug].pptx` — краткая выжимка для CEO/инвестора
- `financial-plan-[slug].xlsx` — финансовая модель
- `presentation-[slug].pptx` — презентация этапа Verification
- `interview-guide-[slug].docx` — гайд для живых интервью (Full-режим, задача 9)

## Структура репозитория

```
.
├── SKILL.md                    # главный файл скила (метаданные + инструкции)
├── CHANGELOG.md
├── assets/                     # шаблоны артефактов
│   ├── one-pager-template.pptx
│   ├── presentation-template.pptx
│   ├── financial-plan-template.xlsx
│   └── interview-guide-template.docx
├── references/                 # детальные инструкции по блокам
│   ├── block-1-market.md       # Блок I — Анализ рынка (задачи 1–6)
│   ├── block-2-customers.md    # Блок II — Потребители (задачи 7–9)
│   ├── block-3-strategy.md     # Блок III — Стратегия (задачи 10–14)
│   ├── block-4-validation.md   # Блок IV — Валидация (задачи 15–17)
│   ├── block-5-main-scenario.md # Блок V — Главный сценарий (18a)
│   ├── block-6-artifacts.md    # Блок VI — Артефакты (18b–d)
│   ├── customer-development.md # альтернативный путь для нового рынка
│   ├── strategic-pivot.md      # путь для действующего бизнеса (pivot)
│   ├── examples.md             # сквозные примеры заполнения холстов
│   ├── glossary.md             # термины PD
│   └── step-0-questions.md     # вопросы шага 0
└── scripts/                    # технические скрипты
    ├── preflight_check.sh
    ├── init_kb.py
    ├── delete_light_slides.py
    ├── reorder_summary_first.py
    ├── add_competitor_comparison_slide.py
    ├── roll_formulas.py
    ├── finalize_pptx.sh
    └── finalize_docx.sh
```

## Установка

### Claude.ai (Skills)

1. Скачай архив репозитория (`Code → Download ZIP`) или клонируй:
   ```bash
   git clone https://github.com/<USER>/product-discovery-skill.git
   ```
2. Загрузи в Claude через **Settings → Capabilities → Skills → Upload skill** (соответствующий пункт UI).
3. Скил триггерится автоматически, когда пользователь описывает задачу Product Discovery — напрямую или косвенно ("оцени идею", "выходим в Таиланд, есть ли рынок", "подготовь презентацию для ангела").

### Локально / кастомный runtime

Помести папку в директорию, которую Claude монтирует как `/mnt/skills/user/`. Главный файл — `SKILL.md`.

## Критические правила безопасности

Скил содержит **6 STOP-GATE правил**, предотвращающих типовые ошибки в продакшене:

1. Фиксация `PD_MODE` перед запуском скриптов
2. Запрет `pack.py --validate false`
3. PowerPoint round-trip (LibreOffice) перед сдачей `.pptx`
4. Раскатка формул в финплане через `roll_formulas.py`
5. Проверка совместимости шаблонов
6. Word round-trip для `.docx` артефактов

Подробно — в `SKILL.md` раздел «Критические правила безопасности».

## Методологическая база

- Anthony Ulwick — *Outcome-Driven Innovation*
- Clayton Christensen — *Jobs to be Done*
- Teresa Torres — *Continuous Discovery Habits*
- Steve Blank — *The Four Steps to the Epiphany*
- Rob Fitzpatrick — *The Mom Test*
- Ash Maurya — *Running Lean*
- Alexander Osterwalder — *Business Model Generation*

## License

MIT — см. [LICENSE](LICENSE).
