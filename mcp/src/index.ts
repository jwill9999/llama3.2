import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import fs from 'fs';
import path from 'path';
import { parse } from 'csv-parse/sync';

// Path to your CSV file - update this with your actual path
const csvFilePath = path.resolve('I:/Users/Mirasi/Downloads/mcp/datasets/avgIncome.csv');

// Initialize server with resource capabilities
const server = new Server(
  {
    name: "ons-ai",
    version: "1.0.0",
  },
  {
    capabilities: {
      resources: {}, // Enable resources
    },
  }
);

// List available resources when clients request them
server.setRequestHandler(ListResourcesRequestSchema, async () => {
  return {
    resources: [
      {
        uri: "hello://world",
        name: "Hello World Message",
        description: "A simple greeting message",
        mimeType: "text/plain",
      }
    ],
  };
});

// Return resource content when clients request it
server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
  if (request.params.uri === "hello://world") {
    let avgIncomeData = parse(fs.readFileSync(csvFilePath));
    return {
      contents: [
        {
          uri: "hello://world",
          text: JSON.stringify(avgIncomeData)
        },
      ],
    };
  }
  throw new Error("Resource not found");
});

// Start server using stdio transport
const transport = new StdioServerTransport();
await server.connect(transport);
console.info('{"jsonrpc": "2.0", "method": "log", "params": { "message": "Server running..." }}');