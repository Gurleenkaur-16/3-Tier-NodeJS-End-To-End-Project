FROM node:20-alpine

# Build frontend
WORKDIR /usr/src/app/client
COPY client/package*.json ./
RUN npm install
COPY client/ ./
RUN npm run build

# Build backend
WORKDIR /usr/src/app/server
COPY server/package*.json ./
RUN npm install --omit=dev
COPY server/ ./

# Set runtime env only after build steps
ENV NODE_ENV=production

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy frontend build files into backend public directory
RUN mkdir -p ./public && cp -R /usr/src/app/client/dist/* ./public/

# Fix ownership
RUN chown -R appuser:appgroup /usr/src/app

USER appuser

EXPOSE 5000

CMD ["npm", "start"]
