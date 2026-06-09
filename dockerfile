# Stage 1: Build the application
FROM node:20-alpine AS builder

RUN apk add --no-cache python3 make g++ build-base
WORKDIR /app

COPY package*.json ./
COPY tsconfig.json ./
RUN npm install

COPY index.ts .
RUN npm run build

# Stage 2: Run the application
FROM node:20-alpine AS runner
WORKDIR /app

COPY package*.json ./
# Only install production dependencies (skips typescript/types)
RUN npm install --only=production 

# Copy compiled JavaScript code from the builder stage
COPY --from=builder /app/dist ./dist

CMD ["npm", "start"]
