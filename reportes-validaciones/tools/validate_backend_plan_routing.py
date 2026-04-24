from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class RoutingSignals:
    backend_type: str | None
    template: str | None
    standards: str | None


def _extract_field(markdown: str, field_name: str) -> str | None:
    pattern = rf"^\*\*{re.escape(field_name)}\*\*:\s*(.+?)\s*$"
    match = re.search(pattern, markdown, flags=re.IGNORECASE | re.MULTILINE)
    return match.group(1).strip() if match else None


def _normalize_backend_type(value: str) -> str | None:
    normalized = value.strip().lower()
    if normalized == "api":
        return "API"
    if normalized == "listener":
        return "Listener"
    return None


def _backend_type_from_template(template: str) -> str | None:
    normalized = template.strip().lower()
    if "lanacion.core.templates.web.api.minimal".lower() in normalized:
        return "API"
    if "ln-sqslstnr".lower() in normalized:
        return "Listener"
    return None


def _backend_type_from_standards(standards: str) -> str | None:
    normalized = standards.strip().lower()
    if "ln-susc-api-standards.mdc".lower() in normalized:
        return "API"
    if "ln-susc-listener-standards.mdc".lower() in normalized:
        return "Listener"
    return None


def _infer_backend_type(signals: RoutingSignals) -> tuple[str | None, list[str]]:
    detected: list[tuple[str, str]] = []

    if signals.backend_type:
        kind = _normalize_backend_type(signals.backend_type)
        if kind:
            detected.append(("Backend Type", kind))

    if signals.template:
        kind = _backend_type_from_template(signals.template)
        if kind:
            detected.append(("Template", kind))

    if signals.standards:
        kind = _backend_type_from_standards(signals.standards)
        if kind:
            detected.append(("Standards", kind))

    kinds = {kind for _, kind in detected}
    sources = [source for source, _ in detected]

    if not detected:
        return None, []

    if len(kinds) > 1:
        return "CONFLICT", sources

    return detected[0][1], sources


def _agent_for_backend_type(backend_type: str) -> str:
    if backend_type == "API":
        return "lanacion-api-developer"
    if backend_type == "Listener":
        return "lanacion-lstnr-developer"
    raise ValueError(f"Unsupported backend type: {backend_type}")


def validate_plan(plan_path: Path) -> int:
    markdown = plan_path.read_text(encoding="utf-8")
    signals = RoutingSignals(
        backend_type=_extract_field(markdown, "Backend Type"),
        template=_extract_field(markdown, "Template"),
        standards=_extract_field(markdown, "Standards"),
    )

    inferred, sources = _infer_backend_type(signals)

    if inferred is None:
        print(f"{plan_path}: ERROR: No routing signals found.")
        print("  Expected at least one of: **Backend Type**, **Template**, **Standards**")
        return 2

    if inferred == "CONFLICT":
        print(f"{plan_path}: ERROR: Conflicting routing signals detected.")
        print(f"  Present signals: {', '.join(sources)}")
        print(f"  Backend Type: {signals.backend_type!r}")
        print(f"  Template: {signals.template!r}")
        print(f"  Standards: {signals.standards!r}")
        return 3

    agent = _agent_for_backend_type(inferred)
    print(f"{plan_path}: OK")
    print(f"  Backend Type: {inferred} (sources: {', '.join(sources)})")
    print(f"  Agent: {agent}")
    return 0


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("Usage: python tools/validate_backend_plan_routing.py <plan1.md> [plan2.md ...]")
        return 1

    exit_code = 0
    for arg in argv[1:]:
        rc = validate_plan(Path(arg))
        exit_code = max(exit_code, rc)
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))

