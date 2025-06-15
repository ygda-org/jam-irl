FROM ubuntu:22.04

# Install required dependencies
RUN apt-get update && apt-get install -y \
    libasound2 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libfreetype6 \
    libgcc1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    libnss3 \
    libxss1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Create a directory for the server
WORKDIR /app

# Copy the server files
COPY build/linux/project.x86_64 /app/
COPY build/linux/project.pck /app/

# Make the server executable
RUN chmod +x /app/project.x86_64

# Expose the server port
EXPOSE 8080

# Command to run the server
CMD ["./project.x86_64", "--server", "--headless"] 