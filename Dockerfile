FROM microsoft/dotnet:2.2.103-sdk

ARG SONAR_VERSION=3.3.0.1492
ARG SONAR_SCANNER_CLI=sonar-scanner-cli-${SONAR_VERSION}
ARG SONAR_SCANNER=sonar-scanner-${SONAR_VERSION}
ENV SONAR_SCANNER_MSBUILD_VERSION 4.6.0.1930
# reviewing this choice
ENV DOCKER_VERSION 18.06.1~ce~3-0~debian
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

COPY drone-sonar /bin/
WORKDIR /bin
RUN curl https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/${SONAR_SCANNER_CLI}.zip -so /bin/${SONAR_SCANNER_CLI}.zip
RUN unzip ${SONAR_SCANNER_CLI}.zip \
    && rm ${SONAR_SCANNER_CLI}.zip \
    && apt-get purge --auto-remove curl -y

ENV PATH $PATH:/sonar-scanner/${SONAR_SCANNER}/bin
ENV PATH $PATH:/bin/${SONAR_SCANNER}/bin

# Cleanup
RUN apt-get -q autoremove \
    && apt-get -q clean -y \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*.bin

RUN chmod u+x /bin/drone-sonar 
 
ENTRYPOINT /bin/drone-sonar