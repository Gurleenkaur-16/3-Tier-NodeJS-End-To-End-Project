# syntax=docker/dockerfile:1

############################
# Stage 1: Build client
############################
FROM node:20-alpine AS client-build

WORKDIR /usr/src/app/client

COPY client/package*.json ./
RUN npm install

COPY client/ ./
RUN npm run build

############################
# Stage 2: Install server deps
############################
FROM node:20-alpine AS server-deps

WORKDIR /usr/src/app/server

COPY server/package*.json ./
RUN npm install --omit=dev

############################
# Stage 3: Runtime
############################
FROM node:20-alpine AS runtime

ENV NODE_ENV=production

WORKDIR /usr/src/app/server

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=server-deps /usr/src/app/server/node_modules ./node_modules
COPY --chown=appuser:appgroup server/ ./

RUN mkdir -p ./public
COPY --from=client-build --chown=appuser:appgroup /usr/src/app/client/dist ./public

RUN chown -R appuser:appgroup /usr/src/app/server

USER appuser

EXPOSE 5000

CMD ["npm", "start"]
