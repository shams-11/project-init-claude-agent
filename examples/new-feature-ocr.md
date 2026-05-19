# Example: NEW_FEATURE — Add receipt OCR to a finance app

Sample walkthrough of `/project-init` adding a feature to an existing project with library research.

## Input

```
/project-init "add receipt OCR scanning to my finance app"
```

## What the agent does (abbreviated)

### Phase F0 — Feature capture
> Detected target: "finance app" — ambiguous. Listing your projects:
>   1. fitness-tracker-weekly (healthtech)
>   2. finance-helper (fintech)
>   3. clasycare-web (ecommerce)
> Which? (1-3)
> User: 2
> Reading `01_Projects/finance-helper/_index.md` for context...

### Phase F1 — Classification
> Feature type: integration
> Impact: full-stack (backend OCR worker + frontend camera + DB receipts table)
> Risk: medium (file upload + image processing)

### Phase F2 — Library / repo research

> | Candidate | Stars | License | Last commit | Compatibility | Score |
> |---|---|---|---|---|---|
> | ML Kit (Google) | bundled | proprietary | active | ✅ mobile-first, on-device | 88 |
> | Tesseract OCR | 60k | Apache 2.0 | active | 🟡 needs server-side | 70 |
> | Google Cloud Vision | proprietary | paid | active | 🟡 expensive at scale | 60 |
> | Claude Haiku Vision | proprietary | usage-based | active | ✅ context-aware | 82 |
>
> Recommendation:
>   Primary: ML Kit (on-device, free, mobile-first matches your stack)
>   Fallback: Claude Haiku Vision (server-side context fallback for hard cases)

### Phase F2.5 — Cost impact
> ML Kit: $0/mo (on-device)
> Claude Haiku Vision (fallback): ~$5/mo at 1000 receipts (estimate)
> Project total: $36/mo → $41/mo (+$5)
> Acceptable? (y/n)
> User: y

### Phase F3 — Requirements gathering
> Problem: manual receipt entry is slow
> Value: "as a user, I want to scan a receipt and have totals filled in"
> IO: camera image → structured receipt data (vendor, date, total, items)
> Acceptance: 90% accuracy on common locale receipts within 3 seconds
> ...

### Phase F4 — Component impact
> Backend: new OCR worker, new POST /receipts endpoint
> Frontend: new camera capture screen, parsing UI
> DB: new receipts table + migration
> Infra: none new (worker reuses existing)

### Phase F5 — Design proposal
> Integration points: backend/workers/ocr.py, frontend/lib/features/scan/
> Data model: receipts (id, user_id, raw_image_url, parsed_json, status, created_at)
> API: POST /receipts/upload, GET /receipts/<id>/status
> Test strategy: golden images per vendor type + integration test for full flow

### Phase F6 — Security review
> File upload risks: size limits, MIME validation, virus scan
> Image storage: signed URLs + 30-day TTL
> PII: receipts contain financial data → encrypt at rest

### Phase F7 — Task breakdown (micronized)
> Macro #M1: ML Kit integration in mobile (Σ 4h)
>   ├── Micro #m1.1 [parallel] Add `google_mlkit_text_recognition` to pubspec.yaml
>   ├── Micro #m1.2 [parallel] Configure ProGuard rules for ML Kit in Android
>   ├── Micro #m1.3 [blocked-by: #m1.1] Create OcrService wrapper with text recognition method
>   └── Micro #m1.4 [blocked-by: #m1.3] Build receipt parser (regex + heuristics)
>
> Macro #M2: Backend receipt endpoint (Σ 3h)
>   ├── Micro #m2.1 [parallel] Define Receipt SQLAlchemy model with parsed_json JSONB
>   ├── Micro #m2.2 [parallel] Add Alembic migration: 0007_create_receipts.py
>   ├── Micro #m2.3 [blocked-by: #m2.1] Implement POST /receipts/upload with file size + MIME validation
>   └── Micro #m2.4 [blocked-by: #m2.3] Add Claude Haiku Vision fallback worker
>
> ... (3 more macros) ...
>
> Total: 5 macros, 18 micros, ~16h estimated.

### Phase F8 — Feature spec write
> Spec saved: 01_Projects/finance-helper/features/2026-05-20-receipt-ocr.md
> _index.md updated with new feature reference.

### End-of-run summary

```
🎯 Feature receipt-ocr planned: finance-helper

Created:
  📄 Spec: 01_Projects/finance-helper/features/2026-05-20-receipt-ocr.md
  🔧 Primary library: ML Kit (fallback: Claude Haiku Vision)
  📚 ADRs: 2 new decisions (OCR library, fallback strategy)
  ✅ Tasks: 18 micros across 5 macros (~16h)

Component impact:
  - Backend: yes (new worker + endpoint + DB migration)
  - Frontend: yes (new screen + parser UI)
  - DB migration: yes

Next steps:
  1. Install: cd mobile && flutter pub add google_mlkit_text_recognition
  2. Start with #m1.1 or #m2.1 (parallel-safe)
```
