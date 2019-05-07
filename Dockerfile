FROM openjdk:8u212-jre-stretch

ARG SONAR_VERSION=3.3.0.1492
ARG SONAR_SCANNER_MSBUILD_VERSION=4.3.1.1372
ARG SONAR_SCANNER_CLI=sonar-scanner-cli-${SONAR_VERSION}
ARG SONAR_SCANNER=sonar-scanner-${SONAR_VERSION}
ARG DOTNET_SDK_VERSION=2.1
ARG MONO_DEBIAN_VERSION=5.12.0.226-0xamarin3+debian9b1
ARG DOTNET_PROJECT_DIR=/project
ARG DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true
ARG DOTNET_CLI_TELEMETRY_OPTOUT=true
ARG SONAR_SCANNER_MSBUILD_HOME=/opt/sonar-scanner-msbuild

#RUN apt-get update nodejs curl
RUN set -x \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
  && echo "deb http://download.mono-project.com/repo/debian stable-stretch main" | tee /etc/apt/sources.list.d/mono-official-stable.list \
  && apt-get update \
  && apt-get install \
    curl \
    libunwind8 \
    gettext \
    apt-transport-https \
    mono-complete \
    ca-certificates-mono \
    referenceassemblies-pcl \
    mono-xsp4 \
    wget \
    unzip \
    -y \
  && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
  && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
  && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/debian/9/prod stretch main" > /etc/apt/sources.list.d/microsoft-prod.list' \
  && apt-get update \
  && apt-get install dotnet-sdk-${DOTNET_SDK_VERSION} -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/SonarSource/sonar-scanner-msbuild/releases/download/$SONAR_SCANNER_MSBUILD_VERSION/sonar-scanner-msbuild-$SONAR_SCANNER_MSBUILD_VERSION-net46.zip -O /opt/sonar-scanner-msbuild.zip \
  && mkdir -p ${SONAR_SCANNER_MSBUILD_HOME} \
  && mkdir -p ${DOTNET_PROJECT_DIR} \
  && unzip /opt/sonar-scanner-msbuild.zip -d ${SONAR_SCANNER_MSBUILD_HOME} \
  && rm /opt/sonar-scanner-msbuild.zip \
  && chmod 775 ${SONAR_SCANNER_MSBUILD_HOME}/*.exe \
  && chmod 775 ${SONAR_SCANNER_MSBUILD_HOME}/**/bin/* \
  && chmod 775 ${SONAR_SCANNER_MSBUILD_HOME}/**/lib/*.jar

ENV PATH="${SONAR_SCANNER_MSBUILD_HOME}:${SONAR_SCANNER_MSBUILD_HOME}/sonar-scanner-${SONAR_SCANNER_VERSION}/bin:${PATH}"
COPY drone-sonar /bin/
WORKDIR /bin
RUN ls -la
RUN chmod 775 /bin/drone-sonar
RUN chmod u+x /bin/drone-sonar
RUN ls -la

RUN curl https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/${SONAR_SCANNER_CLI}.zip -so /bin/${SONAR_SCANNER_CLI}.zip
RUN unzip ${SONAR_SCANNER_CLI}.zip \
    && rm ${SONAR_SCANNER_CLI}.zip \
    && apt-get purge --auto-remove curl -y

ENV PATH=$PATH:/bin/${SONAR_SCANNER}/bin
RUN ls -la
ENTRYPOINT /bin/drone-sonar
