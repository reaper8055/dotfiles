# Use an official Ubuntu base image
FROM ubuntu:24.10

ENV USER=devuser
ENV HOME=/home/$USER

# Create user Downloads,dotfiles dir
RUN mkdir -p $HOME/Downloads

# Install pkgs
COPY dev-setup.sh $HOME/Downloads/
RUN chmod +x $HOME/Downloads/dev-setup.sh
RUN $HOME/Downloads/dev-setup.sh

# Set up a user
RUN useradd -ms /usr/bin/zsh $USER
RUN usermod -aG sudo $USER

# Set up working dir
WORKDIR $HOME/Projects
RUN chown -R $USER:$USER $HOME

# Allow the user to use sudo without a password
RUN echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Change to the new user for interactive shell
USER $USER

# Default command to run
CMD ["zsh"]
