"""
tools/text_chunker.py
Splits long text into overlapping chunks for RAG storage and retrieval.
"""

from typing import List


def chunk_text(
    text: str,
    chunk_size: int = 500,
    overlap: int = 50,
) -> List[str]:
    """
    Split text into chunks of roughly `chunk_size` words with `overlap` words
    of overlap between consecutive chunks.

    Args:
        text: The full text to chunk.
        chunk_size: Target number of words per chunk.
        overlap: Number of words shared between adjacent chunks.

    Returns:
        List of text chunk strings.
    """
    words = text.split()
    if not words:
        return []

    chunks: List[str] = []
    start = 0

    while start < len(words):
        end = min(start + chunk_size, len(words))
        chunk = " ".join(words[start:end])
        chunks.append(chunk)
        if end == len(words):
            break
        start += chunk_size - overlap  # advance with overlap

    return chunks


def chunk_text_by_chars(
    text: str,
    chunk_size: int = 1500,
    overlap: int = 150,
) -> List[str]:
    """
    Character-based chunking — useful for PDFs with variable word lengths.
    """
    chunks: List[str] = []
    start = 0

    while start < len(text):
        end = min(start + chunk_size, len(text))
        # Try to break at a sentence boundary
        if end < len(text):
            boundary = text.rfind(".", start, end)
            if boundary > start:
                end = boundary + 1
        chunks.append(text[start:end].strip())
        if end == len(text):
            break
        start = end - overlap

    return [c for c in chunks if c]
