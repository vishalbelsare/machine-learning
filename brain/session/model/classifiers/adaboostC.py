import sys
sys.path.insert(0, 'brain/session/model')
from adaboostgen import adaboostgen

def adaboostCgenerate(
                model,
                collection,
                payload,
                list_error,
                learning=1.0,
                loss='linear',
                estimators=50):
    return adaboostgen(model,
                  False,
                  collection,
                  payload,
                  list_error,
                  learning=learning,
                  loss=loss,
                  be=None,
                  k=estimators)
