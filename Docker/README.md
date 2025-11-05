https://github.com/fiskaly/coding-challenges/tree/main/sre-challenge


build app
docker build -t ubuntu-hello .
docker run -p 8080:8080 ubuntu-hello


check app repsonse 
curl -v http://localhost:8080
