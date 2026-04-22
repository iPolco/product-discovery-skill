#!/usr/bin/env python3
"""Инициализировать Knowledge Base для нового PD.

Создаёт /home/claude/pd-knowledge-base.md с правильным frontmatter:
skill-version, project-name, mode, created. Предотвращает оставление плейсхолдера
"Режим: [Light / Full / GeoExpansion]" незаполненным.

Также создаёт /home/claude/.pd_env с экспортом PD_MODE — для корректной работы
скриптов из Правила 1 SKILL.md (delete_light_slides.py и др.):

    source /home/claude/.pd_env

Usage:
    python3 init_kb.py --project "TimeTag" --mode Light
    python3 init_kb.py --project "My Startup" --mode Full --output /home/claude/pd-kb.md
    python3 init_kb.py --project "Bittrace Thailand" --mode GeoExpansion
"""
import argparse
import sys
from datetime import datetime
from pathlib import Path

SKILL_VERSION = "3.7"

TEMPLATE = """# PD Knowledge Base — {project}
skill-version: {version}
created: {date}
updated: {date}
mode: {mode}

## Журнал выполнения (инкрементальный)

_После каждой задачи дописывай сюда запись. Формат:_
_### [Дата, время] — Задача N: [название] — done|partial|blocked_
_- 3–5 ключевых находок_

---

## Блок I: Рынок (полное резюме)
_Заполняется после завершения блока I._

## Блок II: Потребители
_Заполняется после завершения блока II._

## Блок III: Стратегия
_Заполняется после завершения блока III._

## Блок IV: Гипотезы
_Заполняется после завершения блока IV._

## Блок V: Главный сценарий
_Заполняется после задачи 18a._

## Статус
- Последняя завершённая задача: —
- Последний завершённый блок: —
- Следующий шаг: начать с Задачи 1 (Анализ рынка)
"""

# Для GeoExpansion — дополнительная секция home-geo baseline
GEO_EXPANSION_EXTRA = """

## Home-geo baseline (только для Geographic Expansion)
_Заполни в Шаге 0 перед стартом Блока I:_
- Home-geo: [страна/регион, где продукт уже работает]
- Платящих клиентов в home-geo: [количество]
- ARR в home-geo: [сумма]
- Когда запущен в home-geo: [месяц/год]
- Ключевые метрики home-geo: LTV=[X], CAC=[Y], retention=[Z]%
- Почему переходим в новую гео: [ключевая гипотеза]
- Новая гео (target): [страна/регион]
- Multi-geo roadmap: [список следующих гео с оценкой SAM, если есть]
"""


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--project", required=True, help="Название проекта")
    ap.add_argument("--mode", required=True,
                    choices=["Light", "Full", "GeoExpansion"],
                    help="Режим работы: Light / Full / GeoExpansion")
    ap.add_argument("--output", default="/home/claude/pd-knowledge-base.md",
                    help="Путь к KB-файлу (default: /home/claude/pd-knowledge-base.md)")
    ap.add_argument("--env-output", default="/home/claude/.pd_env",
                    help="Путь к env-файлу (default: /home/claude/.pd_env)")
    args = ap.parse_args()

    output_path = Path(args.output)
    if output_path.exists():
        print(f"Warning: file {output_path} already exists. Overwrite? [y/N] ", end="")
        if input().strip().lower() != "y":
            print("Cancelled.")
            sys.exit(0)

    content = TEMPLATE.format(
        project=args.project,
        version=SKILL_VERSION,
        date=datetime.now().strftime("%Y-%m-%d %H:%M"),
        mode=args.mode,
    )
    if args.mode == "GeoExpansion":
        content += GEO_EXPANSION_EXTRA

    output_path.write_text(content, encoding="utf-8")
    print(f"Knowledge Base created: {output_path}")
    print(f"  Project: {args.project}")
    print(f"  Mode: {args.mode}")

    env_path = Path(args.env_output)
    env_content = f"""# PD environment -- created {datetime.now().strftime('%Y-%m-%d %H:%M')}
# Source this file before running scripts from SKILL.md Rule 1:
#   source {args.env_output}
#
# This protects delete_light_slides.py from running in Full/GeoExpansion mode
# (which would delete 13 needed slides).

export PD_MODE={args.mode}
export PD_PROJECT="{args.project}"
"""
    env_path.write_text(env_content, encoding="utf-8")
    print(f"Environment created: {env_path}")
    print(f"  Before running scripts, execute: source {env_path}")


if __name__ == "__main__":
    main()
