import flask
from flask import request
from flask import Flask
import mysql.connector
import json
import datetime
import hashlib

FlaskApp = Flask(__name__, template_folder='templates')
FlaskApp.debug = True
FlaskApp.secret_key = 'development'

auth_fail_callback = "https://plusplus7.com/storage/maplestore"

def validate_token(token):
    if token == None:
        return ('Anonymous', False)

    tokens = token.split(":")

    if len(tokens) != 5:
        return ('Anonymous', False)

    date = tokens[0]
    curdate = datetime.datetime.now().strftime('%Y-%m-%d')
    if date != curdate:
        return ('Anonymous', False)

    user = tokens[1]
    data = tokens[2]
    content = f"{date}:{user}:{data}"

    signature = hmac.new(FlaskApp.secret_key, msg=content.encode("ascii"), digestmod=hashlib.sha256).hexdigest()
    if tokens[3] == signature:
        return (user, True)

    return (f'Anonymous-{user}', False)

@FlaskApp.route('/', methods=['GET', 'POST'])
def Homepage():
    if request.method == 'POST':
        token = request.args.get('token')
        (username, isValidToken) = validate_token(token)
        if isValidToken == False:
            flask.redirect(auth_fail_callback)

        resp = make_response(flask.render_template('pages/home.html', username = username))
        resp.set_cookie('token', token)
        return resp

    else:
        (username, isValidToken) = validate_token(request.cookies.get('token'))
        if isValidToken == False:
            return flask.redirect(auth_fail_callback)
        return flask.render_template('pages/home.html')

@FlaskApp.route('/clientinfo')
def ClientInfoPage():
    (username, isValidToken) = validate_token(request.cookies.get('token'))
    if isValidToken == False:
        return flask.redirect(auth_fail_callback)

    return flask.render_template('pages/clientinfo.html')

@FlaskApp.route('/accounts')
def AccountsPage():
    (username, isValidToken) = validate_token(request.cookies.get('token'))
    if isValidToken == False:
        return flask.redirect(auth_fail_callback)

    (conn, cur) = connect()
    return flask.render_template('pages/accounts.html')

@FlaskApp.route('/accounts/create')
def CreateAccountPage():
    (username, isValidToken) = validate_token(request.cookies.get('token'))
    if isValidToken == False:
        return flask.redirect(auth_fail_callback)

    (conn, cur) = connect()

    username = request.args.get('username')
    password = request.args.get('password')

    if create_account(conn, cur, username, password):
        return flask.render_template('pages/succeed.html')
    else:
        return flask.render_template('pages/failed.html')

@FlaskApp.route('/giveaway')
def GiveawayPage():
    (username, isValidToken) = validate_token(request.cookies.get('token'))
    if isValidToken == False:
        return flask.redirect(auth_fail_callback)

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
    FlaskApp.run()

"""    from cherrypy  import wsgiserver
        
    server = wsgiserver.CherryPyWSGIServer(('0.0.0.0', 8080), FlaskApp)
    try:
        server.start()
    except KeyboardInterrupt:
        server.stop()

"""