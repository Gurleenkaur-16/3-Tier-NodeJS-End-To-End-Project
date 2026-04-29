FROM node:20-apline

WORKDIR /app

COPY server/package.json package-lock.json ./

COPY . .

RUN npm install

EXPOSE 5000

CMD ["node" , "server.js"]

