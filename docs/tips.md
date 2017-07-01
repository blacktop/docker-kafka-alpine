Tips and Tricks
---------------

##### Get Kafka Host IPs

Linux

```bash
$ ifconfig docker0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
```

Docker Machine

```bash
$ docker-machine ip <machine_name>
```

Docker for Mac

```bash
# It defaults to `localhost`
```
