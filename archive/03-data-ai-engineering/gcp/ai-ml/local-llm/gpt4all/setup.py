# This program allows us to run local LLMs on our machine (offline)
from gpt4all import GPT4All

MODEL_NAME = "orca-mini-3b-gguf2-q4_0.gguf" # open source model (size: 1.98GB)
try: 
     model = GPT4All(MODEL_NAME)
except Exception as e:
     print(f"Error loading model: {e}")
     exit(1)
# the model in Linux will be downloaded under ~/.cache/gpt4all/models

print("Local LLM chat. Type 'exit' or 'quit' to end.")

with model.chat_session():
    while True:
          user_input = input("Ask anything: ")
          if user_input.lower() in ["exit", "quit"]:
            print("Existing chat...")
            break
          else:
               try:
                   response = model.generate(user_input, max_tokens=1024)
                   print(f"Bot Response: {response}")
               except Exception as e:
                   print(f"Error occurred: {e}")