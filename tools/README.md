# VFD Master Excel import

## Source file

`D:\VFD_Master_Database_Final - Copy.xlsx`

Each sheet = one vendor. Columns (row 3 header):

| Column | Field |
|--------|--------|
| Model Series | model name |
| Min kW / Max kW | range |
| Available Power Ratings (kW) | comma-separated kW list |
| Supports Communication Card | comm cards |
| Default Communication Protocol | default protocol |

## Supported in app (current release)

All 21 vendors seeded in SQLite. Excel catalog (power ratings, comm cards) covers:
ABB, Yaskawa, INVT, Danfoss, Schneider, Allen Bradley, Siemens, Mitsubishi, Delta

Remaining vendors use database parameters and models without Excel enrichment.

## Re-import after Excel changes

```powershell
cd d:\Spray_VFD\vfd_param_app
python tools/import_excel_master.py
flutter analyze lib/data/datasources/
```

Optional custom path:

```powershell
python tools/import_excel_master.py "D:\path\to\your.xlsx"
```

## Generated files

- `tools/excel_master_parsed.json`
- `lib/data/datasources/vfd_master_from_excel.dart`
- `lib/data/datasources/vendor_models_from_excel.dart`

Do not edit generated Dart files by hand.
