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

Optionally, if you would like each motion event to be auto-tagged using [Amazon's Rekognition service](https://github.com/jritsema/rekognize), you can add your AWS keys as environment variables and configure motion as follows.

```yaml
motion:
  container_name: driveway-motion
  image: jritsema/rpi-motion-mmal
  environment:
    - "AWS_ACCESS_KEY_ID=xyz"
    - "AWS_SECRET_ACCESS_KEY=xyz"
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

motion.conf

```
on_picture_save rekognize %f > %f.json
```

And if you want to [auto-email an event based on certain tags](https://github.com/jritsema/rekognotify), you can use the following.

```yaml
motion:
  container_name: driveway-motion
  image: jritsema/rpi-motion-mmal
  environment:
    - "AWS_ACCESS_KEY_ID=xyz"
    - "AWS_SECRET_ACCESS_KEY=xyz"
    - "REKOGNOTIFY_MATCH=Human,People,Person,Animal,Mammal"
    - "REKOGNOTIFY_HOST=smtp.server.net"
    - "REKOGNOTIFY_USER=user@server.net"
    - "REKOGNOTIFY_PASS=xyz"
    - "REKOGNOTIFY_SENDER_ADDRESS=user@server.net>"
    - "REKOGNOTIFY_RECEIVER_ADDRESS=user2@server.net"
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

motion.conf
```
on_picture_save rekognize %f | tee %f.json | rekognotify %f
```
