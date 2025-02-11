FROM node AS builder

WORKDIR /app

COPY . .

RUN npm install

RUN npm run build

FROM node AS runner

WORKDIR /app

COPY --from=builder /app/dist .
COPY --from=builder /app/package*.json ./

# Now install only production dependencies
RUN npm install --omit=dev

EXPOSE 3000

CMD ["npx", "pm2-runtime", "server.mjs"]
