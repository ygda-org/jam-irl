from prisma import Prisma

# Create a single Prisma client instance
prisma = Prisma()

# Export the client
__all__ = ['prisma'] 