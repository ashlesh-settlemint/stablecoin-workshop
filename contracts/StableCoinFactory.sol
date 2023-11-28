// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./StableCoin.sol";
import "./ReserveConsumerV3.sol";

contract StableCoinFactory is Ownable {
    struct Stablecoin {
        string name;
        string symbol;
        uint256 initialSupply;
        uint256 maxSupply;
        address defaultAdmin;
        address pauser;
        address minter;
        address burner;
        uint8 decimal;
        address feedAddress;
        address coinAddress;
    }

    address[] deployedStablecoins;
    Stablecoin[] arrayOfStableCoins;
    mapping(address => Stablecoin) stableCoinDetails;

    event NewStablecoin(address reserveConsumerAddress, address tokenAddress, bool capped);

    constructor(address initialOwner) {
      _transferOwnership(initialOwner);
    }

    function getAllStableCoins() public view returns (Stablecoin[] memory){
        return arrayOfStableCoins;
    }

    function deployStablecoin(
        bool isOffChainOracle,
        address feedAddress,
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint256 maxSupply, // put 0 in case of uncapped
        address defaultAdmin,
        address pauser,
        address minter,
        address burner,
        uint8 decimal
    ) public returns (address) {
        address reserveAddress = address(0);

        if(isOffChainOracle) {
            reserveAddress = address(new ReserveConsumerV3(feedAddress));
        }

        address newToken = address(new StableCoin(name, symbol, initialSupply, defaultAdmin, pauser, minter, burner, decimal));
            emit NewStablecoin(reserveAddress, newToken, false);


        deployedStablecoins.push(newToken);
        arrayOfStableCoins.push(Stablecoin(name, symbol, initialSupply, maxSupply, defaultAdmin, pauser, minter, burner, decimal, feedAddress, newToken));

        stableCoinDetails[newToken] = Stablecoin(name, symbol, initialSupply, maxSupply, defaultAdmin, pauser, minter, burner, decimal, feedAddress, newToken);
        return (newToken);
    }

    function getStablecoinDetails(address stableCoinAddress) public view returns (Stablecoin memory) {
        return stableCoinDetails[stableCoinAddress];
    }
}
