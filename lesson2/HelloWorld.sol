// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract HelloWorld {
    string strVar = "Hello World";
    bool success = true;
    bool failure = false;

    struct Info {
        string phrase;
        uint256 id;
        address addr;
    }

    Info[] infos;

    mapping(uint256 => Info) infoMapping;

    function sayHello(uint256 _id) public view returns (string memory) {
        // for (uint256 i = 0; i < infos.length; i++) {
            // if (infos[i].id == _id) {
                // return addinfo(infos[i].phrase);
            // }
        // }
        // return addinfo(strVar);

        if (infoMapping[_id].addr == address(0)) {
            return addinfo(strVar);
        } else {
            return addinfo(infoMapping[_id].phrase);
        }
    }

    function setHelloWorld(string memory newStr, uint256 _id) public {
        Info memory info = Info(newStr, _id, msg.sender);
        infos.push(info);
        infoMapping[_id] = info;
    }

    function addinfo(string memory helloWorldStr)
        internal
        pure
        returns (string memory)
    {
        return string.concat(helloWorldStr, " from Frank's contract.");
    }
}
