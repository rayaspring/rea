FROM node:22-bookworm AS deps
WORKDIR /app
COPY package*.json ./
COPY scripts ./scripts
RUN npm ci

FROM node:22-bookworm AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run compile

FROM node:22-bookworm-slim AS runtime
ENV NODE_ENV=production
WORKDIR /app
COPY --from=build /app/package*.json ./
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/scripts ./scripts
USER node
EXPOSE 8787
HEALTHCHECK --interval=30s --timeout=5s --start-period=45s --retries=3 CMD node -e "process.exit(0)"
CMD ["npm","run","start"]
