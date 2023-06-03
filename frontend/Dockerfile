# Use the official Node.js image as the base image
FROM node:14 as build-stage

# Set the working directory in the container
WORKDIR /app

# Copy the package.json and package-lock.json files to the container
COPY package*.json ./

# Install the dependencies
RUN npm install

# Copy the source code to the container
COPY . .

# Build the React app
RUN npm run build

# Use the official Nginx image as the base image for the production stage
FROM nginx:1.21

# Copy the built React app from the build-stage container to the Nginx container
COPY --from=build-stage /app/build /usr/share/nginx/html

# Copy the Nginx configuration template file to the Nginx container
COPY ./nginx/nginx.conf.template /etc/nginx/conf.d/default.conf.template

# Copy the entrypoint script to the Nginx container
COPY ./nginx/docker-entrypoint.sh /docker-entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /docker-entrypoint.sh

# Expose port 80 to the outside world
EXPOSE 80

# Start Nginx using the entrypoint script
CMD ["/docker-entrypoint.sh"]
