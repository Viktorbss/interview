install minikube

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
minikube start --driver=docker
minikube addons enable metrics-server  (needed to measure pod performance)
minikube version

deploy app
(expets to have docker built locally image: ubuntu-hello:latest)

(i had a problem with pulling image, but this helped, built docker inside internal minikube docker registry
eval $(minikube docker-env)
docker build -t ubuntu-hello:latest .
)
./app_deploy.sh

deploy_nginx.sh
./deploy_nginx.sh


testing HPA
run in our terminal run:
while kubectl get hpa -n hello; do sleep 1; done

in another terminal window:
sudo apt install -y apache2-utils
ab -n 100000 -c 50 http://$(minikube ip):30080/
you can see scaling pods to 4 as cpu usage is increased immediatelly and after load descresd after 60 seconds scaling down



AI was not in use, but snippets reuses from internet, tested locally