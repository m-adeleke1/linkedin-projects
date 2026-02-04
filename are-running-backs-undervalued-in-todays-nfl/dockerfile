# Use the official Jupyter Notebook image as the base image
FROM jupyter/base-notebook:latest

# Set the working directory in the container
WORKDIR /home/jovyan/work

# Copy the notebook file into the container
COPY notebook.ipynb requirements.txt /home/jovyan/work/

# Change the permissions of the notebook file to allow Jupyter to access it
USER root
RUN chown jovyan:users /home/jovyan/work/notebook.ipynb
USER jovyan
