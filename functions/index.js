const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.receberDados = functions.https.onRequest(async (req, res) => {
  try {
    const { espId, temperatura, umidade, luminosidade } = req.body;

    if (!espId) {
      return res.status(400).send("espId obrigatório");
    }

    await db.collection("dados").add({
      espId,
      temperatura,
      umidade,
      luminosidade,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.send("ok");
  } catch (err) {
    console.error(err);
    res.status(500).send("erro");
  }
});