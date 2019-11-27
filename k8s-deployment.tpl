apiVersion: apps/v1
kind: Deployment
metadata:
  name: {APP_NAME}
  labels:
    app: {APP_NAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {APP_NAME}
  template:
    metadata:
      labels:
        app: {APP_NAME}
    spec:
      containers:
      - name: {APP_NAME}
        image: {IMAGE_URL}
        ports: 
        - containerPort: 8080
          protocol: TCP
          name: web
        env:
          - name: SPRING_PROFILES_ACTIVE
            value: {SPRING_PROFILE}
      imagePullSecrets:
      - name: registry-secret
