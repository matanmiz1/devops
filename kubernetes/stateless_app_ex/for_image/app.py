
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)

#app.config.from_pyfile('config.cfg')

user = os.environ.get('POSTGRES_USER')
password = os.environ.get('POSTGRES_PASSWORD')
host = os.environ.get('POSTGRES_HOST')
port = os.environ.get('POSTGRES_PORT')
database = os.environ.get('POSTGRES_DB')

app.config['SQLALCHEMY_DATABASE_URI'] = f'postgres://{user}:{password}@{host}:{port}/{database}'

db = SQLAlchemy(app)
db.init_app(app)


class User(db.Model):
        __tablename__ = 'users'
        id = db.Column(db.Integer(), primary_key=True)
        name = db.Column(db.String())
        surname = db.Column(db.String())

@app.route('/test')
def test():
        return 'Hello World! I am from docker!'

@app.route('/test_db')
def test_db():
        db.create_all()
        db.session.commit()
        user = User.query.first()
        if not user:
            u = User(name='Matan', surname='Mizrahi')
            db.session.add(u)
            db.session.commit()
        user = User.query.first()
        return "User '{} {}' is from database".format(user.name, user.surname)
