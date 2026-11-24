from google.cloud import language_v2
import argparse


def sentiment_analysis(text: str) -> None:
     """
     Analyses text using NLP Google Cloud Language API

     Args:
          text: The text content to analyze
     """

     client = language_v2.LanguageServiceClient()
     document_type_in_plain_text = language_v2.Document.Type.PLAIN_TEXT
     language = "en"
     document = {
          "content": text,
          "type_": document_type_in_plain_text,
          "language_code": language,
     }

     encoding_type = language_v2.EncodingType.UTF8
     response = client.analyze_sentiment(
          request={"document": document, "encoding_type": encoding_type}
     )
    # Get sentiment for all sentences in the document
     for sentence in response.sentences:
          print(f"Sentence text: {sentence.text.content}")
          print(f"Sentence sentiment score: {sentence.sentiment.score}")
          print(f"Sentence sentiment magnitude: {sentence.sentiment.magnitude}")

if __name__ == "__main__":
     parser = argparse.ArgumentParser(
                    prog='Language API Sentiment Analysis',
                    description='Uses Language API with a text to understand the emotions behind it. Neutral, positive or negative',
                    )
     parser.add_argument('-t','--text',help='Text you want to analyze.')
     args = parser.parse_args()
     
     sentiment_analysis(args.text)