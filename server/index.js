const express = require("express");
var http = require("http");
const app = express();
const port = process.env.PORT || 3000;
var server = http.createServer(app);
const mongoose = require("mongoose");
const Room = require('./models/Room');
var socket = require("socket.io");
var io = socket(server);
const getCode = require('./api/getCode');

// middleware
app.use(express.json());

//connect to MongoDB
const DB = 'mongodb+srv://HariDev:!Hari2002@cluster0.m6a3i.mongodb.net/myFirstDatabase?retryWrites=true&w=majority';

mongoose.connect(DB).then(() => {
    console.log('Connection Successful');
}).catch((e) => {
    console.log(e);
})


io.on('connection', (socket) => {
    console.log('connected');
    //Create game
    socket.on('create-game', async ({ nickname, name, occupancy, maxRounds }) => {
        try {
            console.log('room created');
            const existingRoom = await Room.gameModel.findOne({ name });
            if (existingRoom) {
                socket.emit('notCorrectGame', 'Room with that name already exists.');
                return;
            }
            const code = getCode();
            let room = new Room.gameModel({
                word: code,
                name: name,
                occupancy: occupancy,
                maxRounds: maxRounds
            }
            );

            let player = {
                socketID: socket.id,
                nickname,
                isPartyLeader: true,
            }
            room.players.push(player);
            room = await room.save();
            socket.join(name);
            io.to(name).emit('updateRoom', room);
        } catch (err) {
            console.log(err);
        }
    });

    //Join Game
    socket.on('join-game', async ({ nickname, name }) => {
        try {
            console.log('room joined');
            let room = await Room.gameModel.findOne({ name });
            if (!room) {
                socket.emit('notCorrectGame', 'Please enter a valid room name.');
                return;
            }

            if (room.isJoin) {
                let player = {
                    socketID: socket.id,
                    nickname,
                }
                room.players.push(player);
                socket.join(name);

                if (room.players.length === room.occupancy) {
                    room.isJoin = false;
                }
                room.turn = room.players[room.turnIndex];
                room = await room.save();
                io.to(name).emit('updateRoom', room);
            }
            else {
                socket.emit('notCorrectGame', 'The game is in progress.');
            }
        } catch (err) {
            console.log(err);
        }
    })

    //White Board
    socket.on('paint', ({ details, roomName }) => {
        io.to(roomName).emit('points', { details });
    })

    //Colors
    socket.on('color-change', ({ color, roomName }) => {
        io.to(roomName).emit('color-change', color);
    })

    //Stroke
    socket.on('stroke-width', ({ value, roomName }) => {
        io.to(roomName).emit('stroke-width', value);
    })

    //Clear Screen
    socket.on('clear-screen', (roomName) => {
        io.to(roomName).emit('clear-screen', '');
    })

    //Display messages
    socket.on('msg', async (data) => {
        try {
            if (data.msg === data.word) {
                let room = await Room.gameModel.find({ name: data.roomName });
                let user = room[0].players.filter(
                    (player) => player.nickname === data.username);
                if (data.timeTaken !== 0) {
                    user[0].points += Math.round((200 / data.timeTaken) * 10);
                }
                room = await room[0].save();
                io.to(data.roomName).emit('msg', {
                    username: data.username,
                    msg: 'Correct!!!',
                    correctUserCounter: data.correctUserCounter + 1
                })
                socket.emit('closeInput', "");
            }
            else {
                io.to(data.roomName).emit('msg', {
                    username: data.username,
                    msg: data.msg,
                    correctUserCounter: data.correctUserCounter
                })
            }
        } catch (err) {
            console.log(err);
        }
    })

    socket.on('updateScore', async (name) => {
        try {
            const room = await Room.gameModel.findOne({ name });
            io.to(name).emit('updateScore', room);
        } catch (err) {
            console.log(err);
        }
    })

    //Change Turn for Each User
    socket.on('change-turn', async (name) => {
        try {
            let room = await Room.gameModel.findOne({ name });
            let idx = room.turnIndex;
            if (idx + 1 === room.players.length) {
                room.currentRound += 1;
            }
            if (room.currentRound <= room.maxRounds) {
                const code = getCode();
                room.word = code;
                room.turnIndex = (idx + 1) % room.players.length;
                room.turn = room.players[room.turnIndex];
                room = await room.save();
                io.to(name).emit('change-turn', room);
            }
            else {
                io.to(name).emit("show-leaderboard", room.players);
            }
        } catch (err) {
            console.log(err);
        }
    })

    socket.on('disconnect', async () => {
        try {
            let room = await Room.gameModel.findOne({ "players.socketID": socket.id });
            for (let i = 0; i < room.players.length; i++) {
                if (room.players[i].socketID === socket.id) {
                    room.players.splice(i, 1);
                    //io.to(name).emit('change-turn', room.players[i]);
                    break;
                }
            }
            room = await room.save();
            if (room.players.length === 1) {
                socket.broadcast.to(room.name).emit('show-leaderboard', room.players);
            }
            else {
                socket.broadcast.to(room.name).emit('user-disconnected', room);
            }
        } catch (err) {
            console.log(err);
        }
    })
})

server.listen(port, "0.0.0.0", () => {
    console.log('Server started and running on port ' + port + ' successfully');
})