from fastapi import FastAPI, Response, HTTPException, UploadFile, File, Request
from fastapi.middleware.cors import CORSMiddleware
import requests
import os
from langchain_community.document_loaders import (
    TextLoader,
    UnstructuredPDFLoader,
    Docx2txtLoader,
    UnstructuredMarkdownLoader,
    UnstructuredHTMLLoader,
    UnstructuredExcelLoader,
    UnstructuredPowerPointLoader,
    GoogleDriveLoader
)
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import Chroma
import tempfile
from google.oauth2.credentials import Credentials
from google.oauth2 import service_account
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request as GoogleRequest
from googleapiclient.discovery import build

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Initialize embeddings and vector store
embeddings = HuggingFaceEmbeddings(
    model_name="sentence-transformers/all-MiniLM-L6-v2")
vector_store = Chroma(
    persist_directory="./chroma_db",
    embedding_function=embeddings
)


def get_loader(file_path: str, file_type: str):
    """Get the appropriate loader based on file type"""
    loaders = {
        '.txt': TextLoader,
        '.pdf': UnstructuredPDFLoader,
        '.docx': Docx2txtLoader,
        '.md': UnstructuredMarkdownLoader,
        '.html': UnstructuredHTMLLoader,
        '.htm': UnstructuredHTMLLoader,
        '.xlsx': UnstructuredExcelLoader,
        '.xls': UnstructuredExcelLoader,
        '.pptx': UnstructuredPowerPointLoader,
        '.ppt': UnstructuredPowerPointLoader
    }

    ext = os.path.splitext(file_path)[1].lower()
    if ext not in loaders:
        raise ValueError(f"Unsupported file type: {ext}")

    return loaders[ext](file_path)


@app.get("/ping")
def home():
    try:
        # Basic response without any dependencies
        return {"status": "ok", "message": "Server is running"}
    except Exception as e:
        import traceback
        print(f"Error in /ping endpoint: {str(e)}")
        print(f"Traceback: {traceback.format_exc()}")
        raise HTTPException(
            status_code=500,
            detail=f"Internal server error: {str(e)}"
        )


@app.get("/ask")
def ask(prompt: str):
    try:
        res = requests.post(
            "http://host.docker.internal:11434/api/generate",
            json={
                "prompt": prompt,
                "stream": False,
                "model": "llama3.2:latest"
            },
            timeout=30  # Add timeout
        )
        res.raise_for_status()  # Raise exception for bad status codes
        return Response(content=res.text, media_type="application/json")
    except requests.exceptions.RequestException as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to connect to Ollama: {str(e)}")


@app.post("/upload")
async def upload_document(file: UploadFile = File(...)):
    try:
        # Create a temporary file to store the uploaded content
        with tempfile.NamedTemporaryFile(delete=False, suffix=file.filename) as temp_file:
            content = await file.read()
            temp_file.write(content)
            temp_file.flush()

            # Load and process the document
            loader = get_loader(temp_file.name, file.filename)
            documents = loader.load()

            # Split the documents
            text_splitter = RecursiveCharacterTextSplitter(
                chunk_size=1000,
                chunk_overlap=200
            )
            splits = text_splitter.split_documents(documents)

            # Add to vector store
            vector_store.add_documents(splits)
            vector_store.persist()

            # Clean up
            os.unlink(temp_file.name)

            return {"message": "Document processed and added to vector store"}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/documents")
def list_documents():
    """List all documents in the vector store"""
    try:
        # Get all documents from the vector store
        documents = vector_store.get()

        # Extract relevant information
        doc_info = []
        if documents and documents['documents']:
            for i, doc in enumerate(documents['documents']):
                doc_info.append({
                    "id": documents['ids'][i],
                    "content_preview": doc[:200] + "..." if len(doc) > 200 else doc,
                    "metadata": documents['metadatas'][i] if documents['metadatas'] else {}
                })

        return {
            "total_documents": len(doc_info),
            "documents": doc_info
        }
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error retrieving documents: {str(e)}")


def setup_google_drive_loader(folder_id):
    # You'll need to set up Google Drive credentials
    SCOPES = ['https://www.googleapis.com/auth/drive.readonly']
    credentials = service_account.Credentials.from_service_account_file(
        'path/to/credentials.json',
        scopes=SCOPES
    )

    loader = GoogleDriveLoader(
        folder_id=folder_id,
        credentials=credentials,
        recursive=True  # Include subfolders
    )
    return loader


def process_new_document(file_id):
    # Load the specific document
    SCOPES = ['https://www.googleapis.com/auth/drive.readonly']
    credentials = service_account.Credentials.from_service_account_file(
        'path/to/credentials.json',
        scopes=SCOPES
    )
    loader = GoogleDriveLoader(
        file_ids=[file_id],
        credentials=credentials
    )

    # Load and split the document
    documents = loader.load()
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=1000,
        chunk_overlap=200
    )
    splits = text_splitter.split_documents(documents)

    # Add to vector store
    vector_store.add_documents(splits)
    vector_store.persist()


@app.post("/webhook/google-drive")
async def google_drive_webhook(request: Request):
    try:
        data = await request.json()
        file_id = data.get('file_id')

        if file_id:
            process_new_document(file_id)
            return {"message": f"Document {file_id} processed successfully"}

        return {"message": "No file ID provided"}
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to process document: {str(e)}"
        )


def setup_watch_folder(folder_id, webhook_url):
    """Set up Google Drive Push Notifications for a folder"""
    SCOPES = ['https://www.googleapis.com/auth/drive.readonly']
    credentials = service_account.Credentials.from_service_account_file(
        'path/to/credentials.json',
        scopes=SCOPES
    )
    service = build('drive', 'v3', credentials=credentials)

    # Set up webhook channel
    channel = {
        'id': 'your-channel-id',
        'type': 'web_hook',
        'address': webhook_url,
    }

    # Start watching the folder
    service.files().watch(
        fileId=folder_id,
        body=channel
    ).execute()
