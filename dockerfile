# Stage 1: Build the application
FROM node:20-alpine AS builder

# Add build tools for compiling native node modules
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

# 1. Bring in the build tools to Stage 2 so production native modules can compile
RUN apk add --no-cache python3 make g++ build-base

COPY package*.json ./

# 2. Modernised the flag to avoid the deprecation warning
RUN npm install --omit=dev

# Copy compiled JavaScript code from the builder stage
COPY --from=builder /app/dist ./dist

# 3. Optional optimization: Clean up build tools to keep the final image size small
RUN apk del python3 make g++ build-base

CMD ["npm", "start"]
