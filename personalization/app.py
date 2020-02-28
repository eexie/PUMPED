# app.py
# Required Imports
import os
import pandas as pd
from flask import Flask, request, jsonify
from firebase_admin import credentials, firestore, initialize_app
# Initialize Flask App
# app = Flask(__name__)
# Initialize Firestore DB
cred = credentials.Certificate('key.json')
default_app = initialize_app(cred)
db = firestore.client()

# Create a reference to the cities collection
user_doc_id = 'users/emily'
user_doc_ref = db.document(user_doc_id)

def getSessionsFromDay(date):
    docs = db.collection_group(date).stream()
    for doc in docs:
        print(u'{} => {}'.format(doc.id, doc.to_dict()))

def getAllData():
    collections = user_doc_ref.collections()

    for collection in collections:
        print(u'COLLECTION {}'.format(collection.id))
        docs = collection.stream()
        for doc in docs:
            print(u'{} => {}'.format(doc.id, doc.to_dict()))

def writeAnomaly(anomaly_updates):
    anomalyDoc = db.document('users/emily/personalization/anomalies')
    print("updating anomalies")
    anomalyDoc.set(anomaly_updates, merge=True)

# try:
#     doc = user_doc_ref.get()
#     print(u'Document data: {}'.format(doc.to_dict()))
# except google.cloud.exceptions.NotFound:
#     print(u'No such document!')

# date = '2-5-2020'
# # print(getSessionsFromDay(date))
anomaly_updates = {
    'anomaly': ['low production', "low production, long letdown"]
}
writeAnomaly(anomaly_updates)

# @app.route('/add', methods=['POST'])
# def create():
#     """
#         create() : Add document to Firestore collection with request body
#         Ensure you pass a custom ID as part of json body in post request
#         e.g. json={'id': '1', 'title': 'Write a blog post'}
#     """
#     try:
#         id = request.json['id']
#         todo_ref.document(id).set(request.json)
#         return jsonify({"success": True}), 200
#     except Exception as e:
#         return f"An Error Occured: {e}"
# @app.route('/list', methods=['GET'])
# def read():
#     """
#         read() : Fetches documents from Firestore collection as JSON
#         todo : Return document that matches query ID
#         all_todos : Return all documents
#     """
#     try:
#         # Check if ID was passed to URL query
#         todo_id = request.args.get('id')    
#         if todo_id:
#             todo = todo_ref.document(todo_id).get()
#             return jsonify(todo.to_dict()), 200
#         else:
#             all_todos = [doc.to_dict() for doc in todo_ref.stream()]
#             return jsonify(all_todos), 200
#     except Exception as e:
#         return f"An Error Occured: {e}"
# @app.route('/update', methods=['POST', 'PUT'])
# def update():
#     """
#         update() : Update document in Firestore collection with request body
#         Ensure you pass a custom ID as part of json body in post request
#         e.g. json={'id': '1', 'title': 'Write a blog post today'}
#     """
#     try:
#         id = request.json['id']
#         todo_ref.document(id).update(request.json)
#         return jsonify({"success": True}), 200
#     except Exception as e:
#         return f"An Error Occured: {e}"
# @app.route('/delete', methods=['GET', 'DELETE'])
# def delete():
#     """
#         delete() : Delete a document from Firestore collection
#     """
#     try:
#         # Check for ID in URL query
#         todo_id = request.args.get('id')
#         todo_ref.document(todo_id).delete()
#         return jsonify({"success": True}), 200
#     except Exception as e:
#         return f"An Error Occured: {e}"
# port = int(os.environ.get('PORT', 8080))
# if __name__ == '__main__':
#     app.run(threaded=True, host='0.0.0.0', port=port)