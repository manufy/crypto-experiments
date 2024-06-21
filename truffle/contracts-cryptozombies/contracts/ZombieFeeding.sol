// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19; 

import "./ZombieFactory.sol"; // importamos el contrato ZombieFactory.sol

/* En Solidity, puedes definir una interfaz que actúe como un contrato 
    "virtual" definiendo los métodos que deben ser implementados por un contrato 
    que cumpla con esta interfaz. 
    En este caso, estamos definiendo una interfaz KittyInterface que tiene un 
    método getKitty que devuelve varios valores de un gato de CryptoKitties. 
    No necesitamos definir la lógica de este método aquí, solo necesitamos 
    definir la firma de la función (es decir, el nombre de la función y los 
    tipos de argumentos que toma y devuelve).
*/

/* En solidity <0.6 no se necesita abstract ni virtual */

abstract contract KittyInterface { 
  function getKitty(uint256 _id) external view virtual returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}



/*  Storage se refiere a las variables guardadas permanentemente
    en la blockchain. Las variables de tipo memory son temporales, 
    y son borradas en lo que una función externa llama a tu contrato. 
    Piensa que es como el disco duro vs la RAM de tu ordenador.
*/

/*  Las variables de estado (variables declaradas fuera de las funciones) 
    son por defecto del tipo storage y son guardadas permanentemente en
    la blockchain, mientras que las variables declaradas dentro de las funciones
    son por defecto del tipo memory y desaparecerán una vez la llamada a la 
    función haya terminado.
*/


contract ZombieFeeding is ZombieFactory {

    // no es buena practica setear el ckAddress en el contrato por si este cambia en el futuro
    // por eso se crea la funcion setKittyContractAddress
    // address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d; // Inicializa kittyContract aquí usando el `ckAddress` de arriba
    
    KittyInterface kittyContract; // = KittyInterface(ckAddress);

    // onlyOwner es un modificador que solo permite que el propietario del contrato ejecute la función
    // se hereda de OpenZeppelin_Ownable.sol

    // el codigo de onlyOwner es un modificador, y se ejecutaría antes de la función a la que se le aplica

    function setKittyContractAddress(address _address) external  onlyOwner {
        kittyContract = KittyInterface(_address);
    }
    
    /*  en Solidity 0.5.0 y versiones posteriores,
        los parámetros de tipo string, arrays y structs deben especificar
        explícitamente su ubicación de datos (memory o calldata)
    */

    /*  Alimentarse activa el enfriamiento del zombi, 
        y solo el propietario del zombi puede alimentarlo. 
        Los zombis no podrán alimentarse de gatitos hasta que su 
        periodo de enfriamiento haya concluido
    */

    /*  Si nos damos cuenta, esta función solo necesita ser llamada por feedOnKitty(),
        así que la manera más fácil de prevenir estos problemas es hacer 
        la función internal.
    */

    /* ownerOf es un modificador que solo permite que el propietario
       del zombi ejecute la función, esta defido al final del contrato 
    */

    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal onlyOwnerOf(_zombieId){
        // no es necesatio esto porque se usa el modifier ownerOf
        // require(msg.sender == zombieToOwner[_zombieId]); // solo el dueño del zombi puede llamar a esta función
        
        Zombie storage myZombie = zombies[_zombieId]; // almacenamos el zombi en la memoria
        
        //  el usuario solo podrá ejecutar esta función si el enfriamiento del zombi ha terminado.

        require (_isReady(myZombie)); // solo puede alimentarse si está listo   
        
        _targetDna = _targetDna % dnaModulus; // nos aseguramos de que _targetDna no sea mayor que dnaModulus
        uint newDna = (myZombie.dna + uint(_targetDna)) / 2;


        /*  compara los hashes keccak256 de _species y el string "kitty".
            Dentro de la sentencia if, queremos reemplazar los últimos 2 dígitos 
            del ADN con 99. Una manera de hacer esto es usando la lógica:
            newDna = newDna - newDna % 100 + 99;.
            Pongamos que newDna es 334455. Entonces newDna % 100 es 55,
            así quenewDna - newDna % 100 es 334400. Finalmente añadimos 99 
            para conseguir 334499.
        */

        if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
            newDna = newDna - newDna % 100 + 99;
        }

        _createZombie("NoName", newDna);

        _triggerCooldown(myZombie); // activa el enfriamiento del zombi
    }

    /*  Vamos a hacer una función que recoga los genes del gato del contrato
        (kittyContract) y los use para crear un nuevo zombi.
    */

    /*  Vamos a hacer que los zombis creados a partir de gatos tengan una 
        única característica que muestre que son gato-zombis.
        Para hacer esto, debemos añadir algo de código del gato en el ADN del zombi.
        Estamos solo usando los primeros 12 dígitos de los 16 dígitos que determinan
        el ADN de la apariencia de un zombi.
        Así que vamos a usar los últimos 2 dígitos para manejar esas características
        "especiales". Diremos que los gato-zombis tienen 99 en los últimos dos dígitos 
        de su ADN (debido a que tienen 9 vidas). Entonces en nuestro código, 
        diremos que si (if) un zombi viene de un gato, los últimos dos dígitos 
        de su ADN serán 99.
    */

    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId); // Almacenamos el ADN del gato en kittyDna
        feedAndMultiply(_zombieId, kittyDna, "kitty"); // Creamos un nuevo zombi con el ADN del gato
    }   

    /* Puedes pasar un puntero storage a una estructura 
       como argumento a una función private o internal. Esto es práctico, 
       por ejemplo, para pasar entre funciones la estructura de nuestro Zombie.
    */

    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(block.timestamp + cooldownTime);
    }   

    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.readyTime <= block.timestamp);
    }

    /* el modificador ownerOf solo permite
     que el propietario del zombi ejecute la función */

    modifier onlyOwnerOf(uint _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]);
    _;
  }

}