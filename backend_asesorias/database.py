from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from config import DATABASE_URL

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class Asesoria(Base):
    __tablename__ = "asesorias"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, nullable=False)
    correo = Column(String, nullable=False)
    telefono = Column(String, nullable=False)
    ciudad = Column(String, nullable=False)
    sexo = Column(String, nullable=False)
    estado_pago = Column(String, default="pendiente")
    fecha_horario = Column(String, nullable=True)

def init_db():
    Base.metadata.create_all(bind=engine)
