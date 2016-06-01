FROM node:0.10

MAINTAINER Xin Wang <xwang@soton.ac.uk>

# Install git, nginx
RUN apt-get update && apt-get install -y \
    default-mta
    
# Clean up when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
# Create app directory
RUN mkdir -p /usr/src/app
ENV ROOT /usr/src/app

# Clone WO
WORKDIR $ROOT

# Copy wo build
COPY files/wo.tar.gz $ROOT
RUN tar -zxf wo.tar.gz
RUN rm wo.tar.gz

WORKDIR $ROOT/bundle/programs/server
RUN npm install
WORKDIR $ROOT

# Set up env
# ENV BIND_IP 127.0.0.1
# the port nginx is proxying requests to
ENV PORT 4000
# this allows Meteor to figure out correct IP address of visitors
ENV HTTP_FORWARDED_COUNT 1
# MongoDB connection string using todos as database name
ENV MONGO_URL mongodb://mongo:27017/wo
# The domain name as configured previously as server_name in nginx
ENV ROOT_URL https://localhost
# optional JSON config - the contents of file specified by passing "--settings" parameter to meteor command in development mode
# ENV METEOR_SETTINGS  '{"public": {"environment": "prod"}, "github": {"clientId": "", "secret": ""}, "facebook": {"appId": "", "secret": ""} }' 

# this is optional: http://docs.meteor.com/#email
ENV MAIL_URL smtp://localhost

# Copy nginx config
# COPY nginx/wo /etc/nginx/sites-available
# RUN ln -s /etc/nginx/sites-available/wo /etc/nginx/sites-enabled/wo
# RUN rm /etc/nginx/sites-enabled/default

# Copy ssl cert
# COPY nginx/wo.* /etc/nginx/ssl/

# Run nginx
EXPOSE 4000

# Start wo
COPY files/start.sh $ROOT/start.sh
CMD [ "sh", "/usr/src/app/start.sh" ]
