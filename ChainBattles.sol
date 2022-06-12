// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Stats {
        uint256 level;
        uint256 attack;
        uint256 defense;
        uint256 skillPoints;
    }

    mapping(uint256 => Stats) public tokenIdtoStats;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function generateCharacter(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }",
            ".type { fill: red; font-family: serif; font-size: 22px; }",
            ".sp { fill: yellow; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="20%" class="type" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Level: ",
            getLevel(tokenId),
            "</text>",
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Attack: ",
            getAttack(tokenId),
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Defense: ",
            getDefense(tokenId),
            "</text>",
            '<text x="50%" y="60%" class="sp" dominant-baseline="middle" text-anchor="middle">',
            "Skill points: ",
            getSkillPoints(tokenId),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getLevel(uint256 tokenId) public view returns (string memory) {
        Stats memory _stats = tokenIdtoStats[tokenId];
        return _stats.level.toString();
    }

    function getAttack(uint256 tokenId) public view returns (string memory) {
        Stats memory _stats = tokenIdtoStats[tokenId];
        return _stats.attack.toString();
    }

    function getDefense(uint256 tokenId) public view returns (string memory) {
        Stats memory _stats = tokenIdtoStats[tokenId];
        return _stats.defense.toString();
    }

    function getSkillPoints(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        Stats memory _stats = tokenIdtoStats[tokenId];
        return _stats.skillPoints.toString();
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        Stats storage _stats = tokenIdtoStats[newItemId];
        _stats.level = 0;
        _stats.attack = rand();
        _stats.defense = rand();
        _stats.skillPoints = 2 + rand();
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(
            ownerOf(tokenId) == msg.sender,
            "You can't train a warrior that you don't own!"
        );

        Stats storage _stats = tokenIdtoStats[tokenId];

        require(
            _stats.skillPoints > 0,
            "The Skill points of this NFT are finished, you can not train it anymore!"
        );

        uint256 currentLevel = _stats.level;
        _stats.level = currentLevel + 1;

        uint256 currentAttack = _stats.attack;
        _stats.attack = currentAttack + rand();

        uint256 currentDefense = _stats.defense;
        _stats.defense = currentDefense + rand();

        uint256 currentSkillPoints = _stats.skillPoints;
        _stats.skillPoints = currentSkillPoints - 1;

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    /*
    function getRandomNumber(uint256 max) public view returns (uint256) {
        bytes memory seed = abi.encodePacked(
            block.timestamp,
            block.difficulty,
            msg.sender
        );
        uint256 rand = random(seed, max);
        return rand;
    }

    function random(bytes memory _seed, uint256 max)
        private
        pure
        returns (uint256)
    {
        return uint256(keccak256(_seed)) % max;
    }
    */

    function rand() public view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
                            (block.timestamp)) +
                        block.number
                )
            )
        );

        return (seed - ((seed / 10) * 10));
    }
}
