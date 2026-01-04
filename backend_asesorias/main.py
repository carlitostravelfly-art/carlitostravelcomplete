from fastapi import FastAPI
from pydantic import BaseModel, EmailStr
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from google.oauth2 import service_account
from googleapiclient.discovery import build
from datetime import datetime, timedelta
import os
import smtplib
from email.mime.text import MIMEText
import traceback

# ==========================================================
# CONFIGURACIÓN BASE DE DATOS
# ==========================================================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATABASE_URL = f"sqlite:///{os.path.join(BASE_DIR, '../base_datos/carlitostravel.db')}"

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()


# ==========================================================
# MODELO DE LA TABLA ASESORIAS
# ==========================================================
class Asesoria(Base):
    __tablename__ = "asesorias"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, nullable=False)
    correo = Column(String, nullable=False)
    telefono = Column(String, nullable=False)
    pais = Column(String, nullable=False)
    ciudad = Column(String, nullable=False)
    sexo = Column(String, nullable=False)
    estado_pago = Column(String, default="pendiente")
    fecha_horario = Column(String, nullable=True)
    fecha_pago = Column(DateTime, default=datetime.utcnow)


def init_db():
    Base.metadata.create_all(bind=engine)


# ==========================================================
# CONFIGURACIÓN APP FASTAPI
# ==========================================================
app = FastAPI(title="Backend CarlitosTravel - Asesorías con Correo SMTP + Calendar")
init_db()


# ==========================================================
# MODELOS Pydantic
# ==========================================================
class AsesoriaCreate(BaseModel):
    nombre: str
    correo: EmailStr
    telefono: str
    pais: str
    ciudad: str
    sexo: str


class ConfirmarAsesoria(BaseModel):
    id: int
    fecha_horario: str


# ==========================================================
# GOOGLE CALENDAR CONFIG
# ==========================================================
SERVICE_ACCOUNT_FILE = os.path.join(BASE_DIR, "service_account.json")


def get_calendar_service():
    SCOPES = ['https://www.googleapis.com/auth/calendar']
    if not os.path.exists(SERVICE_ACCOUNT_FILE):
        raise FileNotFoundError(f"No se encontró el archivo de credenciales en: {SERVICE_ACCOUNT_FILE}")

    credentials = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE, scopes=SCOPES
    )
    return build('calendar', 'v3', credentials=credentials)


# ==========================================================
# FUNCIÓN PARA ENVIAR CORREOS USANDO SMTP GMAIL
# ==========================================================
def enviar_correo(destinatario, asunto, cuerpo, bcc=None):
    try:
        remitente = "carlitostravelfly@gmail.com"
        password = "dylknscmhlyxtcou"  # 🔑 Contraseña de aplicación Gmail

        msg = MIMEText(cuerpo, "plain", "utf-8")
        msg["Subject"] = asunto
        msg["From"] = remitente
        msg["To"] = destinatario

        to_list = [destinatario]
        if bcc:
            to_list.append(bcc)

        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
            server.login(remitente, password)
            server.sendmail(remitente, to_list, msg.as_string())

        print(f"📨 Correo enviado correctamente a {destinatario}")
    except Exception as e:
        print("❌ Error al enviar correo:", e)


# ==========================================================
# ENDPOINTS API
# ==========================================================
@app.get("/")
def home():
    return {"mensaje": "✅ Backend activo con Calendar + SMTP Gmail + SQLite"}


# 🔹 Crear registro inicial
@app.post("/api/asesoria")
def crear_asesoria(asesoria: AsesoriaCreate):
    db = SessionLocal()
    try:
        nueva = Asesoria(
            nombre=asesoria.nombre,
            correo=asesoria.correo,
            telefono=asesoria.telefono,
            pais=asesoria.pais,
            ciudad=asesoria.ciudad,
            sexo=asesoria.sexo,
            estado_pago="pendiente",
            fecha_pago=datetime.utcnow()
        )
        db.add(nueva)
        db.commit()
        db.refresh(nueva)
        print(f"🆕 Nueva asesoría registrada: {asesoria.nombre} ({asesoria.pais}, {asesoria.ciudad})")
        return {"mensaje": "Asesoría registrada exitosamente", "id": nueva.id}
    except Exception as e:
        traceback.print_exc()
        return {"error": str(e)}
    finally:
        db.close()


# 🔹 Confirmar asesoría, crear evento y enviar correos
@app.put("/api/asesoria/confirmar")
def confirmar_asesoria(data: ConfirmarAsesoria):
    db = SessionLocal()
    try:
        asesoria = db.query(Asesoria).filter(Asesoria.id == data.id).first()
        if not asesoria:
            return {"error": "Asesoría no encontrada"}

        asesoria.fecha_horario = data.fecha_horario
        asesoria.estado_pago = "aprobado"
        db.commit()
        db.refresh(asesoria)

        service = get_calendar_service()
        start_time = datetime.strptime(data.fecha_horario, "%Y-%m-%d %H:%M")
        end_time = start_time + timedelta(minutes=45)

        event = {
            'summary': f'Asesoría con {asesoria.nombre}',
            'description': (
                f"Asesoría personalizada de viajes con {asesoria.nombre}\n"
                f"🌎 País: {asesoria.pais}\n"
                f"🏙️ Ciudad: {asesoria.ciudad}\n"
                f"📞 Teléfono: {asesoria.telefono}\n"
                f"📧 Correo: {asesoria.correo}\n"
                f"🕒 Fecha y hora: {asesoria.fecha_horario}"
            ),
            'start': {'dateTime': start_time.isoformat(), 'timeZone': 'America/Bogota'},
            'end': {'dateTime': end_time.isoformat(), 'timeZone': 'America/Bogota'},
            'reminders': {'useDefault': True},
        }

        event_result = service.events().insert(
            calendarId='carlitostravelfly@gmail.com',
            body=event,
            sendUpdates='all'
        ).execute()

        calendar_link = event_result.get("htmlLink", "")

        cuerpo_cliente = f"""Hola {asesoria.nombre},

Tu asesoría personalizada ha sido confirmada ✅

📅 Fecha y hora: {asesoria.fecha_horario}
🌎 País: {asesoria.pais}
🏙️ Ciudad: {asesoria.ciudad}
📞 Teléfono: {asesoria.telefono}

Puedes añadir la cita a tu calendario con este enlace:
{calendar_link}

¡Te esperamos con gusto!
— El equipo de Carlitos Travel ✈️
"""

        cuerpo_admin = f"""Nueva asesoría confirmada:

👤 Cliente: {asesoria.nombre}
📧 Correo: {asesoria.correo}
📞 Teléfono: {asesoria.telefono}
🌎 País: {asesoria.pais}
🏙️ Ciudad: {asesoria.ciudad}
🕒 Hora programada: {asesoria.fecha_horario}
💰 Pago registrado: {asesoria.fecha_pago.strftime('%Y-%m-%d %H:%M:%S')}

Evento Calendar:
{calendar_link}
"""

        enviar_correo(asesoria.correo, "Confirmación de tu asesoría ✈️", cuerpo_cliente, bcc="carlitostravelfly@gmail.com")
        enviar_correo("carlitostravelfly@gmail.com", "📢 Nueva asesoría confirmada", cuerpo_admin)

        return {
            "mensaje": "✅ Asesoría confirmada, evento creado y correos enviados",
            "evento_link": calendar_link,
        }

    except Exception as e:
        traceback.print_exc()
        return {"error": f"Error al confirmar asesoría: {e}"}
    finally:
        db.close()


# ==========================================================
# 🔹 Endpoint: obtener horarios ocupados del calendario
# ==========================================================
@app.get("/api/horarios-ocupados")
def horarios_ocupados():
    """
    Devuelve las franjas horarias ya ocupadas en Google Calendar
    para evitar que se dupliquen asesorías en el mismo horario.
    """
    try:
        service = get_calendar_service()
        now = datetime.utcnow().isoformat() + 'Z'
        future = (datetime.utcnow() + timedelta(days=7)).isoformat() + 'Z'

        events_result = service.events().list(
            calendarId='carlitostravelfly@gmail.com',
            timeMin=now,
            timeMax=future,
            maxResults=50,
            singleEvents=True,
            orderBy='startTime'
        ).execute()

        events = events_result.get('items', [])
        ocupados = []

        for e in events:
            if 'start' in e:
                inicio = e['start'].get('dateTime', e['start'].get('date'))
                if inicio:
                    dt = datetime.fromisoformat(inicio.replace("Z", "+00:00"))
                    ocupados.append(dt.strftime("%Y-%m-%d %H:%M"))

        print(f"📅 {len(ocupados)} horarios ocupados detectados")
        return {"ocupados": ocupados}

    except Exception as e:
        traceback.print_exc()
        return {"error": str(e)}
