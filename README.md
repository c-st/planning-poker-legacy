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

### Estimation

Clients send their estimation to the server. The server collects incoming estimations and broadcasts the result once all users in the rooms have submitted their estimation.

Estimation is done by sending a `StartEstimation (task)` event to the clients. All clients, also those that connect in the meanwhile receive this event after they have received the user list. When the task to estimate is set on client side, they show buttons that represent the different complexities.
When all clients have submitted their estimations, the server broadcasts the result to all clients (clients receive the estimations of all other users).

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


