from google import genai
import os
client = genai.Client(api_key=os.environ["GOOGLE_API_KEY"])

history = []
history.append(" O agente deve falar em Portugues de portugal, se muito suncinto e pratico.\n")
# LLM does not have memory. We need to provide the history of the conversation in each request.

MAX_MESSAGES=10

def summarize(history):

    prompt = "Summarize the following conversation:\n" + "\n".join(history)
    response = client.models.generate_content(
        model="gemini-2.5-flash-lite",
        contents=[prompt]
    )
    return response.text

while True:
    user_input = input("You: \n")
    history.append(user_input)

    if len(history) > MAX_MESSAGES:
        summary = summarize(history)
        history = [summary]
    response = client.models.generate_content(
        model="gemini-2.5-flash-lite",
        contents=history
    )
    reply = response.text
    history.append(reply)
    print(f"Gemini: {reply}")