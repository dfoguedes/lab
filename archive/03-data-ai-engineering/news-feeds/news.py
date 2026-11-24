from google import genai
from google.genai import types
import feedparser
import os
import datetime

client = genai.Client(api_key=os.environ["GOOGLE_API_KEY"])
SYSTEM_INSTRUCTION="A resposta deve ser sempre em Portugues de Portugal. " \
"deves agrupar por categoria, formatar com emojis" \
" identificar apenas aqueles que forem de grande importancia" \
" e no limite de 5 noticias. " \
"A resposta deve ser formatada em markdown " \
"e deve conter um titulo para cada categoria. " \
"A resposta deve conter um resumo de cada noticia " \
"e o link para ler a noticia completa."


URLS = ["https://observador.pt/feed/",
        "https://www.rtp.pt/noticias/rss/",
        "https://shifter.pt/feed/",
        "https://feeds.arstechnica.com/arstechnica/index",
        "https://www.theverge.com/rss/index.xml",
        "https://techcrunch.com/feed/",
        "https://feeds.feedburner.com/TheHackersNews",
        "https://hnrss.org/frontpage",
        "https://www.wired.com/feed/rss",
        "https://pplware.sapo.pt/feed/",
        "https://abertoithoje.pt/feed/",
        ]

def summarize(entries):
    prompts = []
    for entry in entries:
        prompt = f"Title: {entry.title} , Summary: {entry.summary}, Link: {entry.link}"
        prompts.append(prompt)

    response = client.models.generate_content(
        model="gemini-2.5-flash-lite",
        contents=prompts,
        config=types.GenerateContentConfig(system_instruction=SYSTEM_INSTRUCTION) 
    )
    return response.text



def get_entries(URLS):
    entries = []
    for url in URLS:
        entries.extend(feedparser.parse(url).entries)

    return entries
def main():
    entries  = get_entries(URLS)
    print(summarize(entries))


main()