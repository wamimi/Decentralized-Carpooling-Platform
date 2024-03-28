//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RideManagement {
    struct Ride {
        uint id;
        address passenger;
        address driver;
        string destination;
        string status; // Values: "pending", "matched", "in-progress", "completed", "cancelled"
    }

    struct Driver {
        address driverAddress;
        bool isAvailable;
        // Additional driver details
    }

    struct Passenger {
        address passengerAddress;
        // Additional passenger details
    }

    mapping(uint => Ride) public rides;
    mapping(address => Driver) public drivers;
    mapping(address => Passenger) public passengers;

    uint public nextRideId = 1;

    event RideRequested(uint rideId, address indexed passenger);
    event RideMatched(uint rideId, address indexed driver);
    event RideStatusUpdated(uint rideId, string status);
    event RideCancelled(uint rideId);

    // Function to request a ride
    function requestRide(string memory destination) public {
        Ride storage ride = rides[nextRideId++];
        ride.id = nextRideId - 1;
        ride.passenger = msg.sender;
        ride.destination = destination;
        ride.status = "pending";
        passengers[msg.sender].passengerAddress = msg.sender;

        emit RideRequested(ride.id, msg.sender);
    }

    // Function for drivers to register or update their availability
    function registerDriver(bool isAvailable) public {
        drivers[msg.sender].driverAddress = msg.sender;
        drivers[msg.sender].isAvailable = isAvailable;
    }

    // Function to match a ride with a driver
    function matchRide(uint rideId, address driverAddress) public {
        require(drivers[driverAddress].isAvailable, "Driver is not available");
        require(rides[rideId].passenger != address(0), "Ride does not exist");
        require(rides[rideId].driver == address(0), "Ride already has a driver");

        rides[rideId].driver = driverAddress;
        rides[rideId].status = "matched";

        emit RideMatched(rideId, driverAddress);
    }

    // Function to update the status of a ride
    function updateRideStatus(uint rideId, string memory status) public {
        require(rides[rideId].passenger != address(0), "Ride does not exist");
        rides[rideId].status = status;

        emit RideStatusUpdated(rideId, status);
    }

    // Function to cancel a ride
    function cancelRide(uint rideId) public {
        require(rides[rideId].passenger != address(0), "Ride does not exist");
        require(
            keccak256(abi.encodePacked(rides[rideId].status)) == keccak256(abi.encodePacked("pending")) || 
            keccak256(abi.encodePacked(rides[rideId].status)) == keccak256(abi.encodePacked("matched")),
            "Cannot cancel at this stage"
        );

        rides[rideId].status = "cancelled";

        emit RideCancelled(rideId);
    }
}