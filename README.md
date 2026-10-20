# Expense Tracker

A personal expense tracker app I am building with Flutter and Firebase.

I started this project to improve my Flutter development skills and learn how to build an application with authentication, transaction management, and financial reports. I am also trying to keep the code organized so that it is easier to maintain and improve later.

## Screenshots

Here are some screenshots of the app.

### Authentication

| Login | Sign Up |
|---|---|
| ![Login](assets/images/login.png) | ![Sign Up](assets/images/signin.png) |

### Home and Profile

| Home | Profile | Logout |
|---|---|---|
| ![Home](assets/images/home.png) | ![Profile](assets/images/profile.png) | ![Logout](assets/images/logout.png) |

### Transactions

| Transaction History | Add Expense | Add Income |
|---|---|---|
| ![Transactions](assets/images/transaction.png) | ![Expense Transaction](assets/images/expenseTransection.png) | ![Income Transaction](assets/images/incomeTransaction.png) |

| Transaction Date |
|---|
| ![Transaction Date](assets/images/transactionDate.png) |

### Reports and Charts

| Reports | Report Insights |
|---|---|
| ![Reports](assets/images/report.png) | ![Report Insights](assets/images/reportInsights.png) |

| Spending Breakdown | Weekly Graph |
|---|---|
| ![Spending Breakdown](assets/images/spendingBrackdown.png) | ![Weekly Graph](assets/images/weeklygraph.png) |

| Monthly Report | Yearly Report |
|---|---|
| ![Monthly Report](assets/images/monthlyReportGrap.png) | ![Yearly Graph](assets/images/yearlyGraph.png) |

## Features

- Create an account and log in with email and password.
- Google sign-in option.
- Sign out from the profile page.
- Keep track of income and expenses.
- Add and review transactions.
- View transaction dates and transaction history.
- Store user transactions in Cloud Firestore.
- Check reports and spending breakdowns.
- View weekly, monthly, and yearly graphs.
- See account information on the profile page.

I am continuing to improve the UI, functionality, and overall user experience as I work on the project.

## Technologies Used

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Google Sign-In
- Git and GitHub

## Getting Started

To run the project on your local machine, follow these steps.

### 1. Clone the Repository

```bash
git clone https://github.com/MUfoysal/expense_tracker.git
```

### 2. Open the Project

```bash
cd expense_tracker
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

The app uses Firebase Authentication and Cloud Firestore.

To configure Firebase for your own project, run:

```bash
flutterfire configure
```

Then, open the Firebase Console and enable the authentication methods you want to use. Configure Cloud Firestore and the required platform settings as well.

Make sure the Firebase configuration matches your project before running the app.

### 5. Run the App

To run the application on an available device:

```bash
flutter run
```

To run it in Chrome:

```bash
flutter run -d chrome
```

## Project Structure

The project is organized by feature to keep related screens and supporting code together. Shared theme settings and reusable widgets are stored in the `core` directory.

```text
expense_tracker/
├── assets/
│   └── images/
│       ├── google_logo.png
│       ├── login.png
│       ├── signin.png
│       ├── home.png
│       ├── profile.png
│       ├── logout.png
│       ├── transaction.png
│       ├── expenseTransection.png
│       ├── incomeTransaction.png
│       ├── transactionDate.png
│       ├── report.png
│       ├── reportInsights.png
│       ├── spendingBrackdown.png
│       ├── weeklygraph.png
│       ├── monthlyReportGrap.png
│       └── yearlyGraph.png
│
├── lib/
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── widgets/
│   │       └── app_bottom_navigation.dart
│   │
│   ├── features/
│   │   ├── authentication/
│   │   │   └── presentation/
│   │   │       └── pages/
│   │   │           ├── auth_gate.dart
│   │   │           ├── login_page.dart
│   │   │           └── signup_page.dart
│   │   │
│   │   ├── home/
│   │   │   └── presentation/
│   │   │       └── pages/
│   │   │           └── home_page.dart
│   │   │
│   │   ├── navigation/
│   │   │   └── presentation/
│   │   │       └── pages/
│   │   │           └── main_navigation_page.dart
│   │   │
│   │   ├── profile/
│   │   │   └── presentation/
│   │   │       └── pages/
│   │   │           └── profile_page.dart
│   │   │
│   │   ├── reports/
│   │   │   └── presentation/
│   │   │       └── pages/
│   │   │           └── reports_page.dart
│   │   │
│   │   └── transactions/
│   │       ├── data/
│   │       │   └── repositories/
│   │       │       └── transaction_repository.dart
│   │       └── presentation/
│   │           └── pages/
│   │               ├── add_transaction_page.dart
│   │               └── transactions_page.dart
│   │
│   ├── firebase_options.dart
│   └── main.dart
│
├── test/
│   └── widget_test.dart
│
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
│
├── firebase.json
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── .gitignore
└── README.md
```

### Main Directories

- `core/theme/` — Shared application theme.
- `core/widgets/` — Reusable widgets, including bottom navigation.
- `features/authentication/` — Login, sign-up, and authentication state.
- `features/home/` — Home dashboard.
- `features/navigation/` — Main application navigation.
- `features/profile/` — User profile and account controls.
- `features/reports/` — Reports and financial charts.
- `features/transactions/data/` — Transaction repository and Firestore operations.
- `features/transactions/presentation/` — Transaction-related screens.
- `assets/images/` — Application images and screenshots.
- `test/` — Flutter widget tests.

## What I Am Learning

While working on this project, I am learning how to:

- Build Flutter interfaces and reusable widgets.
- Manage user authentication states.
- Connect a Flutter application to Firebase.
- Store and retrieve user-specific transaction data.
- Organize code by feature.
- Present financial information using reports and charts.
- Use Git and GitHub to manage project changes.

I am continuing to improve this project as I learn more about Flutter and Firebase.

## Developer

**Mohib Ullah (MUfoysal)**

Computer Science & Technology Student | Flutter Developer in Progress

GitHub: [MUfoysal](https://github.com/MUfoysal)

---

This project is part of my practical learning journey with Flutter and Firebase.