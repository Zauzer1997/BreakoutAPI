# Etapa de build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copia solo los archivos de proyecto y restaura dependencias (mejora cache)
COPY *.sln .
COPY */*.csproj ./
RUN for file in $(ls *.csproj); do mkdir -p ${file%.*}/ && cp $file ${file%.*}/; done

# Restaura paquetes
RUN dotnet restore

# Copia todo el código y publica
COPY . .
RUN dotnet publish -c Release -o /app/publish --no-restore

# Etapa final (más ligera)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

# Puerto que usa Render (importante)
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "BreakoutAPI.dll"]   # ← Cambia esto por el nombre de tu DLL