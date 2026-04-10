from google import genai
import os
client = genai.Client(api_key=os.environ["GOOGLE_API_KEY"])

history = []
history.append(" O agente deve falar em Portugues de portugal, se muito suncinto e pratico.\n")
# LLM does not have memory. We need to provide the history of the conversation in each request.

MAX_MESSAGES=10

while True:
    user_input = input("You: ")
    history.append(user_input)
    window = history[-MAX_MESSAGES:]
    response = client.models.generate_content(
        model="gemini-2.5-flash-lite",
        contents=window
    )
    reply = response.text
    history.append(reply)
    print(f"Gemini: {reply}")