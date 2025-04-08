FROM node:22.12-alpine AS builder

WORKDIR /app

COPY mcp/package.json mcp/package-lock.json ./
COPY mcp/src ./src
COPY mcp/tsconfig.json ./

RUN --mount=type=cache,target=/root/.npm npm install
RUN npm install -g typescript
RUN --mount=type=cache,target=/root/.npm-production npm ci --ignore-scripts --omit-dev
RUN npm run build

FROM node:22-alpine AS release

WORKDIR /app

COPY --from=builder /app/build /app/build
COPY --from=builder /app/package.json /app/package.json
COPY --from=builder /app/package-lock.json /app/package-lock.json

ENV NODE_ENV=production

RUN npm ci --ignore-scripts --omit-dev

ENTRYPOINT ["npx", "@modelcontextprotocol/inspector"]
CMD ["node", "/app/build/index.js"]
EXPOSE 6274
EXPOSE 6277