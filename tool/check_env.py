import sys
print('PY', sys.version.split()[0])
for mod in ('PIL','PIL.Image','numpy'):
    try:
        __import__(mod)
        print('OK', mod)
    except Exception as exc:
        print('MISSING', mod, exc)
