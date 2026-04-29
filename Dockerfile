FROM node:20-alpine

WORKDIR /app

COPY server/package*.json ./

COPY server/ ./

RUN npm install

EXPOSE 5000

CMD npm start

