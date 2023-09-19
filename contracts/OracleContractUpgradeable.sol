// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./interfaces/IOracleContract.sol";

contract OracleContractUpgradeable is IOracleContract, OwnableUpgradeable {
    address public constant USD = address(0);   // USD has no contract so set as zero address
    mapping(bytes32 => address) private _aggregators; // pairId => aggregator

    function initialize() public {
        __Ownable_init();
    }

    /**
     * @notice Get price
     * @param tokenA Base token address
     * @param tokenB Second token address
     * @param precision Precision of the price
     * @return price Price answer for the given round
     * Aggregator contract does not expose this information
     */
    function getPrice(address tokenA, address tokenB, uint8 precision)
        external
        view
        virtual
        returns (uint256 price)
    {
        address aggregator = _getAggregator(tokenA, tokenB);
        if (aggregator == address(0)) {
            // Use seperate USD aggregators for tokenA and tokenB
            address aggregatorA = _getAggregator(tokenA, USD);
            address aggregatorB = _getAggregator(tokenB, USD);
            if (aggregatorA == address(0) || aggregatorB == address(0)) {
                return 0;
            }

            (,int256 _priceA,,,) = AggregatorV3Interface(aggregatorA).latestRoundData();
            (,int256 _priceB,,,) = AggregatorV3Interface(aggregatorB).latestRoundData();
            price = uint256(_priceA) * (10**precision) / uint256(_priceB);
        } else {
            // Use direct aggregator
            (,int256 _price,,,) = AggregatorV3Interface(aggregator).latestRoundData();
            uint8 _priceDecimals = AggregatorV3Interface(aggregator).decimals();
            price = _scale(uint256(_price), _priceDecimals, precision);
        }
    }

    // region - Public service function -

    /**
     * @notice Set aggregator address
     * @param tokenA Base token address
     * @param tokenB Second token address
     * @param aggregator Chainlink aggregator address
     * @dev Only owner can set aggregator
     */
    function setAggregator(address tokenA, address tokenB, address aggregator)
        external
        onlyOwner
    {
        require(tokenA != tokenB, "OracleContract: Invalid tokens");
        require(aggregator != address(0), "OracleContract: Invalid aggregator");

        bytes32 pairId = _getPairId(tokenA, tokenB);
        _aggregators[pairId] = aggregator;

        emit AggregatorSet(pairId, tokenA, tokenB, aggregator);
    }

    /**
     * @notice Remove aggregator address
     * @param tokenA Base token address
     * @param tokenB Second token address
     * @dev Only owner can remove aggregator
     */
    function removeAggregator(address tokenA, address tokenB)
        external
        onlyOwner
    {
        bytes32 pairId = _getPairId(tokenA, tokenB);
        require(_aggregators[pairId] != address(0), "OracleContract: No aggregator to remove");
        
        delete _aggregators[pairId];

        emit AggregatorRemoved(pairId, tokenA, tokenB);
    }

    /**
     * @notice Get aggregator address by naming assets
     * @param tokenA Base token address
     * @param tokenB Second token address
     */
    function getAggregator(address tokenA, address tokenB)
        external
        view
        returns (address)
    {
        return _getAggregator(tokenA, tokenB);
    }

    function _getAggregator(address tokenA, address tokenB)
        internal
        view
        returns (address)
    {
        bytes32 pairId = _getPairId(tokenA, tokenB);
        return _aggregators[pairId];
    }

    function _getPairId(address tokenA, address tokenB) private pure returns (bytes32 pairId) {
        pairId = keccak256(abi.encodePacked(tokenA, tokenB));
    }

    function _scale(uint amount, uint8 fromDecimals, uint8 toDecimals) internal pure returns (uint) {
        if (fromDecimals < toDecimals) {
            return amount * (10 ** (toDecimals - fromDecimals));
        }
        else if (fromDecimals > toDecimals) {
            return amount / (10 ** (fromDecimals - toDecimals));
        }
        return amount;
    }
}