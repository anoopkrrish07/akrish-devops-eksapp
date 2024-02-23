from flask import Flask, Response
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text
import logging
from logging.handlers import RotatingFileHandler
import os

app = Flask(__name__)

database_uri = os.getenv('SQLALCHEMY_DATABASE_URI', 'postgresql://akrish:password123@localhost:5432/test-db')
app.config['SQLALCHEMY_DATABASE_URI'] = database_uri
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

if not os.path.exists('logs'):
    os.mkdir('logs')
file_handler = RotatingFileHandler('logs/flask_app.log', maxBytes=10240, backupCount=10)
file_handler.setFormatter(logging.Formatter('%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'))
file_handler.setLevel(logging.INFO)
app.logger.addHandler(file_handler)

app.logger.setLevel(logging.INFO)
app.logger.info('Flask application startup')

@app.route('/success', methods=['GET'])
def success():
    try:
        db.session.execute(text('SELECT 1'))
        app.logger.info("Database query executed successfully.")
        return Response("Well done :)", mimetype='text/plain; charset=utf-8')
    except Exception as e:
        app.logger.error(f"An error occurred: {e}")
        return Response("Failed to connect to the database.", mimetype='text/plain; charset=utf-8')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
