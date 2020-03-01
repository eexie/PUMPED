# app.py
# Required Imports
import os
import pandas as pd
# from flask import Flask, request, jsonify
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

def getDataFromDay(date):
    docs = db.collection_group(date).stream()
    docData = {}
    for doc in docs:
        docData[doc.id] = doc.to_dict()
    return docData

def getAllData():
    collections = user_doc_ref.collections()

    for collection in collections:
        print(u'COLLECTION {}'.format(collection.id))
        docs = collection.stream()
        for doc in docs:
            print(u'{} => {}'.format(doc.id, doc.to_dict()))

def writeAnomalyToSession(session, anomaly_updates):
    sessionDoc = db.document(session)
    print("updating anomalies")
    sessionDoc.update(anomaly_updates)

date = '2-4-2020'
sessionDict = getDataFromDay(date)
print(sessionDict)
df = pd.DataFrame.from_dict(sessionDict)
print(df)

anomaly_updates = {
    'anomaly': ['low production', "low production, long letdown"]
}
writeAnomalyToSession(user_doc_id + '/2-4-2020/19-44', anomaly_updates)