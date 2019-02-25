import flask
from flask import request
from flask import Flask
import mysql.connector
import json
import hashlib

FlaskApp = Flask(__name__, template_folder='templates')
FlaskApp.debug = False
FlaskApp.secret_key = 'development'

@FlaskApp.route('/')
def Homepage():
    return flask.render_template('pages/home.html')

@FlaskApp.route('/clientinfo')
def ClientInfoPage():
    return flask.render_template('pages/clientinfo.html')

@FlaskApp.route('/accounts')
def AccountsPage():
    (conn, cur) = connect()
    return flask.render_template('pages/accounts.html')

@FlaskApp.route('/accounts/create')
def CreateAccountPage():

    (conn, cur) = connect()

    username = request.args.get('username')
    password = request.args.get('password')

    if create_account(conn, cur, username, password):
        return flask.render_template('pages/succeed.html')
    else:
        return flask.render_template('pages/failed.html')

@FlaskApp.route('/giveaway')
def GiveawayPage():
    (conn, cur) = connect()
    return flask.render_template('pages/giveaway.html')

def query_accounts(conn, cur):

    sql = "SELECT id, name FROM accounts"

    cur.execute(sql)

    result = cur.fetchall()

    return result

def create_account(conn, cur, username, password):

    password_sha1 = hashlib.sha1(password.encode("ascii")).hexdigest()

    sql = "INSERT INTO accounts(name, password) VALUES (%s, %s)"
    val = (username, password_sha1)

    cur.execute(sql, val)
    conn.commit()

    return True

def connect():
    mydb = mysql.connector.connect(
        host="localhost",
        user="root",
        passwd="root",
        database="odinms"
    )
    mycursor = mydb.cursor()

    return (mydb, mycursor)
    
if __name__ == "__main__":
    from cherrypy  import wsgiserver
        
    server = wsgiserver.CherryPyWSGIServer(('0.0.0.0', 8080), FlaskApp)
    try:
        server.start()
    except KeyboardInterrupt:
        server.stop()
