# Stage 1: Build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env

# Set the working directory
WORKDIR /app

# Copy the csproj file and restore dependencies
# This caches the restore step, speeding up subsequent builds
COPY *.csproj ./
RUN dotnet restore

# Copy the rest of the application files
COPY . ./

# Publish the application
RUN dotnet publish -c Release -o out

# Stage 2: Create the final runtime image with a non-root user
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final-env

# Create a non-root user and group
# The UID and GID can be chosen, but often 1000 or higher is used for non-system users.
ARG UID=1001
ARG GID=1001
RUN addgroup --gid $GID appgroup && adduser --system --uid $UID --ingroup appgroup appuser

# Set the working directory for the application
WORKDIR /app

# Copy the published application from the build stage
COPY --from=build-env /app/out .

# Set ownership of the application directory to the non-root user
# This is crucial so the non-root user can read and execute the files.
RUN chown -R appuser:appgroup /app

# Switch to the non-root user
USER appuser

# Expose the port your application listens on (e.g., for ASP.NET Core)
EXPOSE 8080

# Define the entry point for the application
# Replace YourApplicationName.dll with the actual name of your compiled DLL
ENTRYPOINT ["dotnet", "BookShoppingCartMvcUI.dll"]