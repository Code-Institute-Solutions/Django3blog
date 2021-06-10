FROM gitpod/workspace-full

USER root
# Setup Heroku CLI
RUN curl https://cli-assets.heroku.com/install.sh | sh

# Setup MongoDB and MySQL
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 20691eec35216c63caf66ce1656408e390cfb1f5 && \
    echo "deb http://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list  && \
    apt-get update -y  && \
    touch /etc/init.d/mongod  && \
    apt-get -y install mongodb-org-shell -y  && \
    apt-get -y install links  && \
    apt-get install -y mysql-server && \
    apt-get clean && rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/* && \
    mkdir /var/run/mysqld && \
    chown -R gitpod:gitpod /etc/mysql /var/run/mysqld /var/log/mysql /var/lib/mysql /var/lib/mysql-files /var/lib/mysql-keyring /var/lib/mysql-upgrade /home/gitpod/.cache/heroku/ && \
    pip3 install flake8 flake8-flask flake8-django

# Create our own config files

COPY .vscode/mysql.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

COPY .vscode/client.cnf /etc/mysql/mysql.conf.d/client.cnf

COPY .vscode/start_mysql.sh /etc/mysql/mysql-bashrc-launch.sh

USER gitpod

# Start MySQL when we log in

RUN echo ". /etc/mysql/mysql-bashrc-launch.sh" >> ~/.bashrc
RUN echo 'alias run="python3 $GITPOD_REPO_ROOT/manage.py runserver 0.0.0.0:8000"' >> ~/.bashrc
RUN echo 'alias heroku_config=". $GITPOD_REPO_ROOT/.vscode/heroku_config.sh"' >> ~/.bashrc
RUN echo 'alias python=python3' >> ~/.bashrc
RUN echo 'alias pip=pip3' >> ~/.bashrc
RUN echo 'python3 $GITPOD_REPO_ROOT/.vscode/font_fix.py' >> ~/.bashrc

# Local environment variables
# C9USER is temporary to allow the MySQL Gist to run
ENV C9_USER="gitpod"
ENV PORT="8080"
ENV IP="0.0.0.0"
ENV C9_HOSTNAME="localhost"

USER root
# Switch back to root to allow IDE to load
