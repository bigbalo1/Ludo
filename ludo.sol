// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleLudo {
    uint8 public constant BOARD_SIZE = 15; 
    uint8 public constant DICE_SIDES = 6;  

    address public owner;
    uint256 private seed;

    struct Player {
        address playerAddress;
        uint8 position;
    }

    Player[4] public players; // Ludo typically has 4 players
    uint8 public playerCount;
    uint8 public currentPlayerIndex;

    event DiceRolled(address indexed player, uint8 roll);
    event PlayerMoved(address indexed player, uint8 newPosition);

    constructor() {
        owner = msg.sender;
        seed = block.timestamp; // Seed for randomness
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier onlyPlayers() {
        bool isPlayer = false;
        for (uint8 i = 0; i < playerCount; i++) {
            if (players[i].playerAddress == msg.sender) {
                isPlayer = true;
                break;
            }
        }
        require(isPlayer, "Only registered players can call this");
        _;
    }

    function registerPlayer() public {
        require(playerCount < 4, "Maximum 4 players allowed");
        for (uint8 i = 0; i < playerCount; i++) {
            require(players[i].playerAddress != msg.sender, "Player already registered");
        }
        players[playerCount] = Player(msg.sender, 0);
        playerCount++;
    }

    function rollDice() public onlyPlayers returns (uint8) {
        require(playerCount == 4, "Four players are required to start the game");
        require(msg.sender == players[currentPlayerIndex].playerAddress, "It's not your turn");

        uint8 roll = uint8((uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, seed))) % DICE_SIDES) + 1);
        seed++; // Update seed for next randomness

        emit DiceRolled(msg.sender, roll);

        movePlayer(roll);

        currentPlayerIndex = (currentPlayerIndex + 1) % playerCount;

        return roll;
    }

    function movePlayer(uint8 roll) private {
        Player storage player = players[currentPlayerIndex];
        player.position = (player.position + roll) % BOARD_SIZE; // Move the player
        emit PlayerMoved(player.playerAddress, player.position);
    }

    function getPlayerPosition(address _player) public view returns (uint8) {
        for (uint8 i = 0; i < playerCount; i++) {
            if (players[i].playerAddress == _player) {
                return players[i].position;
            }
        }
        revert("Player not found");
    }
}
