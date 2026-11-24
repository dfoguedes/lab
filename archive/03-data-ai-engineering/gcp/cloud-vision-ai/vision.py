from google.cloud import vision
"""Cloud VISION """

def detect_properties(path: str) -> None:
    """Detects properties of an image."""
    client = vision.ImageAnnotatorClient()
    with open(path, "rb") as image_file:
        content = image_file.read()
    image = vision.Image(content=content)
    response = client.image_properties(image=image)
    props = response.image_properties_annotation
    print("Properties:")
    for color in props.dominant_colors.colors:
     print(f"fraction: {color.pixel_fraction}")
     print(f"\tr: {color.color.red}")
     print(f"\tg: {color.color.green}")
     print(f"\tb: {color.color.blue}")
     print(f"\ta: {color.color.alpha}")

    if response.error.message: 
      raise Exception(
            "{}\nFor more info on error messages, check: "
            "https://cloud.google.com/apis/design/errors".format(response.error.message)
        )

def detect_objects(path: str) -> None:
    """Detects objects in an image."""
    client = vision.ImageAnnotatorClient()
    with open(path, "rb") as image_file:
        content = image_file.read()
    image = vision.Image(content=content)
    response = client.object_localization(image=image)
    objects = response.localized_object_annotations
    print("Objects:")
    for obj in objects:
        print(f"Name: {obj.name}")
        print(f"Score: {obj.score}")
        print("Normalized Vertices:")

def detect_logo(path: str) -> None:
     """Detects logos in an image."""
     client = vision.ImageAnnotatorClient()
     with open(path, "rb") as image_file:
         content = image_file.read()
     image = vision.Image(content=content)
     response  = client.logo_detection(image=image)
     logos = response.logo_annotations
     print("Logos:")
     for logo in logos:
         print(f"Description: {logo.description}")
         print(f"Score: {logo.score}")
if __name__ == "__main__":
#     detect_properties('hq720.jpg')
     # detect_objects('hq720.jpg')
     detect_logo('vodafone.jpg')   