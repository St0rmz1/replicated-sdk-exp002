FROM cgr.dev/chainguard/wolfi-base:latest as local_go

RUN apk update && apk add ca-certificates-bundle build-base openssh go-1.21~=1.21.7
ENTRYPOINT /usr/bin/go

FROM local_go as builder

ENV PROJECTPATH=/go/src/github.com/replicatedhq/replicated-sdk
WORKDIR $PROJECTPATH

COPY Makefile.build.mk ./
COPY Makefile ./
COPY go.mod go.sum ./
COPY cmd ./cmd
COPY pkg ./pkg

ARG git_tag
ENV GIT_TAG=${git_tag}

RUN make build && mv ./bin/replicated /replicated

FROM cgr.dev/chainguard/static:latest

COPY --from=builder /replicated /replicated

WORKDIR /

EXPOSE 3000
ENTRYPOINT ["/replicated"]
CMD ["api"]
