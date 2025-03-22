FROM ollama/ollama

COPY ./scripts/pull-llama3.2.sh /pull-llama3.2.sh
RUN chmod +x /pull-llama3.2.sh

ENTRYPOINT ["ollama", "serve"]



