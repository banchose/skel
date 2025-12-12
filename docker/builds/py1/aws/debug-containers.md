# Debug a container

## Add:

- Add a command to keep the container running
- Can access file system

```yaml
spec:
  template:
    spec:
      containers:
      - env: ...
        image: docker-repository.healthresearch.org:8443/pisalapi:awsringotest-2.19.110_b6a6e71
        imagePullPolicy: IfNotPresent
        name: debug-pisalapi-test
        command: ["/bin/sh", "-c", "while true; do sleep 30; done"]  # Add this line here
        ports:
        - containerPort: 9001
          name: debug-pisalapi
          protocol: TCP

```

```bash
kubectl debug pisalapi-5464db8c7c-r2k7q -it --image=docker-repository.healthresearch.org:8443/pisalapi:awsringotest-2.19.110_b6a6e71 --share-processes -- sh

# extract spring boot jar
jar tf app.jar | grep -E 'application.*\.properties|application.*\.yml|application.*\.yaml'

# Run the spring boot backend
java -Dspring.profiles.active=awsringo -jar app.jar
```



```bash
# netshoot
kubectl debug -it mypod --image=nicolaka/netshoot --target=mypod

kubectl run tmp-shell --rm -i --tty --overrides='{"spec": {"hostNetwork": true}}'  --image nicolaka/netshoot
```
```
