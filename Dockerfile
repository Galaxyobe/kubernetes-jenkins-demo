FROM alpine:3.7
COPY bin/app /app  
CMD ["./app"]