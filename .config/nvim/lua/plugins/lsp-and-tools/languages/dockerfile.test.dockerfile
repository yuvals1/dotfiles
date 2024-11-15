# dockerfile.test
FROM ubuntu:latest

# Set environment variables
ENV APP_HOME=/app

# Create application directory
WORKDIR $APP_HOME

# Copy application files
COPY . .

# Install dependencies
RUN apt-get update && \
	apt-get install -y python3

# Command to run the application
CMD ["python3", "app.py"]
