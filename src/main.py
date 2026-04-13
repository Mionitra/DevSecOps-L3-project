from fastapi import FastAPI, Depends, HTTPException, Request
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session
from dotenv import load_dotenv
import os

import models, schemas, crud
from database import engine, get_db

load_dotenv()

models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=os.getenv("APP_NAME", "Mon API"),
    debug=os.getenv("DEBUG", "False").lower() == "true"
)

templates = Jinja2Templates(directory="templates")


@app.post("/items/", response_model=schemas.Item, status_code=201)
def create_item(item: schemas.ItemCreate, db: Session = Depends(get_db)):
    return crud.create_item(db=db, item=item)

@app.get("/items/", response_model=list[schemas.Item])
def read_items(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    items = crud.get_items(db, skip=skip, limit=limit)
    return items

@app.get("/items/{item_id}", response_model=schemas.Item)
def read_item(item_id: int, db: Session = Depends(get_db)):
    db_item = crud.get_item(db, item_id=item_id)
    if db_item is None:
        raise HTTPException(status_code=404, detail="Item non trouvé")
    return db_item

@app.put("/items/{item_id}", response_model=schemas.Item)
def update_item(item_id: int, item: schemas.ItemUpdate, db: Session = Depends(get_db)):
    db_item = crud.update_item(db, item_id=item_id, item_update=item)
    if db_item is None:
        raise HTTPException(status_code=404, detail="Item non trouvé")
    return db_item

@app.delete("/items/{item_id}", status_code=204)
def delete_item(item_id: int, db: Session = Depends(get_db)):
    db_item = crud.delete_item(db, item_id=item_id)
    if db_item is None:
        raise HTTPException(status_code=404, detail="Item non trouvé")
    return None

@app.get("/")
def root(request: Request, db: Session = Depends(get_db), page: int = 1):
    limit = 10
    skip = (page - 1) * limit
    items = crud.get_items(db, skip=skip, limit=limit)
    total_items = crud.count_items(db)
    total_pages = (total_items + limit - 1) // limit

    return templates.TemplateResponse(
        request=request,
        name="index.html",
        context={
            "app_name": os.getenv("APP_NAME", "Mon API FastAPI"),
            "title": os.getenv("APP_NAME", "Mon API FastAPI"),
            "items": items,
            "page": page,
            "total_pages": total_pages,
            "total_items": total_items
        }
    )