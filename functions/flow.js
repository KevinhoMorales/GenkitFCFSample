const { genkit, z } = require("genkit");
const { googleAI } = require("@genkit-ai/googleai");

// Inicializar Genkit
const ai = genkit({
    plugins: [
        googleAI({
            apiKey: process.env.GOOGLE_API_KEY, // 🔥 viene de Firebase Secret
        }),
    ],
});

// Definir flujo
const generateText = ai.defineFlow(
    {
        name: "generateText",
        inputSchema: z.object({
            text: z.string(),
        }),
    },
    async (input) => {
        const response = await ai.generate({
            model: googleAI.model("gemini-2.5-flash"), // 🔥 modelo estable
            prompt: `Describe this app idea: ${input.text}`,
        });

        return response.text; // 🔥 Genkit 1.x usa .text
    }
);

module.exports = { generateText };