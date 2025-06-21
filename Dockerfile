# This tells Docker how to package your app

FROM node:18-alpine

RUN apk update && apk upgrade && \
    apk add --no-cache some-package-if-needed

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3001

CMD ["npm", "start"]