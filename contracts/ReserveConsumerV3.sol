// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ReserveConsumerV3 {
    AggregatorV3Interface internal reserveFeed;

    constructor(address feedAddress) {
        reserveFeed = AggregatorV3Interface(
            feedAddress
        );
    }

    /**
     * Returns the latest price
     */
    function getLatestReserve() public view returns (int) {
        // prettier-ignore
        (
            /*uint80 roundID*/,
            int reserve,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = reserveFeed.latestRoundData();

        return reserve;
    }

    function getDecimals() view external returns (uint8){
        return reserveFeed.decimals();
    }
}
