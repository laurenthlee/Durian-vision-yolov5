# Durian Vision YOLOv5 (Flutter)

A Flutter app for **real-time durian detection** using **YOLOv5**, with a smooth loading flow, structured data, and rich detail pages.

Code lives on GitHub. Model weights are stored with **Git LFS**—after cloning, run `git lfs pull` to fetch the large files.

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

# A) Train YOLOv5 from Roboflow datasets

> Requires Git + Python (with pip). On Windows, use “Command Prompt” or PowerShell.

```bash
# 1) Get YOLOv5
git clone https://github.com/ultralytics/yolov5
cd yolov5
pip install -r requirements.txt

# (optional but handy)
pip install roboflow
```

### Download a Roboflow dataset (YOLOv5 format)

Open one of your links, choose **Download → YOLOv5 PyTorch**, and you’ll get a `data.yaml` + `/train` & `/valid`.
Or via Python (replace with your workspace/project/version):

```python
from roboflow import Roboflow
rf = Roboflow(api_key="YOUR_KEY")
project = rf.workspace("rvv-technologies").project("durian-leaf-wqx98")
dataset = project.version(4).download("yolov5")  # creates a folder with data.yaml
```

### Train

```bash
# inside yolov5/
python train.py --img 640 --batch 16 --epochs 50 \
  --data path/to/data.yaml --weights yolov5s.pt
```

### Export to TFLite for Flutter

```bash
python export.py --weights runs/train/exp/weights/best.pt --include tflite
# result: best.tflite  (move it into your Flutter project's models/)
```

---

# B) Integrate into Flutter (project side)

**Project structure**

```
android/
lib/
models/          # put best.tflite here
pubspec.yaml
```

**pubspec.yaml**

```yaml
flutter:
  assets:
    - models/best.tflite
```

**(If you use the `tflite` plugin)** add “no compress” so .tflite isn’t zipped:

```gradle
// android/app/build.gradle  (AGP 7.x)
android {
  aaptOptions {
    noCompress 'tflite'
    noCompress 'lite'
  }
}
```

---

# C) Fix Android build errors

You saw:

* `A problem occurred configuring project ':camera_android'`
* Kotlin/Gradle confusion
* Namespace hints
* TFLite deps and `Uint8List` trouble

Pick **one** route to stabilize your Android toolchain.

## Route 1 (most compatible for Flutter today)

**Use AGP 7.4.2 + Gradle 7.6 + Kotlin 1.9.x**

**android/build.gradle**

```gradle
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories { google(); mavenCentral() }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
```

**android/gradle/wrapper/gradle-wrapper.properties**

```
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6-all.zip
```

**android/app/build.gradle**

```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        applicationId "com.example.durianapp"   // your id
        minSdkVersion 21
        targetSdkVersion 34
        multiDexEnabled true
    }
    // (AGP 7.x) aaptOptions works:
    aaptOptions {
        noCompress 'tflite'
        noCompress 'lite'
    }
    // adding namespace is OK (AGP 7+ supports it)
    namespace "com.example.durianapp"
}
```

> If you previously edited files under `C:\Users\<you>\AppData\Local\Pub\Cache\...`, undo that. Don’t modify plugin code in the pub cache—pin versions from your app instead.

### If you really want AGP 8.x (not required)

* Use Gradle 8.x, **namespace is mandatory**, and `aaptOptions` is replaced by:

  ```gradle
  android {
    packagingOptions {
      resources {
        excludes += ["**/*.tflite","**/*.lite"] // or use noCompress in aapt2 flags
      }
    }
    namespace "com.example.durianapp"
  }
  ```
* Make sure Kotlin ≥ 1.8.20; 1.9.0 is fine.

## Pin TensorFlow Lite versions (avoid `+`)

Instead of editing the plugin’s Gradle file, declare them in your app to avoid conflicts:

```gradle
// android/app/build.gradle
dependencies {
    implementation 'org.tensorflow:tensorflow-lite:2.12.0'
    implementation 'org.tensorflow:tensorflow-lite-gpu:2.12.0'
}
```

If that clashes with the `tflite` plugin, switch to **tflite_flutter** (often smoother):

```yaml
# pubspec.yaml
dependencies:
  tflite_flutter: ^0.10.4
  tflite_flutter_helper: ^0.3.4
```

---

# D) Fix the `Uint8List` (Dart) issue

Your snippet:

```dart
Uint8List get data {
  final data = cast<Uint8>(tfliteBinding.TfLiteTensorData(_tensor));
  return data.asTypedList(tfliteBinding.TfLiteTensorByteSize(_tensor)).asUnmodifiableView();
}
```

Common fixes:

1. **Make sure imports are present**

```dart
import 'dart:ffi';
import 'dart:typed_data';
```

2. If `.asUnmodifiableView()` isn’t found in your SDK, just return a plain list:

```dart
Uint8List get data {
  final ptr = tfliteBinding.TfLiteTensorData(_tensor);
  final length = tfliteBinding.TfLiteTensorByteSize(_tensor);
  final bytes = ptr.cast<Uint8>().asTypedList(length);
  return Uint8List.fromList(bytes); // drop asUnmodifiableView()
}
```

3. If you’re mixing `tflite` and `tflite_flutter`, pick **one** (recommend `tflite_flutter`) to avoid API mismatches.

---

# E) Build steps (clean → get → build)

```bash
flutter clean
flutter pub get
flutter doctor -v           # confirm Android toolchain
flutter build apk --release
```

If you still see:

```
A problem occurred configuring project ':camera_android'.
> Could not create an instance of ...
```

do this:

```bash
# show exact versions in use
cd android
gradlew.bat --version
gradlew.bat :camera_android:dependencies --configuration debugRuntimeClasspath
gradlew.bat build -s
```

Paste the **full error** (stacktrace) and I’ll pinpoint the exact plugin/version causing it.

---

## Optional: force a dependency to avoid conflicts

If some transitive lib causes issues:

```gradle
configurations.all {
  resolutionStrategy {
    force 'androidx.core:core-ktx:1.6.0'
  }
}
```

(Use only if you know which artifact is conflicting.)

---

## Quick checklist

* [ ] `best.tflite` in `models/` and declared in `pubspec.yaml`
* [ ] No plugin code edited inside Pub Cache
* [ ] AGP/Gradle/Kotlin versions aligned (7.4.2 / 7.6 / 1.9.0 works well)
* [ ] `namespace` present if using AGP ≥ 7 (good to have anyway)
* [ ] `aaptOptions { noCompress 'tflite' 'lite' }` (AGP 7) or packagingOptions (AGP 8)
* [ ] `flutter clean && flutter pub get && flutter build apk --release`

---

## Models & Weights

This repo contains both **training weights** (`.pt`) and **mobile inference weights** (`.tflite`) tracked by **Git LFS**.

### Training weights (`.pt`)

```
models/
├─ AlgalLeafSpot_T1.pt
├─ AlgalLeafSpot_T2.pt
├─ AlgalLeafSpot_T3.pt
├─ LeafBlight_T1.pt
├─ LeafBlight_T2.pt
├─ LeafBlight_T3.pt
├─ LeafSpot_T1.pt
├─ LeafSpot_T2.pt
└─ LeafSpot_T3.pt
```

### Mobile weights (`.tflite`) used by the Flutter app

```
models/
├─ AlgalLeafSpot.tflite   # T3 export
├─ LeafBlight.tflite      # T3 export
├─ LeafSpot.tflite        # T3 export
└─ Phytophthora.tflite    # extra class (exported)
```

> The app uses the **T3** models for AlgalLeafSpot, LeafBlight, and Leaf-Spot (best results).
> `.pt` files are for training/evaluation; `.tflite` files are what the app loads on device.

### Clone + fetch LFS files

```bash
git clone https://github.com/laurenthlee/durian-vision-yolov5.git
cd durian-vision-yolov5
git lfs install
git lfs pull           # fetch .pt/.tflite
flutter pub get
```

---

## Recommended confidence thresholds

We ship three presets (based on your counts):

* **Recall**: `0.70` (default; fewer misses, more false positives)
* **Balanced**: `0.80`
* **Strict**: `0.90` (fewer detections; high precision)

Per-class defaults (edit as needed):

```json
{
  "AlgalLeafSpot": 0.70,
  "LeafBlight":    0.70,
  "Leaf-Spot":     0.70,
  "Phytophthora":  0.70
}
```

### Optional: app config file

Create `assets/models_config.json`:

```json
{
  "models": [
    {"name":"AlgalLeafSpot","file":"models/AlgalLeafSpot.tflite","conf":0.70},
    {"name":"LeafBlight","file":"models/LeafBlight.tflite","conf":0.70},
    {"name":"Leaf-Spot","file":"models/LeafSpot.tflite","conf":0.70},
    {"name":"Phytophthora","file":"models/Phytophthora.tflite","conf":0.70}
  ]
}
```

Add to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/models_config.json
    - models/AlgalLeafSpot.tflite
    - models/LeafBlight.tflite
    - models/LeafSpot.tflite
    - models/Phytophthora.tflite
```

### Example (Flutter) threshold filter

```dart
final Map<String, double> conf = {
  'AlgalLeafSpot': 0.70,
  'LeafBlight':    0.70,
  'Leaf-Spot':     0.70,
  'Phytophthora':  0.70,
};

List<Map<String, dynamic>> filterDetections(List<Map<String, dynamic>> dets) {
  return dets.where((d) {
    final label = d['label'] as String;
    final score = (d['confidence'] as num).toDouble();
    return score >= (conf[label] ?? 0.70);
  }).toList();
}
```

---

## Re-exporting from YOLOv5 (training → TFLite)

```bash
# train (example)
python train.py --img 640 --batch 16 --epochs 50 \
  --data path/to/data.yaml --weights yolov5s.pt

# export to TFLite
python export.py --weights runs/train/exp/weights/best.pt --include tflite
# move best.tflite to: models/<DiseaseName>.tflite
```

---

## Datasets (sources you referenced)

* RVV Technologies — **Durian Leaf** (Roboflow) v4
* Winwut — **Dr.Fruity** (Roboflow) v1
* HuaHin — **Test1** (Roboflow) v1

(Download as **YOLOv5 PyTorch** format for training.)

---
