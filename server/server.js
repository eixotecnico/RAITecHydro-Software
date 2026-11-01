const admin = require("firebase-admin");
const mqtt = require("mqtt");
const cron = require("node-cron");

const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const client = mqtt.connect("mqtt://broker.hivemq.com:1883");

// Mapa dinâmico na memória
let deviceMap = {};

// 1. Carrega e monitora os pareamentos do Firestore
async function carregarConfiguracoes() {
  console.log("🔄 Monitorando mapeamentos de dispositivos...");
  
  db.collection("paired_devices").onSnapshot((snapshot) => {
    // Sempre que houver mudança, atualizamos o mapa do zero para garantir consistência
    let novoMapa = {}; 
    snapshot.forEach((doc) => {
      const data = doc.data();
      novoMapa[data.espId] = {
        userId: data.userId,
        plantaId: data.plantaId
      };
    });
    deviceMap = novoMapa;
    console.log("✅ Mapeamento atualizado:", deviceMap);
  });
}

carregarConfiguracoes();

const ultimosDados = {};

// 2. Conexão MQTT
client.on("connect", () => {
  console.log("📡 Conectado ao broker MQTT");
  client.subscribe("regador/data");
});

// 3. Recebimento e processamento de dados
client.on("message", async (topic, message) => {
  console.log("📥 RAW MQTT:", message.toString());

  try {
    const payload = JSON.parse(message.toString());
    const { espId, temperatura, umidade, luminosidade } = payload;

    // Busca o vínculo no mapa
    const config = deviceMap[espId];

    if (!config) {
      console.warn(`⚠️ ESP ${espId} não pareada. Configure no Firestore.`);
      return;
    }

    const { userId, plantaId } = config;

    // Atualiza cache para o Histórico (Cron)
    ultimosDados[plantaId] = {
      userId,
      temperatura,
      umidade,
      luminosidade,
      timestamp: Date.now(),
    };

    // Salva Tempo Real no Firestore
    await db
      .collection("users")
      .doc(userId)
      .collection("plantas")
      .doc(plantaId)
      .collection("sensores")
      .doc("tempo_real")
      .set({
        temperatura,
        umidade,
        luminosidade,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    console.log(`✅ Sucesso: Planta ${plantaId} atualizada.`);

  } catch (e) {
    console.error("❌ Erro ao processar mensagem:", e.message);
  }
});

// 4. Histórico a cada 10 minutos
cron.schedule("*/10 * * * *", async () => {
  console.log("⏱ Salvando histórico...");

  for (const id in ultimosDados) {
    const dados = ultimosDados[id];

    if (!dados) continue;

    // Verifica se os dados são recentes (últimos 15 min)
    if (Date.now() - dados.timestamp > 15 * 60 * 1000) {
      console.log(`⚠️ Planta ${id} sem dados novos para o histórico.`);
      continue;
    }

    try {
      const historicoRef = db
        .collection("users")
        .doc(dados.userId)
        .collection("plantas")
        .doc(id)
        .collection("sensores")
        .doc("historico")
        .collection("registros");

      await historicoRef.add({
        temperatura: dados.temperatura,
        umidade: dados.umidade,
        luminosidade: dados.luminosidade,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log(`📈 Histórico salvo para planta: ${id}`);
    } catch (err) {
      console.error("❌ Erro ao salvar histórico:", err.message);
    }
  }
});