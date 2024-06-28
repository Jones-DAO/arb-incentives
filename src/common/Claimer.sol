// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Governable} from "./Governable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// * Investigated Ramses contract
// * Passed the erc-20 balances subgrpah to jones org
// * Made a distributor contract so we can redistribute the ramses rewards and jlp arb stip and whatever else we need
// * had a call with xeno to explain stuff
// * talked with n1mr0d to be able to compute the non compounded jlp balances, need to refactor a bit the router to emit events that are erc20 compliant

/**
 * @title Claimer
 * @author JonesDAO
 * @notice
 */
contract Claimer is Governable {
    /// @notice Token to be distributed
    address[] public distributedAsset;

    /// @notice Farm description
    string public farm;

    address public keeper;

    /// @dev Each root data is hashed using cummulative sum accrued for a given user
    ///      we use cumulative sum to avoid storing multiple roots for each user, meaning that the user just needs to claim once
    ///      Merkle-Tree format: keccak256(abi.encodePacked(account, amounts))
    bytes32[] public roots;

    /// @notice claimed[account] is the amount of tokens claimed by the account in total
    mapping(address => mapping(address => uint256)) public claimed;

    event Claimed(address indexed account, bytes32 root, address[] tokens, uint256[] amounts);

    error NothingToClaim();

    constructor(address[] memory _distributedAsset, string memory _farm, address _keeper) Governable(msg.sender) {
        distributedAsset = _distributedAsset;
        farm = _farm;
        keeper = _keeper;
    }

    function claim(address account, uint256[] memory amounts, bytes32[] calldata merkleProof) external {
        uint256 length = distributedAsset.length;

        require(
            MerkleProof.verify(merkleProof, roots[roots.length - 1], keccak256(abi.encodePacked(account, amounts))),
            "Claimer: Invalid proof"
        );

        for (uint256 i = 0; i < length; i++) {
            uint256 claimed_ = claimed[account][distributedAsset[i]];

            if (claimed_ == amounts[i]) {
                continue;
            }

            uint256 toClaim = amounts[i] - claimed_;

            claimed[account][distributedAsset[i]] = amounts[i];

            IERC20(distributedAsset[i]).transfer(account, toClaim);
        }

        emit Claimed(account, roots[roots.length - 1], distributedAsset, amounts);
    }

    function pushNewRoot(bytes32 root) external {
        require(msg.sender == keeper, "Claimer: Only keeper can push new root");
        roots.push(root);
    }

    function updateKeeper(address _newKeeper) external onlyGovernor {
        keeper = _newKeeper;
    }
}
