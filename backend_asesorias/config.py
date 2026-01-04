import os

# Ruta absoluta a tu base de datos global
BASE_DIR = "/Users/carlitosyepes/Carlitostravel/base_datos"
DB_NAME = "carlitostravel.db"

DATABASE_URL = f"sqlite:///{os.path.join(BASE_DIR, DB_NAME)}"
