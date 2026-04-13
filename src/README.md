# DevOps Exam - FastAPI Items API

Ce projet est une API simple développée avec **FastAPI** pour la gestion d'items. Il utilise **SQLAlchemy** comme ORM et **SQLite** comme base de données.

## Fonctionnalités

- **CRUD complet** pour les Items (`/items/`).
- Documentation interactive via Swagger UI (`/docs`).
- Gestion des variables d'environnement avec `.env`.
- Base de données locale SQLite.

## Stack Technique

- **Framework:** FastAPI
- **ORM:** SQLAlchemy
- **Base de données:** SQLite
- **Validation:** Pydantic
- **Gestion d'environnement:** Python-dotenv

## Lancement

Pour lancer l'application en mode développement :

```bash
uvicorn main:app --reload
```

## Structure du Projet

- `main.py` : Point d'entrée de l'application et définition des routes.
- `models.py` : Modèles de données SQLAlchemy.
- `schemas.py` : Schémas Pydantic pour la validation.
- `database.py` : Configuration de la connexion à la base de données.
- `crud.py` : Opérations Create, Read, Update, Delete.
- `.env` : Variables d'environnement (config, secrets).
- `.gitignore` : Fichiers et dossiers à ignorer par Git.
