# Scribble

This project is a clone of Skribbl.io, developed using Flutter for the frontend, Node.js (Express) for the backend, and MongoDB as the database. The application features WebSocket integration to ensure real-time broadcasting of drawings to all players in the room simultaneously. It also replicates the scoring system of Scribble to enhance the gaming experience.

## Project Overview and APK Download

For a detailed project overview, please refer to the following video: [Project Overview](https://drive.google.com/file/d/1ZdWTcAfCYSkXKO5x-fQZcOcdsRgwWxMO/view?usp=sharing)

## Technology Stack

- **Frontend:** Flutter
- **Backend:** Node.js (Express)
- **Database:** MongoDB
- **Real-Time Communication:** WebSocket

## Features

- **Real-Time Drawing Synchronization:** WebSocket technology is used to broadcast the drawing actions of the current player to all players in the room in real-time, ensuring a seamless and interactive gameplay experience.

- **Scoring System:**
  - Points are awarded based on the speed and accuracy of guesses. The first player to guess the word correctly earns the most points.
  - Players who guess the word later receive points, but these diminish as more time elapses.
  - The player drawing earns points based on how many players correctly guess the word within the time limit.

- **Room-Based Gameplay:** Players can create and join rooms to play with friends or other users.

- **Replicated Skribbl.io Mechanics:** The game closely mirrors the mechanics of Skribbl.io, including word selection, drawing, guessing, and scoring.

## Canvas Implementation in Flutter

The drawing canvas was implemented in Flutter using custom made `CustomPainter` class and `GestureDetector` widget. Here's how it works:

- **CustomPainter:** A custom painter was created to draw on the canvas. It tracks the points where the user interacts and renders them as lines or strokes.
  - The `paint` method in the `CustomPainter` class is used to draw the strokes based on the list of points collected during user interaction.
  - The `shouldRepaint` method ensures the canvas updates only when necessary.

- **GestureDetector:**
  - A `GestureDetector` widget wraps the canvas and listens for user touch interactions such as `onPanStart`, `onPanUpdate`, and `onPanEnd`.
  - When the user starts drawing, their touch points are added to a list, which is then passed to the `CustomPainter` for rendering.

- **Stroke Details:**
  - Different attributes such as stroke color, stroke width, and opacity can be customized based on the user's preferences.
  - This information is synchronized across all players in the room via WebSocket to ensure real-time updates.

- **Clear and Undo Features:**
  - The implementation includes the ability to clear the canvas or undo the last stroke. These actions are also broadcasted to all players in the room.
 
## Node.js Implementation

Node.js serves as the backend for this project, handling the following functionalities:

- **WebSocket Communication:**
  - Node.js with the `socket.io` library manages real-time communication between the server and clients.
  - When a player draws on the canvas, their actions are broadcasted to all other players in the same room via WebSocket.

- **Room Management:**
  - Node.js handles the creation and management of game rooms, ensuring that players can join specific rooms to play together.
  - Each room maintains its own state, including the current drawer, the selected word, and the scores.

- **Game Logic:**
  - Node.js implements the core game logic, such as word selection, scoring, and turn management.
  - The server ensures that the game progresses smoothly, enforcing rules and notifying clients of state changes.

- **Canvas Synchronization:**
  - The backend ensures that canvas properties such as stroke width, color, and clear or undo actions are synchronized and broadcasted to all players, maintaining consistency across clients.

- **Database Interaction:**
  - Using MongoDB, Node.js stores game-related data such as user information, room details, and scores.

- **REST API Endpoints:**
  - Node.js provides RESTful endpoints for functionalities like retrieving available words, fetching leaderboard data, and managing user accounts.

## Future Improvements

- Adding custom word lists for private rooms.
- Enhancing UI/UX for better player experience.
- Introducing additional game modes and features.
- Improving scalability for larger player groups.


