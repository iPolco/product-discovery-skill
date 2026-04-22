#!/bin/bash
# Финализация презентации — единая команда с гарантией PowerPoint-совместимости.
#
# Выполняет три шага:
# 1. pack.py с полной валидацией (БЕЗ --validate false!)
# 2. PowerPoint round-trip через LibreOffice (Microsoft Impress Office Open XML filter)
# 3. Верификация через python-pptx — что файл действительно открывается
#
# Usage:
#     bash scripts/finalize_pptx.sh /path/to/unpacked-dir /path/to/output.pptx /path/to/original.pptx
#
# Где:
#   unpacked-dir — папка с unpacked/ppt/... (результат unpack.py)
#   output.pptx  — финальный файл (обычно /mnt/user-data/outputs/presentation-[slug].pptx)
#   original.pptx — оригинальный шаблон (для --original в pack.py)

set -e

UNPACKED="$1"
OUTPUT="$2"
ORIGINAL="$3"

if [ -z "$UNPACKED" ] || [ -z "$OUTPUT" ] || [ -z "$ORIGINAL" ]; then
    echo "Usage: bash finalize_pptx.sh <unpacked-dir> <output.pptx> <original.pptx>"
    exit 1
fi

if [ ! -d "$UNPACKED" ]; then
    echo "❌ Unpacked directory not found: $UNPACKED"
    exit 1
fi

# Проверка наличия LibreOffice
if ! command -v libreoffice >/dev/null 2>&1; then
    echo "🔴 LibreOffice не найден — PowerPoint-совместимость не гарантирована."
    echo "   Файл будет создан только через pack.py, без round-trip."
    echo "   Установи LibreOffice для максимальной надёжности."
    NO_LIBREOFFICE=1
fi

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

STEP1="$TMPDIR/step1.pptx"

echo "=== Шаг 1: pack.py с полной валидацией ==="
# Путь к pack.py из pptx-skill
PACK_PY="/mnt/skills/public/pptx/scripts/office/pack.py"
if [ ! -f "$PACK_PY" ]; then
    # Fallback: поиск pack.py
    PACK_PY=$(find / -name "pack.py" -path "*pptx*" 2>/dev/null | head -1)
    if [ -z "$PACK_PY" ]; then
        echo "🔴 pack.py не найден. Проверь установку pptx skill."
        exit 1
    fi
fi

if ! python3 "$PACK_PY" "$UNPACKED" "$STEP1" --original "$ORIGINAL" 2>&1; then
    echo ""
    echo "🔴 pack.py не прошёл валидацию."
    echo ""
    echo "Типичные причины:"
    echo "  1. Дублированные ссылки на notesSlides — после запуска"
    echo "     add_competitor_comparison_slide.py. Запусти его снова —"
    echo "     он теперь содержит встроенную чистку."
    echo "  2. Отсутствующие rels. Проверь что все слайды, на которые"
    echo "     ссылается presentation.xml, существуют как файлы."
    echo ""
    echo "См. references/block-6-artifacts.md раздел 'Troubleshooting pack.py'."
    echo ""
    echo "НИКОГДА не используй --validate false — файл не откроется в PowerPoint."
    exit 1
fi

echo "✅ pack.py прошёл валидацию"

if [ "$NO_LIBREOFFICE" = "1" ]; then
    # Без LibreOffice — просто копируем результат pack.py
    cp "$STEP1" "$OUTPUT"
    echo "⚠️  Скопирован без LibreOffice round-trip (может не открыться в PowerPoint)"
else
    echo ""
    echo "=== Шаг 2: LibreOffice round-trip ==="
    timeout 60 libreoffice --headless --convert-to pptx "$STEP1" \
        --outdir "$TMPDIR/lo/" 2>&1 | tail -2

    LO_OUTPUT="$TMPDIR/lo/$(basename "$STEP1")"
    if [ ! -f "$LO_OUTPUT" ]; then
        echo "🔴 LibreOffice конвертация не дала файл."
        echo "   Проверь установку LibreOffice: libreoffice --version"
        exit 1
    fi

    cp "$LO_OUTPUT" "$OUTPUT"
    echo "✅ LibreOffice round-trip — файл пересоздан через"
    echo "   Microsoft Impress Office Open XML filter"
fi

echo ""
echo "=== Шаг 3: Верификация через python-pptx ==="
python3 - <<PYEOF
import sys
try:
    from pptx import Presentation
    p = Presentation("$OUTPUT")
    import os
    size_kb = os.path.getsize("$OUTPUT") / 1024
    print(f"✅ python-pptx открывает файл")
    print(f"   Слайдов: {len(p.slides)}")
    print(f"   Размер:  {size_kb:.1f} KB")
    # Проверим что нет незаполненных плейсхолдеров
    import subprocess, re
    result = subprocess.run(['extract-text', "$OUTPUT"], capture_output=True, text=True)
    if result.returncode == 0:
        placeholders = re.findall(r'\[[^\]]{1,80}\]', result.stdout)
        real = [p for p in placeholders if not any(x in p for x in ['✅','⚠️','🔴','🟠','🟡','🟢'])]
        if real:
            print(f"   ⚠️  Найдены незаполненные плейсхолдеры: {len(real)}")
            for p in real[:5]:
                print(f"      - {p}")
        else:
            print(f"   ✅ Незаполненных плейсхолдеров нет")
except Exception as e:
    print(f"🔴 python-pptx не может открыть файл: {e}")
    sys.exit(1)
PYEOF

echo ""
echo "🎉 Файл готов: $OUTPUT"
