let mockableFunctionBody = (~functionName, ~storageParameters, ~mockerParameterCalls) =>
  `
if(shouldUseMock && keccak256(abi.encodePacked(functionToNotMock)) != keccak256(abi.encodePacked("${functionName}"))){
  ${storageParameters}
  return mocker.${functionName}Mock(${mockerParameterCalls});
} else {
  return super.${functionName}(${mockerParameterCalls});
}
}
`
let externalMockerFunctionBody = (
  ~functionName,
  ~mockerArguments,
  ~mockerReturnValues,
  ~mockerReturn,
) =>
  `
  function ${functionName}Mock(${mockerArguments}) public pure ${mockerReturnValues}{
    return (${mockerReturn});
  }
`

let mockableModifierBody = (
  ~functionName,
  ~storageParameters,
  ~mockerParameterCalls,
  ~functionBody,
) =>
  `
if(shouldUseMock && keccak256(abi.encodePacked(functionToNotMock)) != keccak256(abi.encodePacked("${functionName}"))){
  ${storageParameters}
  mocker.${functionName}Mock(${mockerParameterCalls});
  _;
} else {
  ${functionBody}
}
}
`

let externalMockerModifierBody = (~functionName, ~mockerArguments) =>
  `
function ${functionName}Mock(${mockerArguments}) public pure {}
`

//TODO: the licence and the solidity verson should be a config variable!
let internalMockingFileTemplate = (~fileNameWithoutExtension, ~parentImports, ~contractBody) =>
  `// SPDX-License-Identifier: BUSL-1.1 \n pragma solidity 0.8.13;

import "./${fileNameWithoutExtension}Mockable.sol";
import "../${fileNameWithoutExtension}InternalStateSetters.sol";

${parentImports}

contract ${fileNameWithoutExtension}ForInternalMocking {
  ${contractBody}
}`

let constructor = (~paramsWithTypes, ~params, ~fileNameWithoutExtension) =>
  `constructor(${paramsWithTypes}) ${fileNameWithoutExtension}InternalStateSetters(${params}) {}`

let mockingFileTemplate = (~prefix, ~fileNameWithoutExtension, ~fullBody, ~constructor) => {
  `${prefix}
import "./${fileNameWithoutExtension}ForInternalMocking.sol";
import "../${fileNameWithoutExtension}InternalStateSetters.sol";

contract ${fileNameWithoutExtension}Mockable is ${fileNameWithoutExtension}InternalStateSetters {

  ${fileNameWithoutExtension}ForInternalMocking mocker;
  bool shouldUseMock;
  string functionToNotMock;

  ${constructor}

  function setMocker(${fileNameWithoutExtension}ForInternalMocking _mocker) external {
    mocker = _mocker;
  }

  function disableMocker() external {
    shouldUseMock = false;
  }

  function setFunctionToNotMock(string calldata _functionToNotMock) external {
    functionToNotMock = _functionToNotMock;
    shouldUseMock = true;
  }

${fullBody}
}
`
}
