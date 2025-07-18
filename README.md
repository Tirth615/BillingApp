# 🧾 BillingApp – iOS Invoice Generator with Firebase

**BillingApp** is a modern iOS application designed for generating customer invoices, managing item entries, and exporting bills in PDF format. Built using **UIKit** and **Firebase**, it helps businesses quickly generate and share bills with a clean and efficient interface.

---

## ✨ Features

- 🔐 Firebase Authentication (Login, Forgot Password)
- 👤 Add and save customer details
- 📦 Add, update, and manage item entries
- 🧮 Automatic invoice number generation (e.g., `INV-0001`)
- 🧾 Generate professional invoices as PDFs
- 📤 Export or share generated PDFs via email or apps
- 🔍 Barcode search using Firestore indexes
- ⏱ Real-time Firestore integration
- ✅ Offline support with Firestore cache

---

## 🧰 Technologies Used

- UIKit (Storyboard/XIB)
- Firebase Firestore
- Firebase Authentication
- PDFKit
- SDWebImage (optional if you use images)

---


## 🔧 Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/Tirth615/BillingApp.git
cd BillingApp
```

### 2. Install Dependencies
```bash
pod install
```
```bash
open The Podfile And paste The Pod

pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Storage'
pod 'PDFKit'
pod 'SDWebImage'
```
### 3. Firebase Configuration
Go to Firebase Console
- Create a new project
- Firebase Authentication (Login, Forgot Password)
- Add an iOS app to the project
- Download GoogleService-Info.plist and add it to your Xcode project
  - Enable:
    - Email/Password Authentication
    - Cloud Firestore

### Setup Firestore Structure
  <img width="365" height="266" alt="Screenshot 2025-07-18 at 3 34 11 PM" src="https://github.com/user-attachments/assets/ee9c4c8a-9002-4bfe-a9b8-8aeee391dcb4" />

---

## Future Enhancements
- Add customer search & history
- Barcode scanner for adding items
- Cloud backup for invoices
- Analytics dashboard (sales, items sold)
- Dark mode support

---

## 🙋‍♂️ Author

- [Tirth615](https://github.com/Tirth615)
