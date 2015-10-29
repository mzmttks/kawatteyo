# kawatteyo
A bicycle route tracking &amp; communication application.


## Functions
* Track the racer's running trajectory.
* Simple communication with icons:  **代ってよ**  ("I want to have a rest" for a runner  and "I want to run" for non-runners)


## Protocol

1. [Client --> Server] websocket Connect
2. [Server --> Client] send uuid  (Client stores the uuid)
3. [Client --> Server] send uuid + ":" + username  (Server stores the pair of uuid and username)
4. [Client --> Server] send uuid + ": Kawatteyo"
5. [Server --> Broad ] send "{user: username, message: kawatteyo}"

## Architecture

![Overview](https://raw.githubusercontent.com/mzmttks/kawatteyo/master/images/design.png)
