FROM microsoft/dotnet:2.2.103-sdk

ENV SONAR_SCANNER_MSBUILD_VERSION 4.6.1.2049

# Install Java 8
RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y openjdk-8-jre

# install nodejs
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash - && apt-get install -y nodejs autoconf libtool nasm

# Install Sonar Scanner
RUN apt-get install -y unzip \
    && wget https://github.com/SonarSource/sonar-scanner-msbuild/releases/download/$SONAR_SCANNER_MSBUILD_VERSION/sonar-scanner-msbuild-$SONAR_SCANNER_MSBUILD_VERSION-netcoreapp2.0.zip \
    && unzip sonar-scanner-msbuild-$SONAR_SCANNER_MSBUILD_VERSION-netcoreapp2.0.zip -d /sonar-scanner \
    && rm sonar-scanner-msbuild-$SONAR_SCANNER_MSBUILD_VERSION-netcoreapp2.0.zip \
    && chmod +x -R /sonar-scanner

# Cleanup
RUN apt-get -q autoremove \
    && apt-get -q clean -y \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*.bin

COPY drone-sonar /bin/

WORKDIR /bin

RUN chmod +x /bin/drone-sonar 

ENTRYPOINT /bin/drone-sonar