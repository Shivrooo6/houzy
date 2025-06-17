const express = require('express');
const app = express();
const stripe = require('stripe')('sk_test_51NqqEUSFQ0a1pnIOYhQTjCLTTV7CTGe4VKiO6Xk2u0sNTFtMWj9Yclsjz8d8Uyy98TZgisfuDcnleDWjw7dK9z6b00nkjb30By'); // ⚠️ Replace with your actual secret key
const cors = require('cors');

app.use(cors());
app.use(express.json());

app.post('/create-payment-intent', async (req, res) => {
  const { amount } = req.body;

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency: 'usd',
      automatic_payment_methods: { enabled: true },
    });

    res.send({
      clientSecret: paymentIntent.client_secret,
    });
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

app.listen(4242, () => {
  console.log('✅ Server running on http://localhost:4242');
});
