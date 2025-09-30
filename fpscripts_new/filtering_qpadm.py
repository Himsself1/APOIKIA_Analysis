import argparse
import os
import re
import sys
import pandas as pd
from collections import defaultdict

FNAME_RE = re.compile(
    r"""^more_proximate_(?P<ways>\d+)_way_mix_(?P<pop>.+?)_"""
    r"""(?P<kind>accepted_and_feasible|full_results)\.tsv$""",
    re.IGNORECASE,
)

def guess_read_tsv(path: str) -> pd.DataFrame:
    df = pd.read_csv(path, sep="\t", dtype=str, engine="python", comment="#")
    if df.shape[1] == 1:
        df = pd.read_csv(path, sep=r"\s+", dtype=str, engine="python", comment="#")
    df.columns = [str(c).strip() for c in df.columns]
    for c in df.columns:
        df[c] = df[c].astype(str).str.strip()
    return df

def ensure_feasible_column(df: pd.DataFrame) -> pd.DataFrame:
    cols_lower = {c.lower(): c for c in df.columns}
    if "feasible" in cols_lower:
        real = cols_lower["feasible"]
        if real != "feasible":
            df = df.rename(columns={real: "feasible"})
        return df
    if df.shape[1] == 0:
        return df
    last_col = df.columns[-1]
    if last_col != "feasible":
        df = df.rename(columns={last_col: "feasible"})
    return df

def as_bool_series(s: pd.Series) -> pd.Series:
    map_true = {"true","t","1","yes","y"}
    map_false = {"false","f","0","no","n","na"}
    def conv(x: str) -> bool:
        xl = ("" if x is None else str(x).strip()).lower()
        if xl in map_true:
            return True
        if xl in map_false or xl == "":
            return False
        return False
    return s.map(conv)

def find_column(df: pd.DataFrame, candidates: list[str]) -> str | None:
    """
    Find a column by trying a list of case-insensitive candidate names.
    Also tries simple normalizations like removing dashes/underscores.
    """
    norm = {}
    for c in df.columns:
        cl = c.lower()
        norm[cl] = c
        norm[cl.replace("-", "")] = c
        norm[cl.replace("_", "")] = c
        norm[cl.replace("-", "").replace("_", "")] = c
    for cand in candidates:
        cl = cand.lower()
        for key in (cl, cl.replace("-", ""), cl.replace("_", ""), cl.replace("-", "").replace("_", "")):
            if key in norm:
                return norm[key]
    return None

def parse_numeric_series(s: pd.Series) -> pd.Series:
    """
    Convert textual numeric column to float, accepting both '.' and ',' decimals.
    Empty strings / 'NA' / 'NaN' -> NaN.
    """
    s_norm = s.astype(str).str.strip().replace({"": None, "NA": None, "NaN": None, "nan": None})
    s_norm = s_norm.str.replace(",", ".", regex=False)
    return pd.to_numeric(s_norm, errors="coerce")

def extract_population(fname: str) -> str | None:
    m = FNAME_RE.match(fname)
    if not m:
        return None
    return m.group("pop")

def main():
    ap = argparse.ArgumentParser(
        description=("Filter qpadm TSV files by feasible==TRUE, "
                     "p_nested<=0.05 or NA, and p_value>0.05; group by population.")
    )
    ap.add_argument("input_dir", nargs="?", default=".", help="Directory containing TSV files (default: current dir)")
    ap.add_argument("--out", default="QPADM_filtered", help="Output root directory (default: QPADM_filtered)")
    args = ap.parse_args()

    in_dir = os.path.abspath(args.input_dir)
    out_root = os.path.abspath(args.out)
    os.makedirs(out_root, exist_ok=True)

    tsv_files = [f for f in os.listdir(in_dir) if f.lower().endswith(".tsv")]
    if not tsv_files:
        print(f"No .tsv files found in: {in_dir}")
        sys.exit(0)

    total_false_rows = 0
    total_pnested_rejects = 0
    total_pvalue_rejects = 0
    empty_or_header_only_files = 0
    files_missing_pnested = 0
    files_missing_pvalue = 0
    processed_files = 0
    written_files = 0
    populations_created = set()
    files_without_population = []
    per_pop_counts = defaultdict(int)

    for fname in sorted(tsv_files):
        src_path = os.path.join(in_dir, fname)

        # Quick empty/header-only check (lines with any non-whitespace)
        try:
            with open(src_path, "r", encoding="utf-8", errors="ignore") as fh:
                lines = [ln for ln in fh.readlines() if ln.strip() != ""]
        except Exception as e:
            print(f"[WARN] Skipping unreadable file {fname}: {e}")
            continue

        if len(lines) == 0 or len(lines) == 1:
            empty_or_header_only_files += 1
            continue

        # Parse population from filename
        population = extract_population(fname)
        if population is None:
            files_without_population.append(fname)
            population = "_misc_unparsed_population"

        # Read & filter
        try:
            df = guess_read_tsv(src_path)
        except Exception as e:
            print(f"[WARN] Failed to parse {fname}: {e}")
            continue

        if df.shape[0] == 0:
            empty_or_header_only_files += 1
            continue

        # Ensure/locate required columns
        df = ensure_feasible_column(df)
        if "feasible" not in df.columns:
            print(f"[WARN] No 'feasible' column found in {fname}; skipping.")
            empty_or_header_only_files += 1
            continue

        p_nested_col = find_column(df, ["p_nested"])
        if p_nested_col is None:
            print(f"[WARN] No 'p_nested' column found in {fname}; skipping.")
            files_missing_pnested += 1
            continue

        p_value_col = find_column(df, ["p_value", "pvalue", "p-value"])
        if p_value_col is None:
            print(f"[WARN] No 'p_value' column found in {fname}; skipping.")
            files_missing_pvalue += 1
            continue

        # Apply filters
        feas_bool = as_bool_series(df["feasible"])
        total_false_rows += int((~feas_bool).sum())

        p_nested_vals = parse_numeric_series(df[p_nested_col])
        mask_pnested = (p_nested_vals <= 0.05) | p_nested_vals.isna()   # accept <= 0.05 or NA
        total_pnested_rejects += int((~mask_pnested).sum())

        p_value_vals = parse_numeric_series(df[p_value_col])
        mask_pvalue = (p_value_vals > 0.05)                             # accept strictly above 0.05
        total_pvalue_rejects += int((~mask_pvalue).sum())

        df_filtered = df.loc[feas_bool & mask_pnested & mask_pvalue].copy()
        processed_files += 1

        if df_filtered.shape[0] == 0:
            # All models rejected -> do not write empty outputs
            continue

        # Prepare population directory
        pop_dir = os.path.join(out_root, population)
        if not os.path.exists(pop_dir):
            os.makedirs(pop_dir, exist_ok=True)
            populations_created.add(population)

        dst_path = os.path.join(pop_dir, fname)
        try:
            df_filtered.to_csv(dst_path, sep="\t", index=False)
            written_files += 1
            per_pop_counts[population] += 1
        except Exception as e:
            print(f"[WARN] Failed to write {fname} -> {dst_path}: {e}")

    # Summary
    print("\n=== QPADM filtering & grouping summary ===")
    print(f"Input directory: {in_dir}")
    print(f"Output root:     {out_root}")
    print(f"TSV files discovered: {len(tsv_files)}")
    print(f"Files processed (non-empty, >1 line, with required columns): {processed_files}")
    print(f"Files written after filtering: {written_files}")
    print(f"Empty or header-only files skipped: {empty_or_header_only_files}")
    print(f"Files skipped (missing p_nested): {files_missing_pnested}")
    print(f"Files skipped (missing p_value): {files_missing_pvalue}")
    print(f"Rows rejected (feasible == FALSE): {total_false_rows}")
    print(f"Rows rejected by p_nested > 0.05: {total_pnested_rejects}")
    print(f"Rows rejected by p_value <= 0.05 or NA: {total_pvalue_rejects}")
    print(f"Population folders created: {len(populations_created)}")
    if per_pop_counts:
        print("\nFiles written per population (non-empty after filtering):")
        for pop, cnt in sorted(per_pop_counts.items()):
            print(f"  {pop}: {cnt}")
    if files_without_population:
        print("\n[NOTE] These files did not match the expected filename pattern and were placed in '_misc_unparsed_population':")
        for f in files_without_population:
            print(f"  - {f}")

if __name__ == "__main__":
    main()
