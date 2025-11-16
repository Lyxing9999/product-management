
# Product Management App

A Product CRUD system built with Flutter + Provider (frontend), Node.js + Express (backend), and SQL Server (database).

## Features

* List, add, edit, delete products
* Search by name, sort by price/stock
* Pagination and pull-to-refresh
* Export product list to CSV or PDF

## Setup

### Backend

1. Go to backend/ folder:
```bash
cd backend
npm install
```

2. Copy `.env.example` to `.env` and update DB credentials.

3. Start server:
```bash
npm start
```

Runs at http://localhost:3000

### Frontend

1. Go to mobileApp/ folder:
```bash
cd mobileApp
flutter pub get
```

2. Update API base URL in `lib/services/product_service.dart`:
```dart
// For mobile/emulator
static const String baseUrl = 'http://10.0.2.2:3000/api';

// For web
static const String baseUrl = 'http://localhost:3000/api';
```

3. Run app:
```bash
flutter run
```

## Database

```sql
CREATE TABLE PRODUCTS (
  PRODUCTID INT PRIMARY KEY IDENTITY(1,1),
  PRODUCTNAME NVARCHAR(100) NOT NULL,
  PRICE DECIMAL(10, 2) NOT NULL,
  STOCK INT NOT NULL
);
```
