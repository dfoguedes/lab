FROM node:18-alpine

WORKDIR /frontend-serverless/

COPY public/ /frontend-serverless/public
COPY src/ /frontend-serverless/src
COPY package.json /frontend-serverless/

EXPOSE 3000 

RUN npm install

CMD ["npm","start"]