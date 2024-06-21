// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ZombieAttack.sol";
import "./IERC721.sol";
import "./safemath.sol";

/// @title Contrato para gestionar la propiedad de los zombies
/// @author mfy
/// @notice Este contrato implementa ERC721 y añade funcionalidades para transferir zombies
/// @dev Este contrato es una extensión de ZombieAttack y de IERC721

contract ZombieOwnership is ZombieAttack, IERC721 {

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    mapping (uint256 => address) zombieApprovals;

    function balanceOf(address _owner) external view override returns (uint256) {
        return ownerZombieCount[_owner];
    }

    function ownerOf(uint256 _tokenId) external view override returns (address) {
        return zombieToOwner[_tokenId];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable override {
        require(zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender, "Not authorized to transfer this token");
        require(zombieToOwner[_tokenId] == _from, "From address does not own this token");
        require(_to != address(0), "Cannot transfer to the zero address");

        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external payable override onlyOwnerOf(_tokenId) {
        require(zombieToOwner[_tokenId] == msg.sender, "Not authorized to approve");
        zombieApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
        zombieToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function transfer(address _to, uint256 _tokenId) external payable {
    // 2. Agrega la declaracion adecuada aqui
    // 3. Llama a _transfer
  }

}


