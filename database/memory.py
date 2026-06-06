"""
database/memory.py
Lightweight in-memory document store with keyword-based similarity search.
No external vector DB required — suitable for hackathon scale.
"""

import re
import math
from typing import List, Dict, Any, Optional
from collections import defaultdict


# ---------------------------------------------------------------------------
# In-memory store
# ---------------------------------------------------------------------------
_documents = []          # List of {id, text, metadata, tokens}
_inverted_index = defaultdict(list)   # token -> [doc_ids]
_doc_counter = 0


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _tokenize(text):
    text = text.lower()
    text = re.sub(r"[^a-z0-9\s]", " ", text)
    return [t for t in text.split() if len(t) > 2]


def _tf_idf_score(query_tokens, doc_tokens):
    if not doc_tokens:
        return 0.0
    doc_len = len(doc_tokens)
    doc_freq = defaultdict(int)
    for t in doc_tokens:
        doc_freq[t] += 1
    score = 0.0
    for token in query_tokens:
        tf = doc_freq.get(token, 0) / doc_len
        containing = len(_inverted_index.get(token, []))
        idf = math.log((len(_documents) + 1) / (containing + 1)) + 1.0
        score += tf * idf
    return score


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def store_document(chunks, metadata=None):
    global _doc_counter
    if metadata is None:
        metadata = {}
    ids = []
    for chunk in chunks:
        tokens = _tokenize(chunk)
        doc_id = _doc_counter
        _documents.append({
            "id": doc_id,
            "text": chunk,
            "metadata": metadata,
            "tokens": tokens,
        })
        for token in set(tokens):
            _inverted_index[token].append(doc_id)
        ids.append(doc_id)
        _doc_counter += 1
    return ids


def search_documents(query, top_k=5):
    if not _documents:
        return []
    query_tokens = _tokenize(query)
    if not query_tokens:
        return []
    candidate_ids = set()
    for token in query_tokens:
        candidate_ids.update(_inverted_index.get(token, []))
    if not candidate_ids:
        return _documents[-top_k:]
    scored = []
    for doc_id in candidate_ids:
        doc = _documents[doc_id]
        score = _tf_idf_score(query_tokens, doc["tokens"])
        scored.append((score, doc))
    scored.sort(key=lambda x: x[0], reverse=True)
    return [doc for _, doc in scored[:top_k]]


def get_all_documents():
    return list(_documents)


def clear_memory():
    global _doc_counter
    _documents.clear()
    _inverted_index.clear()
    _doc_counter = 0


def document_count():
    return len(_documents)