# Start with a base Python 3.7.2 image
FROM python:3.7.2

# Add the external tasks directory into /tasks
COPY requirements.txt requirements.txt

COPY run.sh /

# Install the required dependencies via pip
RUN pip install -r requirements.txt

# Expose the required Locust ports
EXPOSE 5557 5558 8089

# Set script to be executable
RUN chmod 755 /run.sh

# Start Locust using LOCUS_OPTS environment variable
ENTRYPOINT ["/run.sh"] 