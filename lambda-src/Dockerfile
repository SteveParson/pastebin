FROM node:14
WORKDIR /app
RUN apt-get update && apt-get install -y zip
COPY . .
RUN npm install
RUN zip -r lambda.zip .