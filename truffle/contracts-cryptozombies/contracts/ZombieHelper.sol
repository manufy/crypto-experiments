// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.19;

import "./ZombieFeeding.sol"; // importamos el contrato ZombieFactory.sol


contract ZombieHelper is ZombieFeeding {

    // lo que hay que pagar para subir de nivel un zombie

    uint levelUpFee = 0.001 ether;

    /* modifier que utilice la propiedad level del zombi para
        restringir el acceso a las habilidades especiales
    */

    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }

    // función que permita al usuario cambiar el nombre de su zombi
    // solo si el zombi es de nivel 2 o superior
    // usa el modifier ownerOf para verificar que el usuario sea el dueño del zombi

    function changeName(uint _zombieId, string memory _newName) public aboveLevel(2, _zombieId)  onlyOwnerOf(_zombieId) {
        // require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].name = _newName;
    }

    // función que permita al usuario cambiar el ADN de su zombi
    // solo si el zombi es de nivel 20 o superior
    // usa el modifier ownerOf para verificar que el usuario sea el dueño del zombi

    function changeDna(uint _zombieId, uint _newDna) public aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId){
        // require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].dna = _newDna;
    }

    // Las funciones view no cuestan gas cuando son llamadas externamente por un usuario.
    // Solo se pueden leer datos y no se pueden modificar el estado del contrato.
    // puedes optimizar el uso de gas de tu DApp haciendo que tus usuarios utilicen funciones external view siempre que sea posible.

    // devuelve el ejercito de un usuario
    // storage cuesta gas asi que se usa memory

    // con esto nuestra función de transferencia será mucho más barata, 
    // ya que no necesitamos reordenar ningún array en storage,
    // y porque este enfoque ligeramente contraintuitivo es integramente más barato.

    function getZombiesByOwner(address _owner) external view returns (uint[] memory) {
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < zombies.length; i++) {
            if (zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        // la función ahora devolverá todos los zombis del usuario _owner sin gastar nada de gas.
        return result;
    }

    /* Digamos que nuestro juego tiene una función donde los usuarios pueden pagar
       ETH para subir el nivel de sus zombie en 1.
    */

    /* La función levelUpToOwner() es una función de pago, 
        y el usuario debe enviar un mínimo de 0.001 ETH para subir de nivel a su zombi.
    */  

    function levelUp(uint _zombieId) external payable {
        require(msg.value >= levelUpFee);
        zombies[_zombieId].level++;
    }

    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }

    function withdraw() external onlyOwner {
        address _owner = owner();
        payable(_owner).transfer(address(this).balance);
    }





}