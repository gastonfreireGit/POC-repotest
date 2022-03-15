FROM mcr.microsoft.com/dotnet/core/sdk:3.1.402-bionic-arm64v8 AS build-env

#RUN apt update && apt install nano -y
#RUN apt-get install qemu qemu-user-static binfmt-support debootstrap -y
#RUN curl -SL -o dotnet.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/Sdk/master/dotnet-sdk-latest-linux-arm64.tar.gz
#RUN sudo mkdir -p /usr/share/dotnet
#RUN tar -oxzf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App
#RUN ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
RUN export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
RUN export ASPNETCORE_ENVIRONMENT=Development

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
EXPOSE 443
