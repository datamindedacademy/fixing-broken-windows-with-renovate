FROM python:3.10.0-slim

# renovate: datasource=pypi depName=uv
ARG UV_VERSION=0.1.0
RUN pip install uv==${UV_VERSION}

WORKDIR /app
COPY backend/ ./backend/

RUN cd backend && uv sync

FROM node:18.0.0-alpine AS frontend

WORKDIR /app
COPY frontend/ ./frontend/

RUN cd frontend && npm install
