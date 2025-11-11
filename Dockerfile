FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy *all* project files first to set up restores
# This copies BookShoppingCartMvcUI/BookShoppingCartMvcUI.csproj to /src/BookShoppingCartMvcUI/BookShoppingCartMvcUI.csproj
COPY BookShoppingCartMvcUI/BookShoppingCartMvcUI.csproj  BookShoppingCartMvcUI/
# If you have other projects, copy them too, e.g.:
# COPY ["DataAccessProject/*.csproj", "DataAccessProject/"]


RUN dotnet restore BookShoppingCartMvcUI/BookShoppingCartMvcUI.csproj 

# Copy the rest of your solution
COPY . .

# Set the working directory to the project folder for specific commands
WORKDIR "/src/BookShoppingCartMvcUI"

# Now run your commands
RUN dotnet build "BookShoppingCartMvcUI.csproj" -c Release -o /app/build

FROM mcr.microsoft.com/dotnet/runtime:8.0 AS final
WORKDIR /app

COPY --from=build /app/build /app/
EXPOSE 8080

ENTRYPOINT [ "dotnet", "BookShoppingCartMvcUI.dll" ]