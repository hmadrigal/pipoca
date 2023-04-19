#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/runtime:3.1 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build
WORKDIR /src
COPY ["GrpcGreeterClient.csproj", "GrpcGreeterClient/"]
RUN dotnet restore "GrpcGreeterClient/GrpcGreeterClient.csproj"
COPY . GrpcGreeterClient/
WORKDIR "/src/GrpcGreeterClient"
RUN dotnet build "GrpcGreeterClient.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "GrpcGreeterClient.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "GrpcGreeterClient.dll"]