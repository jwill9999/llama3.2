# Use the official Ollama image
FROM ollama/ollama

# Copy your start script directly
COPY docker/ollama/start.sh /start.sh

# Make the script executable
RUN chmod +x /start.sh

# Override the ENTRYPOINT from the parent image
ENTRYPOINT []

# Set the command to run your script
CMD ["/start.sh"]





