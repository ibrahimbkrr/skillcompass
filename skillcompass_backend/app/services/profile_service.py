from skillcompass_backend.app.database import db
from typing import Optional, Dict, Any
from google.cloud.firestore_v1.base_document import DocumentSnapshot
import logging
from skillcompass_backend.app.utils.firestore_paths import profile_data_collection, profile_card_doc

logger = logging.getLogger(__name__)

class ProfileService:
    @staticmethod
    def get_profile(user_id: str) -> Optional[Dict[str, Any]]:
        """Kullanıcının tüm profil kartlarını getirir."""
        try:
            profile_ref = profile_data_collection(db, user_id)
            docs = profile_ref.stream()
            profile = {doc.id: doc.to_dict() for doc in docs}
            if not profile:
                logger.info(f"Profile not found for user_id: {user_id}")
                return None
            return profile
        except Exception as e:
            logger.exception(f"Error retrieving profile for user_id: {user_id}")
            raise e

    @staticmethod
    def update_profile(user_id: str, profile_data: Dict[str, Any]) -> None:
        """Kullanıcının tüm profil kartlarını günceller."""
        profile_ref = profile_data_collection(db, user_id)
        try:
            for key, value in profile_data.items():
                profile_ref.document(key).set(value, merge=True)
            logger.info(f"Profile updated successfully for user_id: {user_id}")
        except Exception as e:
            logger.exception(f"Error updating profile for user_id: {user_id}")
            raise e

    # --- Kart Bazlı Metotlar ---
    @staticmethod
    def get_card(user_id: str, card_name: str) -> Optional[Dict[str, Any]]:
        """Belirli bir profil kartını getirir."""
        doc_ref = profile_card_doc(db, user_id, card_name)
        doc: DocumentSnapshot = doc_ref.get()
        return doc.to_dict() if doc.exists else None

    @staticmethod
    def save_card(user_id: str, card_name: str, data: Dict[str, Any]) -> None:
        """Belirli bir profil kartını kaydeder/günceller."""
        doc_ref = profile_card_doc(db, user_id, card_name)
        doc_ref.set(data)

    # Eski kart bazlı metotlar yerine yukarıdaki iki fonksiyon kullanılabilir.
    # Geriye dönük uyumluluk için eski metotlar da bırakılabilir, ancak yeni kodda yukarıdakiler tercih edilmeli.

    @staticmethod
    def get_identity_status(user_id: str) -> Optional[Dict[str, Any]]:
        doc_ref = db.collection('users').document(user_id).collection('profile_data').document('identity-status')
        doc: DocumentSnapshot = doc_ref.get()
        return doc.to_dict() if doc.exists else None

    @staticmethod
    def save_identity_status(user_id: str, data: Dict[str, Any]) -> None:
        doc_ref = db.collection('users').document(user_id).collection('profile_data').document('identity-status')
        doc_ref.set(data)

    @staticmethod
    def get_technical_profile(user_id: str) -> Optional[Dict[str, Any]]:
        doc_ref = db.collection('users').document(user_id).collection('profile_data').document('technical-profile')
        doc: DocumentSnapshot = doc_ref.get()
        return doc.to_dict() if doc.exists else None

    @staticmethod
    def save_technical_profile(user_id: str, data: Dict[str, Any]) -> None:
        doc_ref = db.collection('users').document(user_id).collection('profile_data').document('technical-profile')
        doc_ref.set(data)

    @staticmethod
    def get_learning_style(user_id: str) -> Optional[Dict[str, Any]]:
        doc_ref = db.collection('users').document(user_id).collection('profile_data').document('learning-style')
        doc: DocumentSnapshot = doc_ref.get()
        return doc.to_dict() if doc.exists else None

    @staticmethod
    def save_learning_style(user_id: str, data: Dict[str, Any]) -> None:
        doc_ref = db.collection('users').document(user_id).collection('profile_data').document('learning-style')
        doc_ref.set(data)

    @staticmethod
    def get_career_vision(user_id: str) -> Optional[Dict[str, Any]]:
        doc_ref = db.collection('users').document(user_id).collection('profile_data').document('career-vision')
        doc: DocumentSnapshot = doc_ref.get()
        return doc.to_dict() if doc.exists else None

    @staticmethod
    def save_career_vision(user_id: str, data: Dict[str, Any]) -> None:
        doc_ref = db.collection('users').document(user_id).collection('profile_data').document('career-vision')
        doc_ref.set(data)

    @staticmethod
    def get_project_experience(user_id: str) -> Optional[Dict[str, Any]]:
        doc_ref = db.collection('users').document(user_id).collection('profile_data').document('project-experience')
        doc: DocumentSnapshot = doc_ref.get()
        return doc.to_dict() if doc.exists else None

    @staticmethod
    def save_project_experience(user_id: str, data: Dict[str, Any]) -> None:
        doc_ref = db.collection('users').document(user_id).collection('profile_data').document('project-experience')
        doc_ref.set(data)

    @staticmethod
    def get_networking(user_id: str) -> Optional[Dict[str, Any]]:
        doc_ref = db.collection('users').document(user_id).collection('profile_data').document('networking')
        doc: DocumentSnapshot = doc_ref.get()
        return doc.to_dict() if doc.exists else None

    @staticmethod
    def save_networking(user_id: str, data: Dict[str, Any]) -> None:
        doc_ref = db.collection('users').document(user_id).collection('profile_data').document('networking')
        doc_ref.set(data)

    @staticmethod
    def get_personal_brand(user_id: str) -> Optional[Dict[str, Any]]:
        doc_ref = db.collection('users').document(user_id).collection('profile_data').document('personal-brand')
        doc: DocumentSnapshot = doc_ref.get()
        return doc.to_dict() if doc.exists else None

    @staticmethod
    def save_personal_brand(user_id: str, data: Dict[str, Any]) -> None:
        doc_ref = db.collection('users').document(user_id).collection('profile_data').document('personal-brand')
        doc_ref.set(data)
