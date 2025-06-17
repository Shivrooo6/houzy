const express = require("express");
const Stripe = require("stripe");
const cors = require("cors");

const app = express();
const stripe = Stripe("sk_test_51NqqEUSFQ0a1pnIOYhQTjCLTTV7CTGe4VKiO6Xk2u0sNTFtMWj9Yclsjz8d8Uyy98TZgisfuDcnleDWjw7dK9z6b00nkjb30By"); // Your Secret Key

app.use(cors());
app.use(express.json());

app.post("/create-payment-intent", async (req, res) => {
  const { amount, currency } = req.body;

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
    });

    res.send({
      clientSecret: paymentIntent.client_secret,
    });
  } catch (err) {
    res.status(500).send({ error: err.message });
  }
});

app.listen(3000, () => console.log("Server running on port 3000"));
