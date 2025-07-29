FROM python:3.13
RUN pip install --upgrade pip

RUN apt update \
    && apt install -y nano \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

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