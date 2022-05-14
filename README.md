# docker-squeezelite

Squeezelite Dockerfile, Alpine flavour.

## Usage

### Kubernetes

**Warning! You'll expose your sound device with a container running as root. Run at your own risk!**

```
kubectl apply -f << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: squeezelite
    node: speakers
  name: squeezelite-speakers
spec:
  replicas: 1
  selector:
    matchLabels:
      app: squeezelite
      node: speakers
  template:
    metadata:
      labels:
        app: squeezelite
        node: speakers
    spec:
      containers:
      - image: clook/squeezelite:1.9-alpine
        env:
        - name: SOUNDDEVICE
          value: hw:0
        - name: CLIENTNAME
          value: Speakers
        - name: SERVER
          value: 10.0.0.5
        name: squeezelite
        command: ["sh"]
        args: ['-c', 'squeezelite -o $SOUNDDEVICE -n "$CLIENTNAME" -s $SERVER -a :::0']
        securityContext:
          privileged: true
        volumeMounts:
        - mountPath: /dev/snd
          name: snd
      tolerations:
      - key: "role"
        operator: "Equal"
        value: "speakers"
        effect: "NoSchedule"
      nodeSelector:
        kubernetes.io/hostname: speakers
      volumes:
      - name: snd
        hostPath:
          path: /dev/snd
```


## TODO

Non-root user, entrypoint
