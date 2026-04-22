FROM python:3.13-alpine
RUN pip install --upgrade pip

RUN apk add --no-cache nano

# Install dependencies
RUN --mount=type=bind,source=requirements.txt,target=/requirements.txt \
    pip install --no-cache-dir -r /requirements.txt

# copy files
COPY porkbun_ddns.py /
COPY data /data

ENV domains_file=/data/domains.txt \
    interval=60 \
    log_level=INFO

# execute python script
CMD [ "python", "/porkbun_ddns.py" ]