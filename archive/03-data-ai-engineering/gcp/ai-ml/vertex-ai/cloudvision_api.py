from google.cloud import vision
import os

def detect_labels(image_path: str):
     client = vision.ImageAnnotatorClient()

     if 'gs://' in image_path or 'https://' in image_path or 'http://' in image_path:
          image = vision.Image()
          file_uri = image_path
          image.source.image_uri = file_uri
          # Performs label detection on the image file
          response = client.label_detection(image=image)
          labels = response.label_annotations
     else:
          file_name = os.path.abspath(image_path)
          with open(file_name, 'rb') as image_file:
               content = image_file.read()
          image = vision.Image(content=content)
          response = client.label_detection(image=image)
          labels = response.label_annotations
     print("Labels:")
     for label in labels:
          print(label.description)

     return labels