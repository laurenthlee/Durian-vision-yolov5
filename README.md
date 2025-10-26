---

# Durian Vision YOLOv5 (Flutter)

A Flutter app for **real-time durian detection** using **YOLOv5**, with a smooth loading flow, structured data, and rich detail pages.

> Code lives on GitHub. Model weights are stored with **Git LFS**—after cloning, run `git lfs pull` to fetch the large files.

## Features

* Real-time detection (camera / images) powered by YOLOv5
* Loading flow + clean navigation
* Detail pages driven by a simple data model
* Supports multiple models (e.g., 4 variants) via the `models/` folder
* Runs on-device (offline friendly)

## Project structure (short)

```
durian-vision-yolov5/
├─ lib/
│  ├─ main.dart
│  ├─ loading_page.dart
│  ├─ detection.dart
│  ├─ data.dart
│  └─ details_page.dart
├─ models/            # model weights (*.tflite / *.onnx / *.pt) — tracked by Git LFS
├─ assets/            # images/labels if any
├─ pubspec.yaml
├─ .gitattributes     # LFS rules
└─ .gitignore
```

---

## Getting started (for teammates)

### 1) Clone + fetch LFS weights

> Make sure **Git** and **Git LFS** are installed.

```bash
git clone https://github.com/laurenthlee/durian-vision-yolov5.git
cd durian-vision-yolov5

# enable Git LFS on your machine (once)
git lfs install

# fetch large files (model weights, etc.)
git lfs pull
```

### 2) Install Flutter dependencies

```bash
flutter pub get
```

### 3) Run the app

* **Windows Desktop**

  ```bash
  flutter config --enable-windows-desktop
  flutter run -d windows
  ```
* **Android** (recommended to test on a real device)

  ```bash
  flutter run -d android
  ```
* **Web** (if supported)

  ```bash
  flutter run -d chrome
  ```

---

## Models (weights)

* Weights are stored in `models/` and tracked by **Git LFS**.
* After `git pull`, run `git lfs pull` so the actual files are downloaded.
* Example expected files (edit to match your project):

  ```
  models/
  ├─ durian_phytophthora.tflite
  ├─ durian_leaf_spot.tflite
  ├─ durian_leaf_blight.tflite
  └─ durian_algal_leaf_spot.tflite
  ```

---

## Team workflow (quick)

```bash
git checkout -b feature/your-task   # create a feature branch
# make changes...
git add -A
git commit -m "feat: describe your change"
git pull --rebase origin main       # keep up-to-date cleanly
git push -u origin feature/your-task
# open a Pull Request to merge into main
```

---

## Common issues

* **Models missing after clone:** you forgot `git lfs pull`.
* **LFS quota exceeded / slow downloads:** coordinate with repo owner to increase LFS quota or host big assets elsewhere (Hugging Face / Google Drive).
* **Build fails:** check `pubspec.yaml`, paths inside `models/`, and your Flutter setup (`flutter doctor -v`).

---

## License

* App code: see `LICENSE` (if present).
* Model weights may have separate terms (e.g., research-only). See `LICENSE-weights.txt` or `MODEL_CARD.md` if provided.
* Note: YOLOv5 licensing may affect commercial use—review upstream licenses before distributing.

---

## Maintainers

* **Repo:** `laurenthlee/durian-vision-yolov5`
* Questions? Open a GitHub Issue.

---
