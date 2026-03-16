# syntax=docker/dockerfile:1

FROM node:20-alpine AS client-build
WORKDIR /app/client
COPY client/package*.json ./
RUN npm ci
COPY client/ ./
RUN npm run build

FROM node:20-alpine AS server-deps
WORKDIR /app/server
COPY server/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

FROM node:20-alpine AS runtime
ENV NODE_ENV=production
WORKDIR /app/server

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=server-deps /app/server/node_modules ./node_modules
COPY --chown=appuser:appgroup server/ ./
COPY --from=client-build --chown=appuser:appgroup /app/client/dist ./public

USER appuser

EXPOSE 5000

CMD ["npm", "start"]
