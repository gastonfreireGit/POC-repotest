FROM mcr.microsoft.com/dotnet/core/sdk:6.0.201-alpine3.14-arm64v8 AS build-env
WORKDIR /app
# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore
# Copy everything else and build
COPY ./ /app/
RUN dotnet publish -c Release -o out
RUN curl -SL -o dotnet.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/Sdk/master/dotnet-sdk-latest-linux-arm64.tar.gz
RUN mkdir -p /usr/share/dotnet
RUN tar -zxf dotnet.tar.gz -C /usr/share/dotnet
RUN export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
RUN export ASPNETCORE_ENVIRONMENT=Development
# Build runtime image
FROM mcr.microsoft.com/dotnet/core/runtime:3.1.23-alpine3.14-arm64v8
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT  ["dotnet", "test-docker6.dll"]
EXPOSE 80
