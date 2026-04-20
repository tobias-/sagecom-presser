#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${SCAD_REGRESSION_DIR:-$ROOT_DIR/.scad-regression}"
BASE_DIR="$WORK_DIR/baseline"
CAND_DIR="$WORK_DIR/candidate"
DIFF_DIR="$WORK_DIR/diff"

BASE_CASES_FILE="${SCAD_BASELINE_CASES_FILE:-$ROOT_DIR/tests/scad_cases_baseline.tsv}"
CAND_CASES_FILE="${SCAD_CANDIDATE_CASES_FILE:-$ROOT_DIR/tests/scad_cases_candidate.tsv}"

usage() {
    cat <<'EOF'
Usage:
  tools/scad_regression.sh baseline
  tools/scad_regression.sh compare
  tools/scad_regression.sh all

What it does:
  baseline  Generate baseline STL outputs from tests/scad_cases_baseline.tsv
  compare   Generate candidate STL outputs and compare against baseline using
            symmetric geometric difference (A-B) U (B-A)
  all       Run baseline then compare

Notes:
  - Candidate cases are read from tests/scad_cases_candidate.tsv
  - If a label is missing in candidate file, baseline case mapping is used
EOF
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Missing required command: $1" >&2
        exit 1
    }
}

load_cases() {
    local file="$1"
    local -n labels_ref="$2"
    local -n file_ref="$3"
    local -n render_ref="$4"
    local -n defs_ref="$5"

    [[ -f "$file" ]] || {
        echo "Case file not found: $file" >&2
        exit 1
    }

    while IFS=$'\t' read -r label scad_file render_name defs; do
        label="${label//$'\r'/}"
        scad_file="${scad_file//$'\r'/}"
        render_name="${render_name//$'\r'/}"
        defs="${defs//$'\r'/}"

        [[ -z "$label" ]] && continue
        [[ "${label:0:1}" == "#" ]] && continue

        labels_ref+=("$label")
        file_ref["$label"]="$scad_file"
        render_ref["$label"]="$render_name"
        defs_ref["$label"]="${defs:-}"
    done < "$file"
}

render_case() {
    local scad_rel="$1"
    local render_name="$2"
    local defs="$3"
    local out_file="$4"

    local scad_abs="$ROOT_DIR/$scad_rel"
    [[ -f "$scad_abs" ]] || {
        echo "SCAD file not found for case: $scad_rel" >&2
        exit 1
    }

    local cmd=(openscad -q -o "$out_file")

    if [[ -n "$render_name" && "$render_name" != "-" ]]; then
        cmd+=(-D "part_to_render=\"$render_name\"")
    fi

    [[ "$defs" == "-" ]] && defs=""
    IFS=';' read -r -a defs_arr <<< "$defs"
    for d in "${defs_arr[@]}"; do
        [[ "$d" == "-" ]] && continue
        [[ -n "$d" ]] || continue
        cmd+=(-D "$d")
    done

    cmd+=("$scad_abs")
    "${cmd[@]}"
}

compare_meshes() {
    local label="$1"
    local baseline_stl="$2"
    local candidate_stl="$3"

    local diff_scad="$WORK_DIR/tmp_${label}_diff.scad"
    local diff_stl="$DIFF_DIR/${label}_diff.stl"
    local diff_log="$DIFF_DIR/${label}_diff.log"

    cat > "$diff_scad" <<EOF
union() {
    difference() {
        import("$baseline_stl");
        import("$candidate_stl");
    }
    difference() {
        import("$candidate_stl");
        import("$baseline_stl");
    }
}
EOF

    set +e
    local output
    output="$(openscad -o "$diff_stl" "$diff_scad" 2>&1)"
    local rc=$?
    set -e

    printf '%s\n' "$output" > "$diff_log"

    if grep -q "Current top level object is empty" "$diff_log"; then
        echo "PASS $label"
        return 0
    fi

    if [[ $rc -ne 0 ]]; then
        echo "FAIL $label (OpenSCAD error; see $diff_log)" >&2
        return 1
    fi

    echo "FAIL $label (non-empty geometric diff: $diff_stl)" >&2
    return 1
}

run_baseline() {
    mkdir -p "$BASE_DIR" "$WORK_DIR"
    rm -f "$BASE_DIR"/*.stl 2>/dev/null || true

    local -a labels=()
    declare -A files=()
    declare -A renders=()
    declare -A defs=()
    load_cases "$BASE_CASES_FILE" labels files renders defs

    for label in "${labels[@]}"; do
        local out="$BASE_DIR/${label}.stl"
        render_case "${files[$label]}" "${renders[$label]}" "${defs[$label]}" "$out"
        echo "BASELINE $label -> $out"
    done
}

run_compare() {
    mkdir -p "$CAND_DIR" "$DIFF_DIR" "$WORK_DIR"
    rm -f "$CAND_DIR"/*.stl "$DIFF_DIR"/*.stl "$DIFF_DIR"/*.log "$WORK_DIR"/tmp_*_diff.scad 2>/dev/null || true

    local -a base_labels=()
    declare -A base_files=()
    declare -A base_renders=()
    declare -A base_defs=()
    load_cases "$BASE_CASES_FILE" base_labels base_files base_renders base_defs

    local -a cand_labels=()
    declare -A cand_files=()
    declare -A cand_renders=()
    declare -A cand_defs=()
    load_cases "$CAND_CASES_FILE" cand_labels cand_files cand_renders cand_defs

    local fail_count=0
    for label in "${base_labels[@]}"; do
        local baseline_stl="$BASE_DIR/${label}.stl"
        [[ -f "$baseline_stl" ]] || {
            echo "Baseline STL missing for '$label'. Run: tools/scad_regression.sh baseline" >&2
            exit 1
        }

        local scad_file="${cand_files[$label]:-${base_files[$label]}}"
        local render_name="${cand_renders[$label]:-${base_renders[$label]}}"
        local defs="${cand_defs[$label]:-${base_defs[$label]}}"
        local candidate_stl="$CAND_DIR/${label}.stl"

        render_case "$scad_file" "$render_name" "$defs" "$candidate_stl"

        if ! compare_meshes "$label" "$baseline_stl" "$candidate_stl"; then
            fail_count=$((fail_count + 1))
        fi
    done

    if [[ $fail_count -gt 0 ]]; then
        echo "Regression check FAILED ($fail_count case(s) differ)." >&2
        exit 1
    fi

    echo "Regression check PASSED."
}

main() {
    require_cmd openscad

    local mode="${1:-}"
    case "$mode" in
        baseline)
            run_baseline
            ;;
        compare)
            run_compare
            ;;
        all)
            run_baseline
            run_compare
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"
