# 🌱 Regador Automático

Projeto de irrigação inteligente utilizando:

* ESP32
* Flutter
* Node.js
* MQTT

O repositório inclui um **Dev Container**, então todo o ambiente de desenvolvimento é criado automaticamente usando **Docker**.

---

# 📦 Pré-requisitos

Antes de começar, instale:

* Docker
* Visual Studio Code
* Extensão **Dev Containers** no VS Code

---

# 🚀 Como rodar o projeto

## 1️⃣ Clonar o repositório (Use o terminal)

```bash
git clone -b development https://github.com/eixotecnico/regador-automatico.git
cd regador
```

---

## 2️⃣ Abrir no VS Code

Abra a pasta do projeto no VS Code.

```bash
code .
```

---

## 3️⃣ Abrir dentro do Dev Container

O VS Code mostrará uma mensagem:

```
Reopen in Container
```

Clique nela.

O Docker irá:

* construir o container
* instalar Flutter
* instalar Node
* instalar ferramentas MQTT
* preparar o ambiente automaticamente

Isso pode levar alguns minutos na primeira vez.

---

# 🧪 Testar se o ambiente está funcionando

Abra o terminal dentro do container e execute:

```bash
flutter doctor
node -v
npm -v
```

Se aparecerem as versões, o ambiente está funcionando.

---

# 📂 Estrutura do projeto

```
regador
│
├── .devcontainer        # configuração do ambiente Docker
├── lib                  # aplicação Flutter
├── server               # backend Node.js
└── README.md
```

---

# 💡 Vantagem do Dev Container

Com esse sistema **não é necessário instalar manualmente**:

* Flutter
* Dart
* Node.js
* MQTT tools

Tudo já vem configurado dentro do container.

---

# 👩‍💻 Autor

Projeto desenvolvido pela equipe Regador Automático do Eixo Técnico do Raitec
