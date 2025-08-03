// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {HelloWorld} from "./HelloWorld.sol";

contract HelloWorldFactory {
    mapping(uint256 => HelloWorld) map;

    function createHelloWorld(uint256 _index) public {
        map[_index] = new HelloWorld();
    }

    function sayHello(uint256 _index, uint256 _id)
        public
        view
        returns (string memory)
    {
        return map[_index].sayHello(_id);
    }

    function setHelloWorld(
        uint256 _index,
        string memory newStr,
        uint256 _id
    ) public {
        map[_index].setHelloWorld(newStr, _id);
    }
}
