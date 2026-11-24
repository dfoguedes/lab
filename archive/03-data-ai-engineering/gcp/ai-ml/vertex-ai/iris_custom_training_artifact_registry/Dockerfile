FROM python:3.7-buster
WORKDIR /root
COPY vertexai_custom_training.py /root/vertexai_custom_training.py
COPY requirements.txt /root/requirements.txt
RUN pip install -r /root/requirements.txt

ENTRYPOINT ["python","vertexai_custom_training.py"]