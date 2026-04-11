from google import genai
from google.genai import types
import os
import datetime
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

def get_current_time():
    return datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")


tools = [types.Tool(
    function_declarations=[{
        "name": "get_current_time",
        "description": "Returns the current date and time in the format YYYY-MM-DD HH:MM:SS",
        "parameters": {
            "type": "object",
            "properties": {},
            "required": []
        }
    }]

)]
while True:
    user_input = input("You: ")
    history.append(user_input)

    if len(history) > MAX_MESSAGES:
        summary = summarize(history)
        history = [summary]
    response = client.models.generate_content(
        model="gemini-2.5-flash-lite",
        contents=history,
        config=types.GenerateContentConfig(tools=tools)
    )

    if response.candidates[0].content.parts[0].function_call:
        if (response.candidates and 
            response.candidates[0].content and 
            response.candidates[0].content.parts and
            response.candidates[0].content.parts[0].function_call):
            tool_call = response.candidates[0].content.parts[0].function_call
        if tool_call.name == "get_current_time":
            result = get_current_time()
            history.append(f"Tool call: {tool_call.name} with result: {result}")
            response = client.models.generate_content(
                    model="gemini-2.5-flash-lite",
                    contents=history,
                    config=types.GenerateContentConfig(tools=tools)
                )
        else: 
            history.append("Tool call:" + tool_call.name + " not found")
            break
            
    
    reply = response.text
    history.append(reply)
    print(f"\nGemini: {reply}")