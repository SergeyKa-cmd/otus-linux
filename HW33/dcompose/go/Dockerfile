FROM iron/go:dev
WORKDIR /app
COPY myapp.go /app
RUN go build -o myapp
ENTRYPOINT ["./myapp"]