# Changelog

## v3.8 (2026-04-22)

### Added
- **`assets/interview-guide-template.docx`** — универсальный шаблон интервью-гайда с 8 готовыми секциями (как пользоваться гайдом, согласие, 3 гайда по сегментам, таблица инсайтов, красные флаги, шпаргалка по рынку). Плейсхолдеры: {{PROJECT_NAME}}, {{GEO}}, {{SEGMENT_1-3}}, {{PRODUCT_DESCRIPTION}}, {{PRODUCT_CATEGORY}}, {{MONTH_YEAR}}.
- **`scripts/finalize_docx.sh`** — финализация docx-артефактов через LibreOffice round-trip + python-docx верификацию. Гарантирует Word-совместимость.
- **Правило 6 (новое, STOP-GATE)** — Word round-trip для docx-артефактов. Срабатывает перед любым cp *.docx в outputs.

### Changed
- **Раздел «Задача 9» в `references/block-2-customers.md`** — обновлён под использование шаблона и python-docx (вместо docx npm package).
- **Рекомендация по инструментам:** использовать python-docx, не docx npm. Причина: npm-библиотека создаёт файлы с битыми ссылками на стили (~30% параграфов с `style: None`) — LibreOffice и Google Docs их открывают, Word — нет.

### Fixed
- Интервью-гайд теперь надёжно открывается в Microsoft Word. Проблема проявлялась в v3.6-3.7: файлы, сгенерированные через docx npm package, технически валидные для XML-парсера, но отклонялись Word.

---

## v3.7 (2026-04-22)

### Added
- **Режим Geographic Expansion** для продуктов, выходящих в новую гео
- **Таблица лимитов one-pager** в references/block-6-artifacts.md
- **Экспорт PD_MODE** через /home/claude/.pd_env

### Changed
- Правила 3, 4, 5 переписаны в формат STOP-GATE с явными triggers и failure modes
- Шаблон financial-plan-template.xlsx: все 24 упоминания одежных данных заменены на нейтральные "Сегмент 1-4"

---

## v3.6 (предыдущая версия)

- Базовая методология 18 задач / 6 блоков
- Режимы Light и Full
- 5 правил безопасности
