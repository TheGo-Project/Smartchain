package validatorregistry

import (
    "errors"
    "math/big"
    "strings"

    "github.com/ethereum/go-ethereum/accounts/abi"
    "github.com/ethereum/go-ethereum/common"
    "github.com/ethereum/go-ethereum/core/state"
    "github.com/ethereum/go-ethereum/rpc"
)

// ValidatorRegistry defines the contract structure
type ValidatorRegistry struct {
    address common.Address
    abi     abi.ABI
    stateDB *state.StateDB
}

// NewValidatorRegistry creates a new instance of ValidatorRegistry
func NewValidatorRegistry(address common.Address, stateDB *state.StateDB) (*ValidatorRegistry, error) {
    parsedABI, err := abi.JSON(strings.NewReader(validatorRegistryABI))
    if err != nil {
        return nil, err
    }
    return &ValidatorRegistry{
        address: address,
        abi:     parsedABI,
        stateDB: stateDB,
    }, nil
}

// IsValidator checks if an address is a registered validator
func (vr *ValidatorRegistry) IsValidator(callOpts *rpc.CallOpts, validator common.Address) (bool, error) {
    data, err := vr.abi.Pack("isValidator", validator)
    if err != nil {
        return false, err
    }

    res, err := vr.callContract(callOpts, data)
    if err != nil {
        return false, err
    }

    var isValidator bool
    err = vr.abi.UnpackIntoInterface(&isValidator, "isValidator", res)
    return isValidator, err
}

// GetValidatorBalance retrieves the token balance of a validator
func (vr *ValidatorRegistry) GetValidatorBalance(callOpts *rpc.CallOpts, validator common.Address) (*big.Int, error) {
    data, err := vr.abi.Pack("getValidatorBalance", validator)
    if err != nil {
        return nil, err
    }

    res, err := vr.callContract(callOpts, data)
    if err != nil {
        return nil, err
    }

    var balance *big.Int
    err = vr.abi.UnpackIntoInterface(&balance, "getValidatorBalance", res)
    return balance, err
}

// GetValidators retrieves the list of current validators
func (vr *ValidatorRegistry) GetValidators(callOpts *rpc.CallOpts) ([]common.Address, error) {
    data, err := vr.abi.Pack("getValidators")
    if err != nil {
        return nil, err
    }

    res, err := vr.callContract(callOpts, data)
    if err != nil {
        return nil, err
    }

    var validators []common.Address
    err = vr.abi.UnpackIntoInterface(&validators, "getValidators", res)
    return validators, err
}

// callContract simulates a call to the contract
func (vr *ValidatorRegistry) callContract(callOpts *rpc.CallOpts, data []byte) ([]byte, error) {
    msg := ethereum.CallMsg{
        To:   &vr.address,
        Data: data,
    }
    return vr.stateDB.CallContract(callOpts, msg)
}

// validatorRegistryABI is the ABI of the ValidatorRegistry contract
const validatorRegistryABI = `[{"constant":true,"inputs":[{"name":"validator","type":"address"}],"name":"isValidator","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"validator","type":"address"}],"name":"getValidatorBalance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"getValidators","outputs":[{"name":"","type":"address[]"}],"payable":false,"stateMutability":"view","type":"function"}]`
