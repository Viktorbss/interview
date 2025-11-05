#!/bin/bash
set -e

echo "Deploying NGINX Load Balancer..."

# Ensure namespace exists
kubectl create namespace hello --dry-run=client -o yaml | kubectl apply -f -

# --- ConfigMap ---
kubectl apply -n hello -f - <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    events { worker_connections 1024; }
    http {
      upstream hello_upstream {
        server hello-service.hello.svc.cluster.local:8080;
      }

      server {
        listen 80;
        location / {
          proxy_pass http://hello_upstream;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        }
      }
    }
EOF

# --- Deployment ---
kubectl apply -n hello -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-lb
  labels:
    app: nginx-lb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-lb
  template:
    metadata:
      labels:
        app: nginx-lb
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 101
      containers:
        - name: nginx
          image: nginx:1.27-alpine
          ports:
            - containerPort: 80
          volumeMounts:
            - name: nginx-config
              mountPath: /etc/nginx/nginx.conf
              subPath: nginx.conf
            - name: nginx-cache
              mountPath: /var/cache/nginx       # writable cache
            - name: nginx-run
              mountPath: /run                   # writable PID directory
          resources:
            requests:
              cpu: "50m"
              memory: "64Mi"
            limits:
              cpu: "200m"
              memory: "128Mi"
          securityContext:
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
            capabilities:
              drop: ["ALL"]
      volumes:
        - name: nginx-config
          configMap:
            name: nginx-config
        - name: nginx-cache
          emptyDir: {}
        - name: nginx-run
          emptyDir: {}
EOF

# --- Service ---
kubectl apply -n hello -f - <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: nginx-lb-service
spec:
  type: NodePort
  selector:
    app: nginx-lb
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
EOF

echo "NGINX Load Balancer deployed successfully!"
kubectl get svc -n hello