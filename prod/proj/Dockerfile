ARG BW_BUILD_DOCKER_IMAGE
ARG BW_BUILD_DOCKER_TAG
FROM ${BW_BUILD_DOCKER_IMAGE}:${BW_BUILD_DOCKER_TAG}

RUN apk add dumb-init 

RUN mkdir /proj
WORKDIR /proj
COPY ./copy/echo .

ENTRYPOINT [ "dumb-init", "--",  "/proj/echo" ]
EXPOSE 8000
