"""
tools/pdf_tool.py
Extracts text from uploaded PDF files using pdfplumber.
"""

import pdfplumber
from pathlib import Path


def extract_text_from_pdf(file_path: str) -> str:
    """
    Extract all text from a PDF file.
    Returns concatenated text from all pages.
    """
    path = Path(file_path)
    if not path.exists():
        raise FileNotFoundError(f"PDF not found: {file_path}")

    full_text = []
    with pdfplumber.open(str(path)) as pdf:
        for i, page in enumerate(pdf.pages):
            text = page.extract_text()
            if text:
                full_text.append(f"--- Page {i + 1} ---\n{text.strip()}")

    if not full_text:
        raise ValueError("No extractable text found in PDF (may be scanned/image-only).")

    return "\n\n".join(full_text)


def extract_text_from_bytes(pdf_bytes: bytes) -> str:
    """
    Extract text directly from PDF bytes (for in-memory uploads).
    """
    import io

    full_text = []
    with pdfplumber.open(io.BytesIO(pdf_bytes)) as pdf:
        for i, page in enumerate(pdf.pages):
            text = page.extract_text()
            if text:
                full_text.append(f"--- Page {i + 1} ---\n{text.strip()}")

    if not full_text:
        raise ValueError("No extractable text found in PDF.")

    return "\n\n".join(full_text)
