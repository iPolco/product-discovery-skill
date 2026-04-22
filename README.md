# Ultimate Product Discovery Skill

[![Version](https://img.shields.io/badge/version-3.8-blue.svg)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Made for Claude](https://img.shields.io/badge/made%20for-Claude%20Skills-D97706.svg)](https://docs.claude.com/en/docs/agents-and-tools/agent-skills)
[![Requires: Opus](https://img.shields.io/badge/requires-latest%20Claude%20Opus-black.svg)](https://www.anthropic.com/claude)
[![Methodology](https://img.shields.io/badge/methodology-JTBD%20%7C%20OST%20%7C%20Lean-purple.svg)](#методологическая-база)

Claude Skill для проведения структурного Product Discovery по методологии из **18 задач в 6 блоках**. Объединяет Jobs-to-be-Done (Ulwick/Christensen), Opportunity Solution Tree (Teresa Torres), Customer Development (Steve Blank), The Mom Test (Rob Fitzpatrick), Lean Canvas (Ash Maurya), PESTEL, SWOT и Business Model Canvas.

Версия: **3.8** · см. [CHANGELOG.md](CHANGELOG.md)

> ⚡ **Рекомендуемая модель — последний Claude Opus.** Скил использует длинный контекст (суммарно 1500+ строк методологии в references), параллельный вызов tool'ов (web_search + bash + Python), структурное планирование и оценку числовых порогов. Sonnet/Haiku справляются с отдельными задачами, но на сложных блоках (III — Стратегия, IV — Валидация, VI — Артефакты) качество артефактов заметно падает.

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

## Методология: 18 задач в 6 блоках

### Блок I — Анализ рынка (задачи 1–6) · [details](references/block-1-market.md)

1. **Анализ рынка** — классификация (Существующий / Ресегментированный / Новый / Клон), размер, стадия жизненного цикла, структура ценности
2. **Анализ трендов** — 5–7 макро- и микро-трендов с горизонтом 3–5 лет, их влияние на гипотезу
3. **Конкурентный ландшафт** — карта конкурентов (прямые, косвенные, заменители), позиционирование, feature matrix
4. **Анализ ключевого конкурента** — глубокий разбор №1 по рынку: модель, unit-экономика, слабые места
5. **TAM / SAM / SOM** — размер рынка top-down + bottom-up, sanity check, пороги для стадии раунда
6. **PESTEL-анализ** — Political, Economic, Social, Technological, Environmental, Legal факторы

### Блок II — Потребители (задачи 7–9) · [details](references/block-2-customers.md)

7. **Jobs-to-be-Done + Карточки персон** — функциональные / социальные / эмоциональные jobs, Job Map, 2–4 персоны с мотивациями
8. **Customer Journey Map (CJM)** — этапы пути клиента, пейны, каналы, моменты истины
9. **Экспертные интервью + Интервью-гайд** — Mom Test-совместимый гайд на 3 сегмента, таблица инсайтов, красные флаги

### Блок III — Стратегия (задачи 10–14) · [details](references/block-3-strategy.md)

10. **Текущий стратегический сценарий** — Lean Canvas / Business Model Canvas + Product-Audience-Channel fit
11. **SWOT-анализ** — с опорой на конкурентный ландшафт и тренды, не в вакууме
12. **Opportunity Solution Tree (OST)** — дерево возможностей по Teresa Torres: outcome → opportunities → solutions → experiments
13. **Альтернативные сценарии** — 2–3 стратегические альтернативы текущему сценарию
14. **Скоринг сценариев + RICE** — Reach / Impact / Confidence / Effort, итоговый ранкинг

### Блок IV — Валидация (задачи 15–17) · [details](references/block-4-validation.md)

15. **Пул гипотез** — выписать все нефальсифицированные допущения из блоков I–III
16. **Rapid Assumption Testing** — план тестов (Smoke Test, Wizard of Oz, Concierge, Fake Door), критерии успеха
17. **PMF-индикаторы и Opportunity Score** — Sean Ellis test, NPS, retention, Opportunity Score Ulwick'а

### Блок V — Главный сценарий (задача 18a) · [details](references/block-5-main-scenario.md)

18a. **Выбор главного стратегического сценария** — синтез итогов I–IV, параметры для финплана (unit-экономика, каналы, команда, горизонт)

### Блок VI — Артефакты (задачи 18b–d) · [details](references/block-6-artifacts.md)

18b. **One-pager (.pptx)** — 1 слайд для CEO/инвестора: проблема, решение, рынок, трекшн, команда, ask
18c. **Финансовый план (.xlsx)** — P&L / Cash Flow на 12 месяцев + 3 года, drivers, чувствительность
18d. **Презентация (.pptx)** — полная питч-дека Verification-стадии на 21 (Light) или 34 (Full) слайда

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
