FROM node:22-alpine

LABEL org.opencontainers.image.title="cloud-orders"
LABEL org.opencontainers.image.description="Cloud Orders training service"

WORKDIR /app

COPY --chown=node:node package.json ./
COPY --chown=node:node app.js ./
COPY --chown=node:node app.test.js ./

ENV NODE_ENV=production
ENV PORT=8080
ENV APP_VERSION=1.0.0

EXPOSE 8080

USER node

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "fetch('http://localhost:8080/health').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"

CMD ["node", "app.js"]