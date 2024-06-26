pragma solidity 0.8.20;

import {IERC20} from "src/sushi/IERC20.sol";

import {IRewarder} from "src/sushi/IRewarder.sol";
import {IMigratorChef} from "src/sushi/IMigratorChef.sol";
import {UpgradeableGovernable} from "src/common/UpgradeableGovernable.sol";
import {MiniChefV2} from "src/sushi/MiniChefV2.sol";
import {Operable, Governable} from "src/common/Operable.sol";

contract FarmController is UpgradeableGovernable {
    /* -------------------------------------------------------------------------- */
    /*                                 VARIABLES                                  */
    /* -------------------------------------------------------------------------- */

    MiniChefV2 public farm;
    uint256 public deadline;

    /* -------------------------------------------------------------------------- */
    /*                                 INITIALIZE                                 */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Initialize Farm Controller
     * @param _multisig Jones MultiSig
     */
    function initialize(address _multisig, address _farm, uint256 _deadline) external initializer {
        __Governable_init(_multisig);

        farm = MiniChefV2(_farm);
        deadline = _deadline;
    }

    /* -------------------------------------------------------------------------- */
    /*                                  EXTERNAL                                  */
    /* -------------------------------------------------------------------------- */

    function finishRewards() external {
        if (block.timestamp < deadline) {
            revert TooEarly();
        }

        /// @notice set deadline to infinite
        farm.setDeadline(type(uint256).max);

        /// @notice set rewards to 0
        farm.setSushiPerSecond(0);
    }

    /* -------------------------------------------------------------------------- */
    /*                                  GOVERNOR                                  */
    /* -------------------------------------------------------------------------- */

    function add(uint256 allocPoint, IERC20 _lpToken, IRewarder _rewarder, uint256 _depositIncentives)
        public
        onlyGovernor
    {
        farm.add(allocPoint, _lpToken, _rewarder, _depositIncentives);
    }

    function set(uint256 _pid, uint256 _allocPoint, IRewarder _rewarder, bool overwrite) public onlyGovernor {
        farm.set(_pid, _allocPoint, _rewarder, overwrite);
    }

    function setSushiPerSecond(uint256 _sushiPerSecond) public onlyGovernor {
        farm.setSushiPerSecond(_sushiPerSecond);
    }

    function toggleIncentives() public onlyGovernor {
        farm.toggleIncentives();
    }

    function setDeadline(uint256 _deadline) public onlyGovernor {
        farm.setDeadline(_deadline);
        deadline = _deadline;
    }

    function setMigrator(IMigratorChef _migrator) public onlyGovernor {
        farm.setMigrator(_migrator);
    }

    function emergencyWithdraw(address _to, address[] memory _assets, bool _withdrawNative) external onlyGovernor {
        farm.emergencyWithdraw(_to, _assets, _withdrawNative);
    }

    function updatePoolIncentive(uint256 pid, uint256 _depositIncentives) external onlyGovernor {
        farm.updatePoolIncentive(pid, _depositIncentives);
    }

    function updateFarmGovernor(address _newGovernor) external onlyGovernor {
        Governable(address(farm)).updateGovernor(_newGovernor);
    }

    function addOperator(address _newOperator) external onlyGovernor {
        Operable(address(farm)).addOperator(_newOperator);
    }

    function removeOperator(address _operator) external onlyGovernor {
        Operable(address(farm)).removeOperator(_operator);
    }

    /* -------------------------------------------------------------------------- */
    /*                                  ERRORS                                    */
    /* -------------------------------------------------------------------------- */

    error TooEarly();
}
