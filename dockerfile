FROM ubuntu:16.04

MAINTAINER Russell Murray & Maxime Lasserre

# Install Core Programs
RUN apt-get update && apt-get install -y tmux vim git rubygems vim-nox openssh-server python-pip nodejs npm && \
    gem install tmuxinator

# Pair User Setup
RUN mkdir -p /home/pair && \
    echo "pair:x:1000:1000:Pair,,,:/home/pair:/bin/bash" >> /etc/passwd &&\
    echo "pair:x:1000:" >> /etc/group && \
    chown pair:pair -R /home/pair && \
    chmod 777 /etc/ssh && \
    echo 'pair:reduce' | chpasswd 
    
# Setup Paths
ENV HOME /home/pair
WORKDIR /home/pair

# Powerline Install
RUN mkdir ~/.cache && \
    mkdir ~/.cache/pip && \
    pip install powerline-status && \
    vim +PluginInstall +qall

# Start SSH
RUN echo 'root:reduce' | chpasswd 
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN mkdir /var/run/sshd
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g'  /etc/ssh/sshd_config

# Get ready for and Switch User to "Pair"
RUN mkdir ~/.tmuxinator && \
    chown pair:pair -R ~/

RUN npm install npm -g

USER pair
ENV HOME /home/pair
WORKDIR /home/pair

# VIM SETUP AND PLUG-IN INSTALLS
RUN cd $HOME && \ 
    git clone https://github.com/spf13/spf13-vim.git && \
    ./spf13-vim/bootstrap.sh
RUN echo "Stuff2"
RUN cd $HOME && \
    git clone https://github.com/mousezero/PairZero.git .pairConfig &&\
    ./.pairConfig/install.sh
    
USER root
RUN ln /usr/bin/nodejs /usr/bin/node
USER pair
    
RUN cd /home/pair/workspace/demo && \
    npm init --yes && \
    npm install --save-dev babel-cli && \
    npm install babel-preset-es2015 --save-dev && \
    npm install --save-dev babel-polyfill && \
    mv /home/pair/.pairConfig/npm/babelrc ./.bablerc
    
USER root
RUN locale-gen en_US.UTF-8
RUN chown pair:pair /usr/bin/

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]