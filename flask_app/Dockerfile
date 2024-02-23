FROM python:3.12.2-slim-bookworm

WORKDIR /app
COPY app/ /app/app/
RUN pip install --no-cache-dir -r app/requirements.txt
EXPOSE 5000
ENV FLASK_APP=app/app.py
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]
