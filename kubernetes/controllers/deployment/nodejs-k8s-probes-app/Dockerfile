FROM node:14

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY . .

COPY health-check.sh /usr/src/app/
COPY ready-check.sh /usr/src/app/
RUN chmod +x /usr/src/app/health-check.sh /usr/src/app/ready-check.sh

EXPOSE 80
CMD ["node", "app.js"]
