FROM node:14-alpine
WORKDIR /app
# Copy app file to image
COPY package.json ./
COPY package-lock.json ./
RUN npm install --silent
COPY . ./
EXPOSE 8080
CMD ["npm", "start"]
