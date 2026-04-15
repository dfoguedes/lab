from google import genai
from google.genai import types
import os
import datetime

client = genai.Client(api_key=os.environ["GOOGLE_API_KEY"])

history = []
# LLM does not have memory. We need to provide the history of the conversation in each request.

MAX_MESSAGES = 10


def summarize(history):

    prompt = "Summarize the following conversation:\n" + "\n".join([f"{content.role}: {content.parts[0].text}" for content in history if content.parts[0].text is not None])
    response = client.models.generate_content(
        model="gemini-2.5-flash-lite", contents=[prompt],
        config=types.GenerateContentConfig(system_instruction="o agente deve falar em Portugues de portugal, se muito suncinto e pratico.")
    )
    return response.text


def get_current_time():
    return datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")


tools = [
    types.Tool(
        function_declarations=[
            {
                "name": "get_current_time",
                "description": "Returns the current date and time in the format YYYY-MM-DD HH:MM:SS",
                "parameters": {"type": "object", "properties": {}, "required": []},
            }
        ]
    )
]
while True:
    user_input = input("You: ")
    # Content is the input format for the Gemini API. It consists of a role (user, assistant, system)
    #  and parts (text, function_call, tool_calls).
    history.append(types.Content(role="user", parts=[types.Part(text=user_input)]))

    if len(history) > MAX_MESSAGES:
        summary = summarize(history)
        history = [types.Content(role="model", parts=[types.Part(text=summary)])]
    response = client.models.generate_content(
        model="gemini-2.5-flash-lite",
        contents=history, 
        config=types.GenerateContentConfig(tools=tools,system_instruction="o agente deve falar em Portugues de portugal, se muito suncinto e pratico."),
    )

    if (
        response.candidates
        and response.candidates[0].content
        and response.candidates[0].content.parts
        and response.candidates[0].content.parts[0].function_call
    ):
        history.append(response.candidates[0].content)
        tool_call = response.candidates[0].content.parts[0].function_call
        if tool_call.name == "get_current_time":
            result = get_current_time()
            history.append(types.Content(role="tool",
                                            parts=[types.Part(function_response=types.FunctionResponse(name=tool_call.name, response={"result": result}))]))
            response = client.models.generate_content(
                model="gemini-2.5-flash-lite",
                contents=history,
                config=types.GenerateContentConfig(tools=tools,system_instruction="o agente deve falar em Portugues de portugal, se muito suncinto e pratico."),
            )
        else:
            history.append(types.Content(role="tool", parts=[types.Part(function_response=types.FunctionResponse(name=tool_call.name, 
                                                                                                                    response={"result": "Tool not implemented"}))]))
            break

    reply = result
    history.append(types.Content(role="model", parts=[types.Part(text=reply)]))
    print(f"\nGemini: {reply}")
