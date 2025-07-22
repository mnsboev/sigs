# Use the official lightweight Alpine image as the base
FROM evidencetrial.jfrog.io/local-oci-bug-hunt-a/alpine:v1.0 AS builder


# Set the working directory inside the container
WORKDIR /app

# Copy the Go modules manifests
COPY go.* ./

# Download dependencies
RUN go mod download

# Copy the source code
COPY src/ ./src/

# Build the Go application
RUN go build -o main ./src/cmd/main.go

# Use a minimal runtime image
FROM evidencetrial.jfrog.io/evidence-demo-docker-dev/hello-world-1.1:1.1

# Set the working directory inside the runtime container
WORKDIR /app

# Copy the compiled binary from the builder stage
COPY --from=builder /app/main .

# Expose the application port (if applicable)
EXPOSE 8080

# Command to run the application
CMD ["./main"]
