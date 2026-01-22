Dart Frog RESTful API Training Project
A clean, modular RESTful API built with Dart Frog for managing task lists and items. This project demonstrates proper API architecture, error handling, and repository patterns in Dart.

✨ Features
Complete CRUD Operations: Full create, read, update, and delete functionality for both lists and items

Clean Architecture: Separated models, repositories, and route handlers

Singleton Pattern: Properly implemented repository pattern with singleton instances

Comprehensive Error Handling: Meaningful HTTP status codes and error messages

In-Memory Storage: Easy-to-understand data persistence using Dart Maps

REST Client Testing: Ready-to-use API testing with included HTTP client file

🚀 Getting Started
Prerequisites
Dart SDK (version 3.0 or higher)

Dart Frog CLI

Installation
Clone the repository:

bash
git clone https://github.com/AhmedShaltout85/training_dart_frog_api.git
cd training_dart_frog_api
Install dependencies:

bash
dart pub get
Run the development server:

bash
dart_frog dev
The server will start at http://localhost:8080

📚 API Endpoints
Lists Management (/api/v1/lists)
GET /api/v1/lists - Retrieve all lists

GET /api/v1/lists?id={id} - Retrieve a specific list

POST /api/v1/lists - Create a new list

PUT /api/v1/lists - Update an existing list

DELETE /api/v1/lists?id={id} - Delete a list

Items Management (/api/v1/items)
GET /api/v1/items - Retrieve all items

GET /api/v1/items?id={id} - Retrieve a specific item

POST /api/v1/items - Create a new item

PUT /api/v1/items - Update an existing item

DELETE /api/v1/items?id={id} - Delete an item

📁 Project Structure
text
training_api/
├── lib/
│   ├── models/
│   │   ├── list/list.dart    # TaskList model
│   │   └── items/item.dart   # Item model
│   └── repositories/
│       ├── list/list_repository.dart
│       └── item/item_repository.dart
├── routes/
│   ├── api/v1/
│   │   ├── lists/
│   │   │   └── index.dart    # Lists route handlers
│   │   └── items/
│   │       └── index.dart    # Items route handlers
├── REST-CLIENT-TESTER.HTTP    # API testing collection
└── pubspec.yaml              # Dependencies
🧪 Testing the API
Using the Included REST Client
The project includes a comprehensive REST-CLIENT-TESTER.HTTP file with VS Code REST Client extension format. This file contains:

Complete CRUD workflow examples

Edge case and error handling tests

Performance testing scenarios

Batch operation examples

Example API Calls
Create a new list:

bash
curl -X POST http://localhost:8080/api/v1/lists \
  -H "Content-Type: application/json" \
  -d '{"id": "list_001", "title": "Shopping List"}'
Get all items:

bash
curl -X GET http://localhost:8080/api/v1/items \
  -H "Content-Type: application/json"
🛠️ Key Implementation Details
Models
TaskList: Simple model with id and title properties

Item: Model with id, name, and description properties

Both models include toJson() and fromJson() methods for serialization

Repositories
Singleton pattern implementation for data persistence

In-memory storage using Dart Maps

Comprehensive error handling and validation

Route Handlers
Clean separation of HTTP method handlers

Proper status codes (200, 201, 204, 400, 404, 500)

JSON request/response handling

🤝 Contributing
Feel free to fork this repository and submit pull requests. This is a training project, so all improvements and suggestions are welcome!

📄 License
This project is open source and available for educational purposes.

Built with ❤️ using Dart Frog