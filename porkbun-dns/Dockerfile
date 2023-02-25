FROM python:3.8
RUN pip install --upgrade pip

RUN apt update
RUN apt install nano -y

# Install dependencies
COPY requirements.txt /
RUN pip install --no-cache-dir -r requirements.txt

# copy files
COPY porkbun_ddns.py /
ADD data /data

ENV domains_file=/data/domains.txt
ENV interval=60
ENV log_level=INFO

# execute python script
CMD [ "python", "/porkbun_ddns.py" ]