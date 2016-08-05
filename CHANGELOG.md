Change Log
==========

All notable changes to this project will be documented in this file.

[0.10] - 2016-08-01
-------------------

### Fixed

-	KAFKA_ZOOKEEPER_CONNECT in configure-kafka.sh

### Added

- ability to run a single node kafka broker when you don't supply a zookeeper link
-	KAFKA_LISTENERS, KAFKA_ADVERTISED_LISTENERS env config flags
-	official configs for reference
-	krallin/tini
-	tianon/gosu
-	golang kafka test client

### Removed

### Changed

-	docker-compose to spin up 3 nodes by default
-	updated docker-compose in Vagrantfile
-	changed tini to /sbin/tini

[0.9] - 2016-08-01
------------------

### Fixed

-	KAFKA_ZOOKEEPER_CONNECT in configure-kafka.sh

### Added

- ability to run a single node kafka broker when you don't supply a zookeeper link
-	KAFKA_LISTENERS, KAFKA_ADVERTISED_LISTENERS env config flags
-	official configs for reference
-	krallin/tini
-	tianon/gosu
-	golang kafka test client

	### Removed

### Changed

-	changed tini to /sbin/tini

[0.8] - 2016-08-01
------------------

### Fixed

-	KAFKA_ZOOKEEPER_CONNECT in configure-kafka.sh

### Added

- ability to run a single node kafka broker when you don't supply a zookeeper link
-	KAFKA_LISTENERS, KAFKA_ADVERTISED_LISTENERS env config flags
-	official configs for reference
-	krallin/tini
-	tianon/gosu
-	golang kafka test client

### Removed

### Changed

-	changed tini to /sbin/tini
