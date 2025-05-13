from flask import Flask, jsonify, request
import sqlite3
import hashlib
import datetime

app = Flask(__name__)
 
@app.route('/api/add_score', methods=['GET'])
def api_add_score():
    name = request.args.get('name')
    score = request.args.get('score')
    hash = request.args.get('hash')

    if (name == None or score == None or hash == None):
         return ""

    md5 = hashlib.md5(f'{name}_{score}_abcXYZ123!@#'.encode('utf-8')).hexdigest()
    if (hash!= md5):
        return ""

    add_score(name, score, datetime.datetime.now(), request.remote_addr)

    return ""
 

@app.route('/api/get_score', methods=['GET'])
def api_get_score():
    return jsonify(get_score())


def add_score(name, score, createtime, ip):
    db = sqlite3.connect('db.db')
    cursor = db.cursor()
    cursor.execute("INSERT INTO leaderboard (name, score, createtime, ip) VALUES (?, ?, ?, ?)", (name, score, createtime, ip))
    db.commit()
    cursor.close()
    db.close()


def get_score():
    query = """
    SELECT name, MAX(score) AS max_score
    FROM leaderboard
    GROUP BY name
    ORDER BY max_score DESC
    LIMIT 100;
    """
    
    db = sqlite3.connect('db.db')
    cursor = db.cursor()
    cursor.execute(query)
    rows = cursor.fetchall()
    result = [{"name": row[0], "max_score": row[1]} for row in rows]
    db.commit()
    db.close

    return result

def create_table():
    db = sqlite3.connect('db.db')
    cursor = db.cursor()
    cursor.execute('''CREATE TABLE IF NOT EXISTS leaderboard (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, score INTEGER NOT NULL, createtime DATETIME NOT NULL, ip TEXT NOT NULL)''')
    cursor.execute('''CREATE INDEX idx_name_score ON leaderboard (name, score DESC)''')
    db.commit()
    cursor.close()
    db.close()
    
if __name__ == '__main__':
    app.run(debug=True)
