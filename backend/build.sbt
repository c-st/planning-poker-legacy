name := """pp-backend"""

version := "1.0"

scalaVersion := "2.11.6"

libraryDependencies ++= Seq(
  "com.typesafe.akka" %% "akka-actor" % "2.4.8",
  "com.typesafe.akka" %% "akka-http-core" % "2.4.8",
  "com.typesafe.akka" %% "akka-http-experimental" % "2.4.8"
)
