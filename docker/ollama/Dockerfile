FROM ollama/ollama

RUN echo "Building OLLAMA Docker image" && \
    COPY ./scripts/pull-llama3.2.sh /pull-llama3.2.sh  && \
    echo "✅ OLLAMA Docker pull image build started successfully"
RUN echo "Updating file permissions" && \
    chmod +x /pull-llama3.2.sh && \
    echo "✅ File permissions updated successfully"

ENTRYPOINT ["ollama", "serve"]



