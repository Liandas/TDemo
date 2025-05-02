# 📱 TDemo - Product List App

A lightweight iOS app built using UIKit and MVVM that lists grocery products and shows their details. It supports offline caching, image storage with ETag-based freshness checks, and full unit test coverage — all without third-party libraries.

---

## 🧠 Architecture & Design

- ✅ **MVVM Pattern** for clean separation of concerns
- ✅ **Protocol-Based Abstraction** for testability and flexibility
- ✅ **Replaceable Layers**: Swap Core Data with Realm or others without changing business logic
- ✅ **Multi-environment support ready** via `APIConstants`

---

## 💾 Offline & Persistence Strategy

- ✅ `Persistence` abstraction makes Core Data replaceable
- ✅ Offline-first: falls back to local DB when network is unavailable
- ✅ `insertOrUpdate` prevents unnecessary read-update-write cycles
- ✅ All DB operations are done on background context for performance

---

## 📸 Image Caching

- ✅ Saves images to `/caches/ImageCache`
- ✅ Uses HTTP `ETag` to prevent redundant downloads
- ✅ Format-agnostic saving (PNG, JPG, etc.)
- ✅ Saves both Thumbnail and Original for performance (Thumbnail uses same aspect ratio)
- ✅ Clean `UIImageView` extension (`setImage(for:)`) for use in UI

---

## ⚡️ Performance Optimizations

- ✅ All Core Data writes run off the main thread
- ✅ ETag checks for image freshness
- ✅ Avoids redundant DB interactions by combining logic into `insertOrUpdate`

---

## ❗️ Error Handling

- ✅ Graceful fallback to DB if API fails
- ✅ ViewModels expose `onError` closures for clean UI integration
- ✅ Custom domain errors like `.noCachedProduct` for clarity

---

## 🧪 Test Coverage

### ✅ DetailViewModel

```
Case | Repository Result     | ViewModel Callback   | Description                      | Covered?
-----|------------------------|-----------------------|----------------------------------|----------
  1  | Success (Product)      | onProductUpdated      | Updates description              | ✅
  2  | Failure (Error)        | onError               | Triggers error handling          | ✅
```

### ✅ HomeViewModel

```
Case | Repository Result     | ViewModel Callback       | Description                        | Covered?
-----|------------------------|---------------------------|------------------------------------|----------
  1  | Success ([Product])    | onProductsUpdated         | Updates product list               | ✅
  2  | Failure (Error)        | onError                   | Triggers error handling            | ✅
```

### ✅ ProductRepositoryImp.fetchProductDetails(productId:)

```
Case | Internet | Network | JSON Decode | DB Save | DB Read | Result                        | Covered?
-----|----------|---------|-------------|---------|---------|-------------------------------|----------
  1  | OFF      | —       | —           | —       | OK      | Load product from DB          | ✅
  2  | OFF      | —       | —           | —       | FAIL    | Return read failure           | ✅
  3  | ON       | FAIL    | —           | —       | —       | Return network error          | ✅
  4  | ON       | OK      | FAIL        | —       | OK      | Load product from DB          | ✅
  5  | ON       | OK      | OK          | FAIL    | —       | Return product anyway         | ✅
  6  | ON       | OK      | OK          | OK      | —       | Return product                | ✅
  7  | ON       | OK      | FAIL        | —       | FAIL    | Return read failure fallback  | ✅
  8  | ON       | OK      | FAIL        | —       | Empty   | Return .noCachedProduct       | ✅
```

### ✅ ProductRepositoryImp.fetchProducts()

```
Case | Internet | Network | JSON Decode | DB Save | Result                     | Covered?
-----|----------|---------|-------------|---------|----------------------------|----------
  1  | OFF      | —       | —           | —       | Load from DB               | ✅
  2  | ON       | FAIL    | —           | —       | Return network error       | ✅
  3  | ON       | OK      | FAIL        | —       | Load from DB               | ✅
  4  | ON       | OK      | OK          | FAIL    | Return products (no save)  | ✅
  5  | ON       | OK      | OK          | OK      | Return products (saved)    | ✅
  6  | ON       | OK      | OK (empty)  | OK      | Return empty array         | ✅
```

---

## 🧪 Tech Stack

- UIKit
- MVVM
- Core Data
- Native image caching with ETag support
- XCTest
- No third-party libraries

---

## ▶️ Run the App

- Open `TDemo.xcodeproj`
- Run on simulator

---
