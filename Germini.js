const { GoogleGenAI } = require("@google/genai");

const ai = new GoogleGenAI({ apiKey: "AIzaSyDs9SvSTrcxRNCEesr3KzOrNy4glg05Fvo" });

async function main(contents_input) {
  const response = await ai.models.generateContent({
    model: "gemini-2.0-flash",
    contents: contents_input,
  });
  console.log(response.text);
}

main("hello");