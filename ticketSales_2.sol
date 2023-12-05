// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract TicketSales {
    mapping(string => string) private tickets;
    address public owner;
    uint256 public deployTime;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier withinTimePeriod() {
        require(block.timestamp < deployTime + 1 days, "Time period exceeded");
        _;
    }

    constructor() {
        owner = msg.sender;
        deployTime = block.timestamp;
    }

    function setTicket(string memory barcode, string memory firstName, string memory lastName) public onlyOwner withinTimePeriod {
        require(bytes(barcode).length > 0, "Barcode cannot be empty");
        require(bytes(tickets[barcode]).length == 0, "Ticket already set");

        string memory firstTwoOfFirst = substring(firstName, 0, 2);
        string memory firstSixOfLast = substring(lastName, 0, 6);

        string memory uniqname = string(abi.encodePacked(firstSixOfLast, firstTwoOfFirst));
        tickets[barcode] = uniqname;
    }

    function getTicket(string memory barcode) public view returns (string memory) {
        return tickets[barcode];
    }

    function verifySeller(string memory barcode, string memory sellerFirstName, string memory sellerLastName) public view returns (string memory) {
        require(bytes(tickets[barcode]).length > 0, "Ticket not found");

        string memory firstTwoOfFirst = substring(sellerFirstName, 0, 2);
        string memory firstSixOfLast = substring(sellerLastName, 0, 6);

        string memory sellerUniqname = string(abi.encodePacked(firstSixOfLast, firstTwoOfFirst));

        if (keccak256(bytes(tickets[barcode])) == keccak256(bytes(sellerUniqname))) {
            return "Authentic Ticket Seller";
        } else {
            return "Not Authentic";
        }
    }

    function isTicketValid(string memory barcode) public view returns (bool) {
        return bytes(tickets[barcode]).length > 0;
    }

    function deleteTicket(string memory barcode) public onlyOwner {
        require(bytes(tickets[barcode]).length > 0, "Ticket not found");
        delete tickets[barcode];
    }

    function substring(string memory str, uint256 startIndex, uint256 endIndex) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        require(startIndex < strBytes.length, "Invalid start index");
        require(endIndex <= strBytes.length, "Invalid end index");
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }
}
