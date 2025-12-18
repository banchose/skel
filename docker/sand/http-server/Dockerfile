# syntax=docker/dockerfile:1

# Build stage - compile/build your application
FROM node:18 AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
# Outputs to /app/dist (or your build output directory)

# HTTP server stage - serve the built files
FROM node:16-alpine AS production
VOLUME /public
WORKDIR /srv/http-server

# Copy http-server dependencies
COPY package.json package-lock.json ./
RUN npm install --production

# Copy the http-server code
COPY ./bin ./bin

# Copy the built static files from the build stage
COPY --from=build /app/dist ./public

EXPOSE 8080
ENTRYPOINT ["node", "./bin/http-server"]
