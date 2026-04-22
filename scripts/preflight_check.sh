#!/bin/bash
# Pre-flight check для скила product-discovery.
#
# Проверяет, что все нужные инструменты доступны ДО старта PD, чтобы он не упал
# в середине блока 6, когда финплан нужно сохранять в .xlsx.
#
# Usage:
#     bash preflight_check.sh
#
# Выводит список статусов. Если все OK — можно запускать PD. Если что-то ⚠️ —
# читай "Fallback при провале pre-flight" в SKILL.md.

set -u

echo "🔍 Pre-flight check для product-discovery..."
echo ""

# Режим PD (критично — см. SKILL.md, "Критические правила безопасности")
if [ -n "${PD_MODE:-}" ]; then
    case "$PD_MODE" in
        light|full|Light|Full|LIGHT|FULL)
            echo "  ✅ PD_MODE: $PD_MODE"
            ;;
        *)
            echo "  ⚠️  PD_MODE=$PD_MODE — неизвестное значение. Должно быть 'light' или 'full'."
            ;;
    esac
else
    echo "  ⚠️  PD_MODE не установлен — скрипты scripts/delete_light_slides.py откажутся работать"
    echo "      После выбора режима в Шаге 0 выполни: export PD_MODE=light (или full)"
fi

# CLI-утилиты
if command -v extract-text >/dev/null 2>&1; then
    echo "  ✅ extract-text: доступен"
else
    echo "  ⚠️  extract-text: НЕТ — чтение .pptx/.xlsx напрямую через openpyxl/python-pptx"
fi

# LibreOffice — нужен для PowerPoint-совместимости (finalize_pptx.sh)
if command -v libreoffice >/dev/null 2>&1; then
    echo "  ✅ libreoffice: $(libreoffice --version 2>&1 | head -1)"
else
    echo "  🔴 libreoffice: НЕ найден — презентация не пройдёт PowerPoint round-trip"
    echo "      Файл может не открываться в PowerPoint, даже если валиден по OOXML"
fi

# Python и библиотеки
if ! command -v python3 >/dev/null 2>&1; then
    echo "  ❌ python3: НЕ найден — критично, без него финплан и презентация не создаются"
    exit 1
fi
echo "  ✅ python3: $(python3 --version)"

# Импорты проверяем точные — не просто "пакет существует", а рабочий API
python3 -c "from openpyxl import load_workbook" 2>/dev/null \
    && echo "  ✅ openpyxl: рабочий импорт" \
    || echo "  ⚠️  openpyxl: импорт НЕ работает — задача 18c (финплан) невозможна"

python3 -c "from pptx import Presentation" 2>/dev/null \
    && echo "  ✅ python-pptx: рабочий импорт" \
    || echo "  ⚠️  python-pptx: импорт НЕ работает — задачи 18b, 18d (one-pager, презентация) невозможны"

python3 -c "from docx import Document" 2>/dev/null \
    && echo "  ✅ python-docx: рабочий импорт" \
    || echo "  ⚠️  python-docx: импорт НЕ работает — задача 9 выведет гайд в markdown вместо docx"

# Утилиты артефактов
SKILL_ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
echo ""
echo "Утилиты артефактов:"
for f in finalize_pptx.sh roll_formulas.py delete_light_slides.py add_competitor_comparison_slide.py reorder_summary_first.py; do
    if [ -f "$SKILL_ROOT/scripts/$f" ]; then
        echo "  ✅ scripts/$f"
    else
        echo "  ⚠️  scripts/$f отсутствует"
    fi
done

# Шаблоны
echo ""
echo "Шаблоны:"
if [ -d "$SKILL_ROOT/assets" ]; then
    MISSING=0
    for f in one-pager-template.pptx presentation-template.pptx financial-plan-template.xlsx; do
        if [ -f "$SKILL_ROOT/assets/$f" ]; then
            echo "  ✅ assets/$f"
        else
            echo "  ⚠️  assets/$f НЕ найден"
            MISSING=$((MISSING + 1))
        fi
    done
    if [ "$MISSING" -gt 0 ]; then
        echo "  ⚠️  Отсутствует $MISSING шаблон(а) — PD завершится без соответствующего артефакта"
    fi
else
    echo "  ❌ Папка $SKILL_ROOT/assets не найдена — критично"
fi

echo ""
echo "Pre-flight готов. Если есть ⚠️ — см. SKILL.md, раздел \"Fallback при провале pre-flight\"."
echo "Если есть 🔴 — это критические проблемы, исправь перед стартом PD."

