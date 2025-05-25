from skillcompass_backend.app.database import db
from typing import Optional, Dict, Any
from google.cloud.firestore_v1.base_document import DocumentSnapshot
import logging
from google.cloud.exceptions import NotFound, GoogleCloudError
from skillcompass_backend.app.utils.firestore_paths import user_doc_ref

logger = logging.getLogger(__name__)

class UserService:
    @staticmethod
    def get_user_by_id(user_id: str) -> Optional[Dict[str, Any]]:
        """Kullanıcıyı user_id ile getirir."""
        try:
            doc_ref = user_doc_ref(db, user_id)
            doc: DocumentSnapshot = doc_ref.get()
            if doc.exists:
                logger.info(f"User {user_id} retrieved successfully.")
                return doc.to_dict()
            logger.info(f"User {user_id} does not exist.")
            return None
        except GoogleCloudError as e:
            logger.exception(f"Firestore error while retrieving user {user_id}.")
            raise e

    @staticmethod
    def create_user(user_id: str, user_data: Dict[str, Any]) -> None:
        """Yeni kullanıcı oluşturur."""
        try:
            user_doc_ref(db, user_id).set(user_data)
            logger.info(f"User {user_id} created successfully.")
        except GoogleCloudError as e:
            logger.exception(f"Firestore error while creating user {user_id}.")
            raise e

    @staticmethod
    def update_user(user_id: str, user_data: Dict[str, Any]) -> None:
        """Kullanıcıyı günceller."""
        try:
            user_ref = user_doc_ref(db, user_id)
            user_ref.update(user_data)
            logger.info(f"User {user_id} updated successfully.")
        except NotFound:
            logger.warning(f"Attempted to update non-existent user {user_id}.")
            raise ValueError("User not found.")
        except GoogleCloudError as e:
            logger.exception(f"Firestore error while updating user {user_id}.")
            raise e

    @staticmethod
    def delete_user(user_id: str) -> None:
        """Kullanıcıyı siler."""
        try:
            user_ref = user_doc_ref(db, user_id)
            user_ref.delete()
            logger.info(f"User {user_id} deleted successfully.")
        except GoogleCloudError as e:
            logger.exception(f"Firestore error while deleting user {user_id}.")
            raise e
