# ⚡ Campus QuickSplit

> **Smart Campus Debt & Shared Expense Management Platform**  
> Built for GDG (Google Developer Groups) Campus Engineering Challenge.

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)]()
[![Tests](https://img.shields.io/badge/Tests-8%2F8%20Passed-success)]()

---

## 📌 Project Overview

**Campus QuickSplit** is a full-featured, production-grade expense-splitting and peer-to-peer debt settlement application designed specifically for college students, roomies, trip groups, and campus organizations. It solves complex multi-person bill allocations with mathematically exact split modes, graph-based debt simplification, OCR receipt processing, and verified payment gateway checkouts.

### Key Highlights
- 🎨 **Electric Royal Blue Fintech UI**: Modern dark/light fintech design system with interactive animations.
- 🤝 **100% Direct Debt Settlement**: Direct 1-to-1 peer payments clear exact debt balances without halving or unexpected splitting.
- 📊 **Debt Simplification Graph Solver**: Reduces $N$-person circular debts down to minimal direct transfer paths using a net-flow optimization algorithm.
- 📷 **OCR Receipt Scanner**: Auto-detects item descriptions and prices from paper receipt images to instantly populate expense forms.
- 🔐 **Dual Payment Gateways**: Option for external Paytm/GPay UPI app redirects (with completion verification checks) and in-app animated 4-digit UPI PIN & Stripe tokenized card checkouts.
- 👥 **Campus Groups & Friends Hub**: Dedicated management for campus peers (with custom display aliases) and group hubs with member management.

---

## 🛠️ Tech Stack & Dependencies

### Core Framework & State Management
- **Flutter & Dart SDK**: Cross-platform web, mobile, and desktop UI engine.
- **Provider (`provider: ^6.1.2`)**: Centralized reactive state management decoupling UI components from business logic.
- **Local Disk Persistence (`shared_preferences: ^2.2.2`)**: Offline-first storage persisting expenses, custom friends, campus groups, user PINs, linked bank accounts, and theme settings.

### UI Styling & Animations
- **Flutter Animate (`flutter_animate: ^4.5.0`)**: Smooth micro-animations and state transitions.
- **Intl (`intl: ^0.19.0`)**: Currency formatting and date/time stream parsing.
- **CustomPainter**: Hand-drawn category expense breakdown donut charts and concentric participant allocation rings.

---

## 🔄 Data Processes & Core Business Logic

### 1. Debt Simplification Algorithm (`DebtSimplifier`)
Computes net balances for all participants across expenses and solves the **Minimum Flow Debt Problem**:
1. Sums all amounts paid vs owed per participant to produce net balance vector $B(u)$.
2. Separates participants into Net Debtors ($B < 0$) and Net Creditors ($B > 0$).
3. Iteratively matches max debtor with max creditor to eliminate circular debt transactions (converting $O(N^2)$ transfers into minimal direct paths).

### 2. Balance Calculation Engine (`BalanceCalculator`)
- **Bilateral Pairwise Debts**: Computes net pairwise debt matrix between any two individuals.
- **Direct Settlement Handling**: Detects transactions flagged with `isSettlement = true` and applies 100% of the dollar amount directly to debt reduction.

### 3. 5 Granular Allocation Modes (`SplitMode`)
1. **Equal (`=`)**: Distributes cost evenly among $N$ participants, handling leftover decimal remainders ($100 / 3 \rightarrow \$33.33, \$33.33, \$33.34$).
2. **Exact Amounts (`$`)**: Enables manual dollar allocations while tracking unallocated remaining funds in real-time.
3. **Percentage Ratios (`%`)**: Percentage-driven splitting enforced against a strict 100% total cap.
4. **Shares (`||`)**: Weighted ratio splits based on custom participant share values.
5. **Adjustment (`+/-`)**: Base equal split adjusted by individual positive/negative offset amounts.

---

## 📐 System Data Flow Architecture

```mermaid
flowchart TD
    subgraph Client Layer (UI)
        A[LoginScreen / Google Auth] --> B[MainNavigationScreen]
        B --> C[DashboardScreen]
        B --> D[GroupsListScreen / GroupDetailScreen]
        B --> E[AnalyticsScreen & Donut Chart]
        B --> F[FriendsListScreen & RequestCashScreen]
        B --> G[AddExpenseScreen / OCR Receipt Scanner]
    end

    subgraph State Management Layer
        H[ExpenseProvider]
        I[ThemeProvider]
    end

    subgraph Business Logic & Algorithms
        J[BalanceCalculator Engine]
        K[DebtSimplifier Min-Flow Graph Solver]
        L[PaymentGatewayService]
    end

    subgraph Storage Layer (Local-First)
        M[(LocalStorageService / SharedPreferences)]
    end

    Client Layer -->|Reads / Dispatches Actions| H
    Client Layer -->|Theme Toggles| I
    H -->|Computes Balances| J
    H -->|Simplifies Group Debts| K
    H -->|Executes Payments| L
    H <-->|Reads & Persists JSON| M
```

---

## 📋 Feature Matrix (Phase Specification Mapping)

| Phase | Feature | Status | Implementation File |
|---|---|---|---|
| **Phase 1** | Standard Equal Distribution | ✅ Complete | `lib/models/expense.dart` |
| | Aggregated Balance Dashboard | ✅ Complete | `lib/screens/dashboard_screen.dart` |
| | Time-Ordered Activity Stream | ✅ Complete | `lib/screens/activity_log_screen.dart` |
| | Input Sanitization & Validation | ✅ Complete | `lib/screens/add_expense_screen.dart` |
| | Modular Provider Architecture | ✅ Complete | `lib/providers/expense_provider.dart` |
| **Phase 2** | 5 Granular Allocation Modes | ✅ Complete | `lib/models/split_mode.dart` |
| | Offline Local-First Disk Storage | ✅ Complete | `lib/logic/local_storage_service.dart` |
| | Settlement Debt Optimization | ✅ Complete | `lib/logic/debt_simplifier.dart` |
| **Phase 3** | Multi-Payer Contributions | ✅ Complete | `lib/models/expense.dart` |
| | Minimum Transaction Path Solver | ✅ Complete | `lib/logic/debt_simplifier.dart` |
| | Spend Analytics Donut Chart | ✅ Complete | `lib/widgets/spend_analytics_chart.dart` |
| | Swipe-to-Delete with Undo | ✅ Complete | `lib/widgets/expense_card.dart` |
| | System Light/Dark Theme Modes | ✅ Complete | `lib/providers/theme_provider.dart` |

---

## 🚀 How to Run & Build

### Prerequisites
- **Flutter SDK**: `>= 3.0.0`
- **Dart SDK**: `>= 3.0.0`
- **Browser / Emulator**: Google Chrome, Edge, or iOS/Android Simulator.

### 1. Clone Repository & Install Dependencies
```bash
git clone https://github.com/AbhiKrish07/campus_quicksplit.git
cd campus_quicksplit
flutter pub get
```

### 2. Run Static Code Analysis
Ensure zero lints or warnings:
```bash
flutter analyze
```

### 3. Run Automated Unit & Widget Tests
Execute full test suite (100% pass rate):
```bash
flutter test
```

### 4. Run Development Application
```bash
# Run on Web Server
flutter run -d web-server --web-port=8080

# Or run on Chrome Browser
flutter run -d chrome
```

### 5. Build Release Bundle
```bash
# Build Web Release Bundle
flutter build web --release
```

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
