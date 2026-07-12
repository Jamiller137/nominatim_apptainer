import re

import pandas as pd


PO_BOX_PATTERN = re.compile(
    r"\b(?:"
    r"P\.?\s*O\.?\s*(?:Box|Box)?"
    r"|Post\s+Office\s+Box"
    r"|POBox|PO\s+Box"
    r"|Box"
    r")\s*#?\s*(\d+(?:[\s-]\d+)?)\b",
    re.IGNORECASE,
)

SECONDARY_UNIT_PATTERN = re.compile(
    r"(?i)(?:\s*,\s*|\s+(?:APT|APARTMENT|UNIT|SUITE|STE|FL|FLOOR|BLDG|BUILDING|LOT|RM|ROOM|#)\b|\s*#).*"
)


def add_po_box_flag(df: pd.DataFrame) -> pd.DataFrame:
    """Vectorized PO Box detector."""
    line1 = df["ADDR_HX_LINE1"].fillna("").astype(str)
    line2 = df["ADDR_HX_LINE2"].fillna("").astype(str)
    combined = (line1 + " " + line2).str.upper()

    df["is_po_box"] = combined.str.contains(PO_BOX_PATTERN, regex=True, na=False)
    return df


def clean_address_line1(line1: str) -> str:
    """Remove secondary address info from line 1."""
    if not isinstance(line1, str):
        return line1

    cleaned = SECONDARY_UNIT_PATTERN.sub("", line1).strip()
    cleaned = re.sub(r"\s+", " ", cleaned)
    return cleaned


def normalize_address(row: pd.Series) -> dict:
    """Build a structured address dict from a DataFrame row."""
    zip_value = row.get("ZIP")
    postalcode = None
    if pd.notna(zip_value):
        postalcode = str(zip_value).split("-")[0].strip()

    return {
        "street": clean_address_line1(str(row.get("ADDR_HX_LINE1", ""))),
        "city": str(row.get("CITY", "")),
        "state": str(row.get("STATE", "")),
        "postalcode": postalcode,
        "country": str(row.get("COUNTRY", "")),
    }

