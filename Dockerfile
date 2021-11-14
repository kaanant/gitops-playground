FROM python:3.9-slim-buster as builder

WORKDIR /build

COPY ./app/requirements.txt /build/requirements.txt

RUN pip install --user --no-cache-dir --upgrade -r /build/requirements.txt

ADD app app

FROM python:3.9-slim-buster as app

WORKDIR /code

RUN rm -rf /var/lib/apt/lists/*
RUN apt-get -y --purge autoremove && apt-get -y autoclean && apt-get -y clean

COPY --from=builder /build/app /code/app
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

RUN find /usr/local -depth \
  \( \
  \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
  -o \
  \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
  \) -exec rm -rf '{}' +;

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]

# If running behind a proxy like Nginx or Traefik add --proxy-headers
# CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80", "--proxy-headers"]