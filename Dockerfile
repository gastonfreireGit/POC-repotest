#FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build-env
ARG REPO=mcr.microsoft.com/dotnet/runtime
FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build-env

#RUN apt update && apt install nano -y
RUN wget -O aspnetcore.tar.gz https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/3.1.0/aspnetcore-runtime-3.1.0-linux-musl-arm64.tar.gz
RUN mkdir -p /usr/share/dotnet
RUN tar -oxzf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App
#RUN ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
RUN export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
RUN export ASPNETCORE_ENVIRONMENT=Development

#RUN aspnetcore_version=3.1.23 \
#    && wget -O aspnetcore.tar.gz https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/3.1.0/aspnetcore-runtime-3.1.0-linux-musl-arm64.tar.gz \
#    && aspnetcore_sha512='530801e168078a6a64d24fcf5d3622e8c9042a2a7a92e612c85137958ac57fc9d98cc5812124d373eb56a0ee6d8ac25edc96b09cbe68f0a46673ae287f7562a2' \
#    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
#    && tar -oxzf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
#    && rm aspnetcore.tar.gz

WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY ./ /app/
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/sdk:3.1
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "CFCImplementation.dll"]
EXPOSE 80
EXPOSE 443