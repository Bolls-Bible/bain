FROM node AS builder

WORKDIR /build

COPY . .

RUN npm install

RUN npm run build

FROM node AS runner

WORKDIR /build

COPY --from=builder /build/dist .
COPY --from=builder /build/public ./public/
COPY --from=builder /build/src/data ./src/data/
COPY --from=builder /build/package*.json ./

# Now install only production dependencies
RUN npm install --omit=dev

EXPOSE 3000

CMD ["npx", "pm2-runtime", "server.mjs"]
