const express = require('express');
const admin = require('firebase-admin');
const bodyParser = require('body-parser');

const app = express();

app.use(bodyParser.json());
const serviceAccount = require('./Firebase_Admin.json');
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

app.get('/admin', async (req, res) => {
    const db = admin.firestore();
    try {
        // Lấy document cụ thể trong collection 'admin'
        const docRef = db.collection('admin').doc('DJkNTXeJfbFYTV8GMKHx');
        const doc = await docRef.get();

        if (!doc.exists) {
            res.status(404).json({ error: 'Admin not found' });
        } else {
            res.json({ id: doc.id, ...doc.data() });
        }
    } catch (error) {
        console.error("Lỗi khi lấy dữ liệu:", error);
        res.status(500).send("Error fetching admin");
    }
});

app.listen(3000, () => {
    console.log('Server is running on port 3000');
});