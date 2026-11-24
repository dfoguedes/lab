from yt_dlp import YoutubeDL
import whisper 
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_core.documents import Document
from langchain_community.document_loaders.text import TextLoader
from langchain_community.llms.ollama import Ollama
from langchain_classic.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate
import logging
import os


logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
URL= 'https://www.youtube.com/watch?v=MmmW2s9uWhc'
FILE_NAME="audio.mp3"
TRANSCRIPT_FILE="transcription.txt"

def get_transcript():
    logging.info("Downloading YouTube video from URL: %s", URL)
    ydl_opts = {
        'format': 'bestaudio/best',
        'quiet': False,
        'no_warnings': False,
        'source_address': '0.0.0.0', 
        'extractor_args': {'youtube': {'player_client': ['android']}},
        'user_agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'postprocessors': [{
            'key': 'FFmpegExtractAudio',
            'preferredcodec': 'mp3',
            'preferredquality': '192',
        }],
        'outtmpl': 'audio',
}
    try:
        with YoutubeDL(ydl_opts) as ydl:
            ydl.download(URL)
        logging.info("Download finished: %s", FILE_NAME)
    except Exception as e:
        logging.error("Error: %s", str(e))

    try:
        model = whisper.load_model("base")
        result = model.transcribe(f"./{FILE_NAME}",fp16=False,verbose=True)
        with open(f"{TRANSCRIPT_FILE}", "w", encoding="utf-8") as f:
            f.write(result["text"]) 
        logging.info("Transcription finished: %s", TRANSCRIPT_FILE)
        if os.path.exists(f"./{FILE_NAME}"):
            os.remove(path=f"./{FILE_NAME}")

    except Exception as e:
        logging.error("Error: %s", str(e))
def summarize(document):
    llm = Ollama(model="llama3")
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=2000, chunk_overlap=200)
    loader_docs = TextLoader(file_path=document, encoding='utf-8').load()
    docs = text_splitter.split_documents(loader_docs)
    prompt = ChatPromptTemplate.from_messages([
    ("system", "Create a clear, educational summary."),
    ("human", "Summarize this video transcript in bullet points:\n- What is the main topic?\n- What are the 3-5 key points?\n- What are practical takeaways?\n\n{context}")
    ])
    # map reduce for long texts
    logging.info("Starting summarization...")
    chain = create_stuff_documents_chain(llm=llm, prompt=prompt)
    result = chain.invoke({"context": docs})
    logging.info("Summarization result: %s", result)
    print(result)
    if os.path.exists(f"./{TRANSCRIPT_FILE}"):
        os.remove(path=f"./{TRANSCRIPT_FILE}")

def main():
    get_transcript()
    summarize(document=TRANSCRIPT_FILE)

if __name__ == "__main__":
    main()