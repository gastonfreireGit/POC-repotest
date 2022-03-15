FROM mcr.microsoft.com/dotnet/core/sdk:3.1.402-bionic-arm64v8 AS build-env
WORKDIR /app
# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore
# Copy everything else and build
COPY ./ /app/
RUN dotnet publish -c Release -o out
RUN curl -SL -o dotnet.tar.gz https://download.visualstudio.microsoft.com/download/pr/5da6dffe-5c27-4d62-87c7-a3fca48be9bd/967bd7ddc7bbcaef20671175f7b26ee3/dotnet-sdk-3.1.417-linux-arm64.tar.gz
RUN mkdir -p /usr/share/dotnet
RUN tar -zxf dotnet.tar.gz -C /usr/share/dotnet
RUN export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
RUN export ASPNETCORE_ENVIRONMENT=Development
# Build runtime image
FROM mcr.microsoft.com/dotnet/core/runtime:3.1.8-bionic-arm64v8
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT  ["dotnet", "test-docker-net.dll"]
EXPOSE 80
# dotnet build -r linux-arm64
# dotnet publish -c Release -r linux-arm64