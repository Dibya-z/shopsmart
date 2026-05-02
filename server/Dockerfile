# ─────────────────────────────────────────────
# Stage 1: Builder
# Install all dependencies (including devDependencies needed for Prisma CLI)
# ─────────────────────────────────────────────
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Generate Prisma client
RUN npx prisma generate

# ─────────────────────────────────────────────
# Stage 2: Production
# Copy only what is needed to run the app
# ─────────────────────────────────────────────
FROM node:18-alpine AS production

WORKDIR /app

# Create a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy dependencies and generated Prisma client from builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/src ./src
COPY --from=builder /app/prisma ./prisma

# Switch to non-root user
USER appuser

EXPOSE 5000

# Healthcheck: ping the /api/health endpoint every 30s
# Allow 40s for the container to start before checking
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget -qO- http://localhost:5000/api/health || exit 1

CMD ["node", "src/index.js"]