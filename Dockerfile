# syntax=docker/dockerfile:1

############################
# Stage 1: Build frontend
############################
FROM node:20-alpine AS client-build

WORKDIR /app/client

# Install only from lockfile for reproducibility
COPY client/package*.json ./
RUN npm ci

# Copy source and build
COPY client/ ./
RUN npm run build

############################
# Stage 2: Install server deps
############################
FROM node:20-alpine AS server-deps

WORKDIR /app/server

COPY server/package*.json ./
RUN npm ci --omit=dev

############################
# Stage 3: Runtime
############################
FROM node:20-alpine AS runtime

ENV NODE_ENV=production

WORKDIR /app/server

# Create non-root user/group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy production node_modules first
COPY --from=server-deps /app/server/node_modules ./node_modules

# Copy server source
COPY server/ ./

# Copy built frontend into server public directory
COPY --from=client-build /app/client/dist ./public

# Fix ownership
RUN chown -R appuser:appgroup /app/server

# Run as non-root
USER appuser

EXPOSE 5000

# Optional healthcheck if /health exists
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget -qO- http://127.0.0.1:5000/health || exit 1

CMD ["npm", "start"]
