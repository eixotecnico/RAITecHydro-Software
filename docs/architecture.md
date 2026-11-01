#  Arquitetura do Sistema – Regador Automático

##  Tecnologias

- Flutter (App Mobile)
- Node.js (Servidor)
- Firebase Firestore (Banco de Dados)
- Firebase Auth (Autenticação)
- MQTT (Sensores IoT)

---

##  Fluxo de Dados

Sensores(ESP) → MQTT(Broker) → Node.js(Servidor) → Firebase Firestore(Banco de Dados) → Flutter(Aplicativo)


- Os dados coletados pelos sensores de luminosidade, temperatura e umidade, utilizando o microcontrolador ESP32, são publicados via protocolo MQTT em um broker.

- O servidor Node.js assina os tópicos MQTT, processa as mensagens recebidas e realiza a persistência das informações no Firebase Firestore.

- O aplicativo Flutter consome os dados armazenados no Firestore, exibindo informações de histórico e dados em tempo real ao usuário.


---

##  Aplicativo Flutter

Responsável por:
- Exibir dados em tempo real
- Cadastro de plantas
- Mostrar os Gráficos
- Relatórios

---

##  Servidor Node.js

Responsável por:
- Receber dados MQTT
- Salvar histórico
- Atualizar tempo_real
