#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:3.1 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build
WORKDIR /src
COPY ["GrpcGreeterServer/GrpcGreeterServer.csproj", "GrpcGreeterServer/"]
RUN dotnet restore "GrpcGreeterServer/GrpcGreeterServer.csproj"

COPY . .
WORKDIR "/src/GrpcGreeterServer"
RUN dotnet build "GrpcGreeterServer.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "GrpcGreeterServer.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "GrpcGreeterServer.dll"]