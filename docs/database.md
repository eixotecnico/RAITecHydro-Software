# Estrutura Firestore

users (collection)
 └── {userId} (document)
      └── plantas (subcollection)
           └── {plantaId} (document)
                ├── nome
                ├── localizacao
                ├── criada
                └── sensores (subcollection)
                     ├── historico (document)
                     │    └── registros (subcollection)
                     │         └── {registroId}
                     │              ├── luminosidade
                     │              ├── temperatura
                     │              ├── umidade
                     │              └── timestamp
                     └── tempo_real (document)
                          ├── luminosidade
                          ├── temperatura
                          ├── umidade
                          └── updatedAt


paired_devices (collection)
 └── {espId} (document)
          ├── espId
          ├── plantaId
          ├── status
          ├── updatedAt
          └── userId