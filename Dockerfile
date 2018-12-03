FROM debian
SHELL ["/bin/bash", "-c"]
ENV REDMINE_VERSION="3.4.6"
ENV REDMINE_LANGUAGE="cs"

# Install necessary
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y curl imagemagick libmagickwand-dev nginx procps sudo

# Copy nginx configuration and Redmine service script
ADD config/default /etc/nginx/sites-available/
ADD config/redmine /etc/init.d/

# Download and install RVM
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby

# Create user 'redmine'
RUN adduser --disabled-login --gecos "" redmine && adduser redmine rvm
USER redmine

# Download and extract Redmine, copy configuration files
WORKDIR /home/redmine
RUN curl http://www.redmine.org/releases/redmine-$REDMINE_VERSION.tar.gz > redmine-$REDMINE_VERSION.tar.gz && \
  tar xvfz redmine-$REDMINE_VERSION.tar.gz
ADD config/puma.rb /home/redmine/redmine-$REDMINE_VERSION/config/
ADD config/database.yml /home/redmine/redmine-$REDMINE_VERSION/config/

# Install Redmine and fixtures
RUN source /usr/local/rvm/scripts/rvm && \
  cd redmine-$REDMINE_VERSION && \
  mkdir tmp/pids && \
  echo "gem: --no-ri --no-rdoc" >> ~/.gemrc && \
  echo -e "# Gemfile.local\ngem 'puma'" >> Gemfile.local && \
  bundle install --without development test && \
  rake generate_secret_token && \
  RAILS_ENV=production rake db:migrate && \
  echo $REDMINE_LANGUAGE | RAILS_ENV=production rake redmine:load_default_data

USER root

# Test if everything works without puma
# RUN ruby bin/rails server webrick -e production

ADD config/entrypoint.sh /opt/
ENTRYPOINT /opt/entrypoint.sh
