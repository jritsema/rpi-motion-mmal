### rpi-motion-mmal

Docker image with [motion-mmal](http://wiki.raspberrytorte.com/index.php?title=Motion_MMAL) setup and configured to support [motion](https://github.com/Motion-Project/motion) with the raspberry pi camera module based on [this post](http://www.codeproject.com/Articles/665518/Raspberry-Pi-as-low-cost-HD-surveillance-camera).  

In other words, use your raspberry pi with camera module as a surveillance system by running this container.

#### usage

```bash
$ docker run --device /dev/vchiq -p 80:8081 -p 8080:8080 -v /home/pi:/home/pi jritsema/rpi-motion-mmal
```

or using docker-compose...

```yaml
motion:
  container_name: driveway-motion
  image: jritsema/rpi-motion-mmal
  devices:
    - "/dev/vchiq"
  volumes:
    - /home/pi/motion:/home/pi
    - /home/pi/cam-driveway/motion-mmalcam.conf:/etc/motion.conf
  ports:
    - "80:8081"
    - "8080:8080"
  restart: always
```