#!/usr/bin/env bash
. demo-magic.sh
export TYPE_SPEED=100
export DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"
TEMP_DIR=AOT-processing-demo

function initSDKman() {
  source "$HOME/.sdkman/bin/sdkman-init.sh"
}

function createAppWithInitializr {
  # hide the evidence
  rm -rf $TEMP_DIR
  mkdir $TEMP_DIR
  cd $TEMP_DIR || exit
  clear
  pei "# Make sure you are using Java 17"
  pei "java -version"
  pei "# If you are not, use SDKman to switch to Java 17"
  pei "# We are using GraalVM CE 22.3.0 for its AOT processing capabilities"
  wait
  clear
  pei "# Create a new Spring Boot app with the Initializr"
  pei "# We are using the 'web' and 'actuator' starters"
  pei "# We are using Java 17 as the target version"
  pei "# We are using Maven as the build tool"
  pei "# We are using the 'tar' command to extract the downloaded archive, into our current directory"
  pei "curl https://start.spring.io/starter.tgz -d dependencies=web,actuator -d javaVersion=17 -d type=maven-project | tar -xzf - || exit"
  pei "# Look at what we just created"
  pei "tree"
  pei "# A very simple Spring Boot app!"
  pei "# Let's take a look a the generated pom.xml"
  wait
  clear
  pei "more pom.xml"
  pei "# Still, a very simple Spring Boot app!"
  wait
  clear
}

function validateApp {
  pei "# Let's run the app using '-q' to keep the output quiet"
  pei "./mvnw -q clean package spring-boot:start -DskipTests"
  pei "# Take note of the startup time------------------------------------------------------------------------------^^^"
  pei "# Also note that the app is running in the background, so we can continue to use the terminal"
  pei "# You can see the PID in the logs!"
  wait
  clear
  pei "# Let's check the health endpoint"
  pei "# We are using the 'httpie' tool to make HTTP requests"
  pei "http :8080/actuator/health"
  pei "# Yay! Our app is up and healthy!"
  pei "# The same PID shows up in the logs here."
  wait
  clear
  pei "# Let's check the memory usage, using the PID of the app"
  pei "vmmap $(jps | grep DemoApplication | cut -d ' ' -f 1) | grep Physical"
  pei "# That's how much physical memory our JIT-compiled app is using!"
  wait
  clear
  pei "# Let's stop the app, quietly"
  pei "./mvnw -q spring-boot:stop -Dspring-boot.stop.fork"
  pei "# The same PID shows up in the logs, as the app shuts down."
  pei "# All done, now let's see how we can improve this!"
  wait
  clear
}

function nativeValidate {
  pei "# Let's compile the app as a native image"
  pei "# We are using the 'native' profile to enable the native image compilation"
  pei "# We get the 'native' profile and native image compilation for free with Spring Boot 3.0, from the parent pom"
  pei "# The native:compile goal will compile the app as a native image"
  pei "# GraalVM is doing a lot of work here!  It's evaluating every branch of code and optimizing, 'ahead of time'"
  pei "# This is called 'AOT' processing"
  pei "# ./mvnw -q -Pnative native:compile -DskipTests"
  pei "# Creating native images SHOULD NOT be part of your inner-loop development process!"
  wait
  cp ../demo ./target/demo
  clear
  pei "# Let's run the native image"
  pei "# Our Spring Boot app is now a statically linked executable, with no JVM overhead!"
  pei "./target/demo &"
  wait
  pei "# Take note of the new and improved startup time-------------------------------------------------------------^^^"
  wait
  clear
  pei "# Let's check the health endpoint, just as we did before."
  pei "http :8080/actuator/health"
  pei "# Our native-image version of the app is up and healthy!"
  wait
  clear
  pei "# Let's check the memory usage, using the PID of the native image app"
  pei "export NPID=$(pgrep demo)"
  pei "vmmap $NPID | grep Physical"
  pei "# That's a lot better!  Orders of magnitude less memory usage!"
  wait
  clear
  pei "# Let's stop the app, we are done here!"
  pei "kill -9 $NPID"
  wait
  clear
}

function butWhatAboutPerformance {
  pei "# Ok."
  pei "# Startup time is great."
  pei "# Memory footprint is smaller."
  pei "# But what about performance?"
  pei "# Grab a slightly more complex app, and let's do some performance testing!"
  wait
  clear
  pei "# This app loads a bunch of CSV data into Postgres and Redis"
  pei "# Nothing fancy, just read one row at a time, and write one row at a time, into the datastore"
  pei "# You can see the code here:"
  pei "# https://github.com/dashaun/spring-data-jpa-and-redis/"
  wait
  clear
  pei "git clone git@github.com:dashaun/spring-data-jpa-and-redis.git"
  pei "cd spring-data-jpa-and-redis || exit"
  pei "tree"
  wait
  clear
  pei "# Startup Postgres and Redis with the included docker-compose file"
  pei "docker-compose up -d"
  wait
  clear
  pei "# Ok, lets run the app, with JIT compilation, on the JVM"
  pei "./mvnw -q clean package spring-boot:start -DskipTests"
  pei "# Take note of the startup time                                                         ^^^"
  pei "# Also note that the app is running in the background, so we can continue to use the terminal"
  pei "# You can see the PID in the logs!"
  wait
  clear
  pei "# Let's load data into Redis"
  pei "# We are using the 'httpie' tool to make HTTP requests"
  pei "# Because we care about performance, lets measure how long it takes with the 'time' command."
  pei "time http :8080/load-redis"
  pei "# All the data is loaded, note how long it took!"
  wait
  clear
  pei "# Let's look at the memory again, for our slightly more complex app"
  pei "vmmap $(jps | grep Application | cut -d ' ' -f 1) | grep Physical"
  pei "# That's how much physical memory our JIT-compiled app is using!"
  wait
  clear
  pei "# Let's stop the app, quietly"
  pei "./mvnw -q spring-boot:stop -Dspring-boot.stop.fork"
  clear
  pei "# Let's compile this app as a native image..."
  pei "# This is what we ran: ./mvnw -q -Pnative native:compile -DskipTests"
  pei "# I'll copy a precompiled version of the native image into the target directory, for the sake of time."
  wait
  cp ../../retailstore ./target/retailstore
  clear
  pei "./target/retailstore &"
  wait
  pei "# Take note of the new and improved startup time                                          ^^^"
  wait
  clear
  pei "# Let's load the database using our native-image, and see how long it takes"
  pei "time http :8080/load-redis"
  pei "# Our native-image version of the app loaded the exact same data, faster!"
  wait
  clear
  pei "# Let's check the memory usage, using the PID of the native image app"
  pei "export NPID=$(pgrep retailstore)"
  pei "vmmap $NPID | grep Physical"
  pei "# As we expected."
  wait
  clear
  pei "# Let's stop the app, we are done here!"
  pei "kill -9 $NPID"
  pei "docker-compose down"
  wait
  clear
  pei "# Faster startup time, less memory usage, and faster performance!"
  pei "# This workload hit the trifecta!"
  pei "# Not all workloads will get the same benefits from AOT processing, but it's worth trying!"
}

initSDKman
createAppWithInitializr
validateApp
nativeValidate
butWhatAboutPerformance