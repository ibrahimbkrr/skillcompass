"""
Firestore yol yardımcıları
"""
def user_doc_ref(db, user_id: str):
    return db.collection('users').document(user_id)

def profile_data_collection(db, user_id: str):
    return user_doc_ref(db, user_id).collection('profile_data')

def profile_card_doc(db, user_id: str, card_name: str):
    return profile_data_collection(db, user_id).document(card_name) 