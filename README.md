# ARMessenger Mobile App 📲

**ARMessenger** is a modern real-time chat application built with **Flutter** and powered by a **Laravel 11** backend. This mobile client connects to the same backend as the web version and allows users to communicate securely using WebSockets and per-user encrypted messages.

---

## 🚀 Features

- 🔐 **Authentication** (Login, Register) using Laravel Sanctum
- 💬 **Real-time chat** with Laravel Reverb (WebSocket)
- 📦 **Paginated messages** with auto-scroll to latest
- 🧑‍🤝‍🧑 **Contact system** (Add, Remove)
- ✉️ **Invitation management** (Send, Accept, Refuse)
- 🔐 **Encrypted messages** using a per-user encryption key
- ⚙️ **Token expiration handling** with redirect to login
- 🔄 Automatic logout and error management
- 📱 Designed for easy future extension (media sharing, calls, etc.)

---

## 🧱 Tech Stack

- **Flutter** (latest stable)
- **Dart**
- `http` for API requests  
- `provider` for state management  
- `web_socket_channel` for WebSocket communication  
- **Laravel Sanctum** for secure API authentication

---
