# =====================================================
# Backend Dockerfile
# =====================================================
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine

WORKDIR /app

# Copy production node_modules from builder
COPY --from=builder /app/node_modules ./node_modules
# Copy source code
COPY . .

EXPOSE 3000

ENTRYPOINT ["sh", "docker-entrypoint.sh"]
