from typing import List
from fastapi import FastAPI
from f_train.f_train import router as f_train_router, f_train_manhattan_next
from g_train.g_train import router as g_train_router, g_train_next_queens
from train_types import DirectionalTrainArrival

app = FastAPI()

# Add routers
app.include_router(f_train_router)
app.include_router(g_train_router)

@app.get("/")
def root():
    return {"message": "Trains API Service"}

@app.get("/fg-northbound-next", response_model=List[DirectionalTrainArrival])
def fg_trains_northbound_next():
    f_trains = f_train_manhattan_next()
    g_trains = g_train_next_queens()
    all_trains = f_trains + g_trains
    
    # Sort by arrival time (using status string which is in format "X mins")
    sorted_trains = sorted(all_trains, key=lambda x: int(x.status.split()[0]))
    
    return sorted_trains[:2] 