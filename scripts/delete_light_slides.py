#!/usr/bin/env python3
"""Удалить слайды, не актуальные в Light-режиме PD.

Light-режим пропускает задачи 2, 4, 6, 8, 9, 13, 15, 16, 17, поэтому соответствующие
слайды презентации (5, 6, 8, 9, 12, 13, 26-32) остаются без данных. Этот скрипт
удаляет их и помечает обновление оглавления как задачу для агента.

Usage:
    export PD_MODE=light   # обязательно установить режим
    python3 delete_light_slides.py <path-to-presentation.pptx>

Входные и выходные файлы совпадают — скрипт модифицирует файл на месте.

⚠️ Скрипт ОТКАЖЕТСЯ работать в Full-режиме (PD_MODE=full) без флага --force.
   Это защита: в Full-режиме нужны все 34 слайда для инвестора.
"""
import sys
import os
from pathlib import Path

# ═══════════════════════════════════════════════════════════════════════════
# Защита режима — предотвращает потерю 13 слайдов в Full-режиме
# ═══════════════════════════════════════════════════════════════════════════
_mode = os.environ.get("PD_MODE", "").lower()
_force = "--force" in sys.argv

if _mode == "full" and not _force:
    print("🔴 ОТКАЗ: PD_MODE=full, а этот скрипт — только для Light.")
    print()
    print("В Full-режиме презентация должна содержать все 34 слайда,")
    print("включая тренды, PESTEL, CJM, альтернативный сценарий, PMF.")
    print()
    print("Если режим установлен по ошибке — переустанови: export PD_MODE=light")
    print("Если точно нужно удалить слайды в Full — передай --force, но ты")
    print("потеряешь 13 слайдов, которые нужны инвестору.")
    sys.exit(2)

if _mode not in ("light", "full"):
    print("⚠️  PD_MODE не установлен.")
    print()
    print("Этот скрипт требует явной установки режима, чтобы избежать ошибок:")
    print("    export PD_MODE=light   # для Light-режима (45 мин)")
    print("    export PD_MODE=full    # для Full-режима (2-3 часа, не запускай этот скрипт)")
    print()
    print("См. references/step-0-questions.md, раздел 'Финальный шаг'.")
    sys.exit(3)

# Убираем --force из argv чтобы не мешал sys.argv[1]
if _force:
    sys.argv = [a for a in sys.argv if a != "--force"]

try:
    from pptx import Presentation
except ImportError:
    print("❌ Нужна библиотека python-pptx. Установить: pip install python-pptx")
    sys.exit(1)

# Слайды, которые становятся пустыми в Light (нумерация с 1, для презентации из 34 слайдов):
# 5, 6 — тренды и Value Chain (задача 2)
# 9 — ключевой конкурент (задача 4)  [был 8 до вставки слайда сравнения конкурентов]
# 10 — PESTEL (задача 6)
# 13 — CJM (задача 8)
# 14 — инсайты интервью (задача 9)
# 27-30 — раздел 05: альтернативный сценарий и пул гипотез (задачи 13-16)
# 31-33 — раздел 06 кроме финальных шагов (задача 17)
# Слайд 8 (Сравнение конкурентов) — НЕ удаляется в Light, так как задача 3 выполняется
LIGHT_SKIP_SLIDES_1BASED = [5, 6, 9, 10, 13, 14, 27, 28, 29, 30, 31, 32, 33]


def delete_light_slides(pptx_path: str) -> int:
    """Удалить пустые Light-слайды из презентации. Возвращает число удалённых."""
    prs = Presentation(pptx_path)
    # python-pptx индексирует слайды с 0, поэтому конвертируем
    skip_indices = sorted({i - 1 for i in LIGHT_SKIP_SLIDES_1BASED}, reverse=True)

    xml_slides = prs.slides._sldIdLst
    slides = list(xml_slides)
    deleted = 0
    for i in skip_indices:
        if 0 <= i < len(slides):
            xml_slides.remove(slides[i])
            deleted += 1

    prs.save(pptx_path)
    return deleted


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(1)

    path = Path(sys.argv[1])
    if not path.exists():
        print(f"❌ Файл не найден: {path}")
        sys.exit(1)

    n = delete_light_slides(str(path))
    total_left = 34 - n  # 34 — стандартное число слайдов в шаблоне (с учётом слайда сравнения конкурентов)
    print(f"✅ Удалено {n} слайдов. Осталось: {total_left}.")
    print("⚠️  Не забудь обновить слайд 2 (Содержание) — он теперь ссылается на удалённые страницы.")
