# 🐸 Dart Frog RESTful API Training Project

A clean, modular RESTful API built with [Dart Frog](https://dartfrog.vgv.dev/) for managing task lists and items. This project demonstrates proper API architecture, error handling, and repository patterns in Dart.

[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Dart Frog](https://img.shields.io/badge/Dart_Frog-02569B?style=for-the-badge&logo=dart&logoColor=white)](https://dartfrog.vgv.dev/)

## ✨ Features

- **Complete CRUD Operations**: Full create, read, update, and delete functionality for both lists and items
- **Clean Architecture**: Separated models, repositories, and route handlers
- **Singleton Pattern**: Properly implemented repository pattern with singleton instances
- **Comprehensive Error Handling**: Meaningful HTTP status codes and error messages
- **In-Memory Storage**: Easy-to-understand data persistence using Dart Maps
- **REST Client Testing**: Ready-to-use API testing with included HTTP client file
- **Type Safety**: Leveraging Dart's strong typing system

## 🚀 Getting Started

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) (version 3.0 or higher)
- [Dart Frog CLI](https://pub.dev/packages/dart_frog_cli)

```bash
# Install Dart Frog CLI globally
dart pub global activate dart_frog_cli
```

### Installation

1. Clone the repository:

```bash
git clone https://github.com/AhmedShaltout85/training_dart_frog_api.git
cd training_dart_frog_api
```

2. Install dependencies:

```bash
dart pub get
```

3. Run the development server:

```bash
dart_frog dev
```

The server will start at `http://localhost:8080` 🎉

## 📚 API Documentation

### Base URL
```
http://localhost:8080/api/v1
```

### Lists Management (`/api/v1/lists`)

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| `GET` | `/lists` | Retrieve all lists | - |
| `GET` | `/lists?id={id}` | Retrieve a specific list | - |
| `POST` | `/lists` | Create a new list | `{"id": "string", "title": "string"}` |
| `PUT` | `/lists` | Update an existing list | `{"id": "string", "title": "string"}` |
| `DELETE` | `/lists?id={id}` | Delete a list | - |

### Items Management (`/api/v1/items`)

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| `GET` | `/items` | Retrieve all items | - |
| `GET` | `/items?id={id}` | Retrieve a specific item | - |
| `POST` | `/items` | Create a new item | `{"id": "string", "name": "string", "description": "string"}` |
| `PUT` | `/items` | Update an existing item | `{"id": "string", "name": "string", "description": "string"}` |
| `DELETE` | `/items?id={id}` | Delete an item | - |

### HTTP Status Codes

- `200 OK` - Successful GET/PUT request
- `201 Created` - Successful POST request
- `204 No Content` - Successful DELETE request
- `400 Bad Request` - Invalid request data
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

## 📁 Project Structure

```
training_dart_frog_api/
├── lib/
│   ├── models/
│   │   ├── list/
│   │   │   └── list.dart          # TaskList model
│   │   └── items/
│   │       └── item.dart          # Item model
│   └── repositories/
│       ├── list/
│       │   └── list_repository.dart
│       └── item/
│           └── item_repository.dart
├── routes/
│   ├── api/
│   │   └── v1/
│   │       ├── lists/
│   │       │   └── index.dart     # Lists route handlers
│   │       └── items/
│   │           └── index.dart     # Items route handlers
│   └── index.dart                  # Root route
├── test/
│   └── routes/                     # Route tests
├── .vscode/
│   └── settings.json               # VS Code settings
├── REST-CLIENT-TESTER.HTTP         # API testing collection
├── analysis_options.yaml           # Dart analyzer configuration
├── pubspec.yaml                    # Dependencies
└── README.md                       # This file
```

## 🧪 Testing the API

### Using the Included REST Client

The project includes a comprehensive `REST-CLIENT-TESTER.HTTP` file with examples for the [REST Client VS Code extension](https://marketplace.visualstudio.com/items?itemName=humao.rest-client). This file contains:

- ✅ Complete CRUD workflow examples
- ✅ Edge case and error handling tests
- ✅ Performance testing scenarios
- ✅ Batch operation examples

### Example API Calls

**Create a new list:**

```bash
curl -X POST http://localhost:8080/api/v1/lists \
  -H "Content-Type: application/json" \
  -d '{"id": "list_001", "title": "Shopping List"}'
```

**Get all items:**

```bash
curl -X GET http://localhost:8080/api/v1/items \
  -H "Content-Type: application/json"
```

**Update an item:**

```bash
curl -X PUT http://localhost:8080/api/v1/items \
  -H "Content-Type: application/json" \
  -d '{"id": "item_001", "name": "Updated Name", "description": "New description"}'
```

**Delete a list:**

```bash
curl -X DELETE "http://localhost:8080/api/v1/lists?id=list_001"
```

## 🛠️ Key Implementation Details

### Models

**TaskList**: Simple model with `id` and `title` properties

```dart
class TaskList {
  final String id;
  final String title;
  
  TaskList({required this.id, required this.title});
  
  Map<String, dynamic> toJson() => {'id': id, 'title': title};
  factory TaskList.fromJson(Map<String, dynamic> json) => 
    TaskList(id: json['id'], title: json['title']);
}
```

**Item**: Model with `id`, `name`, and `description` properties

```dart
class Item {
  final String id;
  final String name;
  final String description;
  
  Item({required this.id, required this.name, required this.description});
  
  Map<String, dynamic> toJson() => 
    {'id': id, 'name': name, 'description': description};
  factory Item.fromJson(Map<String, dynamic> json) => 
    Item(id: json['id'], name: json['name'], description: json['description']);
}
```

### Repositories

- **Singleton Pattern**: Ensures single instance of each repository
- **In-Memory Storage**: Using Dart Maps for quick data access
- **Type Safety**: Comprehensive error handling and validation
- **CRUD Operations**: Full create, read, update, delete support

### Route Handlers

- Clean separation of HTTP method handlers
- Proper status codes (200, 201, 204, 400, 404, 500)
- JSON request/response handling
- Query parameter validation

## 🎯 Learning Objectives

This project is designed to help you learn:

1. **Dart Frog Fundamentals**: Understanding the framework's routing and middleware system
2. **RESTful API Design**: Implementing proper REST conventions
3. **Repository Pattern**: Separating data access logic from business logic
4. **Error Handling**: Managing different error scenarios gracefully
5. **Data Serialization**: Converting between Dart objects and JSON
6. **HTTP Methods**: Understanding when to use GET, POST, PUT, DELETE

## 🚧 Future Enhancements

- [ ] Add database integration (PostgreSQL/MongoDB)
- [ ] Implement authentication and authorization
- [ ] Add validation middleware
- [ ] Include logging and monitoring
- [ ] Add unit and integration tests
- [ ] Implement pagination for list endpoints
- [ ] Add search and filtering capabilities
- [ ] Create API documentation with Swagger/OpenAPI

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

This is a training project, so all improvements and suggestions are appreciated!

## 📖 Resources

- [Dart Frog Documentation](https://dartfrog.vgv.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [RESTful API Design Best Practices](https://restfulapi.net/)

## 📝 License

This project is open source and available for educational purposes.

## 👤 Author

**Ahmed Shaltout**

- GitHub: [@AhmedShaltout85](https://github.com/AhmedShaltout85)

---

Built with ❤️ using [Dart Frog](https://dartfrog.vgv.dev/)

⭐ Star this repository if you find it helpful!