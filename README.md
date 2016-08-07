# Planning poker
==============

## Getting started

* run backend: `./backend $ sbt run`
* run frontend: `./frontend $ npm start`

## General
* Poker room
* User (name)
* Moderator (name)

* Estimation round (id, results)
* Estimation (user, value)
* Estimation result

### Users

Clients keep a list of all other users currently estimating. The event when a user joins or leaves the room is broadcasted to all other participants.

`ParticipantJoined (name)`
`ParticipantLeft (name)`

When a new user joins into a room already filled with users, he/she receives information about all other users through multiple `ParticipantJoined` events.

### Moderation

The first user to join a channel is considered moderator. A moderator has additional rights. The user is able to initiate the estimation of a new task.

Additionally, the moderator is able to make another user a moderator while losing the status (there is always only exactly one moderator). Likewise when the moderator leaves the room, a new user is chosen to be moderator.

### Estimation

* Start new estimation round
    * Moderator decides to move on to the next story and asks users to estimate.

* Send estimation
    * User sends his/her estimation for the current story.

* Request to reveal result
    * Moderator requests to reveal the users' estimations.

* Restart estimation
    * Moderator resets all estimations and asks users to estimate again.


