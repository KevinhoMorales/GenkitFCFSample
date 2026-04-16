const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const { generateText } = require("./flow");

exports.generate = onRequest(
    {
        secrets: ["GOOGLE_API_KEY"], // 🔥 IMPORTANTE
    },
    async (req, res) => {
        try {
            const text = req.body.text || "una app de comida";

            const result = await generateText({ text });

            res.json({
                success: true,
                data: result,
            });
        } catch (error) {
            logger.error(error);

            res.status(500).json({
                success: false,
                error: error.toString(),
            });
        }
    }
);