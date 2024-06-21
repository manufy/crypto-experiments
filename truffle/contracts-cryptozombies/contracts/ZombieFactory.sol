// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;

import "./OpenZeppelin_Ownable.sol";
import "./safemath.sol";

contract ZombieFactory is Ownable {

    // Usamos SafeMath para evitar ataques de desbordamiento

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    /* 
        Las Variables de estado se guardan permanentemente en el almacenamiento 
        del contrato. Esto significa que se escriben en la cadena de bloques
        de Ethereum. Equivalente a escribir en una base de datos
    */

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits; // 10 elevado a dnaDigits.
    uint cooldownTime = 1 days;

    /* Si tienes varios uints dentro de una estructura, 
       usar un uint de tamaño reducido cuando sea posible permitirá
       a Solidity empaquetar estas variables para que ocupen menos espacio en memoria.
    */

    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount; // uint16 da para 1716 años de batallitas
        uint16 lossCount;
    }

    /* Para guardar el dueño de un zombi, vamos a usar dos mapeos: 
        el primero guardará el rastro de la dirección que posee ese zombi 
        y la otra guardará el rastro de cuantos zombis posee cada propietario.
    */

    mapping (uint => address) public zombieToOwner; // es publico para que otras aplicaciones puedan leerlo
    mapping (address => uint) ownerZombieCount; // es privado porque no necesitamos que otras aplicaciones lo lean

    /*
        Vamos a guardar un ejército de zombis en nuestra aplicación
        Y vamos a querer mostrar todos nuestros zombis a otras applicaciones, 
        así que lo queremos público para que otras aplicaciones puedan leerlo.
    */

    Zombie[] public zombies;

    /* 
        Los eventos son la forma en la que nuestro contrato comunica que algo sucedió
        en la cadena de bloques a la interfaz de usuario, el cual puede estar 'escuchando' ciertos eventos
        y hacer algo cuando sucedan, se lanza con emit y desde javascript se puede escuchar por ejemplo con 
        YourContract.IntegersAdded(function(error, result) {
        hacer algo con `result`
        })
    */

    /*
        Evento que se lanza cuando se crea un nuevo Zombie
    */

    event NewZombie(uint zombieId, string name, uint dna);


    /*
        Crea un nuevo Zombie y se añade al array zombies. Funcion privada.
        la convención es nombrar las funciones privadas empezando con una barra baja (_).
        Solidity también contiene funciones pure, 
        que significa que ni siquiera accedes a los datos de la aplicación
    */

    // now es en solidity < 0.6, ahora es block.timestamp

    function _createZombie(string memory _name, uint _dna) internal {
        zombies.push(Zombie(_name, _dna, 1, uint32(block.timestamp  + cooldownTime),0,0)); // en solidity < 0.6.0 push devolvia el nuevo tamaño del array, en varsiones mayores no devuelve nada
        uint id = zombies.length - 1;
       
        /*  Primero, después de recibir la id del nuevo zombi, 
            actualizamos nuestro mapeo zombieToOwner para que guarde msg.sender 
            bajo esa id.
        */


        /*  En Solidity, hay una serie de variables globales que están disponibles 
            para todas las funciones. Una de estas es msg.sender, 
            que hace referencia a la dirección (address) de la persona
            (o el contrato inteligente) que ha llamado a esa función.

            Nota: En Solidity, la ejecución de una función necesita empezar
            con una llamada exterior. Un contrato se sentará en la blockchain
            sin hacer nada esperando a que alguien llame a una de sus funciones.
            Así que siempre habrá un msg.sender.
            zombieToOwner[id] = msg.sender; // msg.sender es la dirección del propietario del contrato 
            ownerZombieCount[msg.sender]++; // Incrementa el contador de zombis del propietario       
        */ 

        zombieToOwner[id] = msg.sender; // msg.sender es la dirección del propietario del contrato  
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1); // Incrementa el contador de zombis del propietario 


        emit NewZombie(id, _name, _dna); // Lanza el evento NewZombie

    }

    /*
        view: significa que no se modificará el estado del contrato.
        La función keccak256 es una función hash criptográfica que toma un número arbitrario de bytes de entrada y devuelve una cadena de 32 bytes.
    */

    function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str))); // forzar el tipo como uint
        return rand % dnaModulus; // para asegurarnos de que el ADN tenga solo 16 dígitos % 10 ** dnaDigits
    }

    /*
        Función pública que toma un nombre y crea un Zombie con ese nombre y un ADN aleatorio.
    */

    /*  Vamos a usar require para asegurarnos que esta función solo pueda 
        ser ejecutada una vez por usuario, cuando vayan a crear a su primer zombi.
    */


    function createRandomZombie(string memory _name) public {

        //require(ownerZombieCount[msg.sender] == 0); // Solo puede crear un zombi si no tiene ninguno    

        uint randDna = _generateRandomDna(_name); // Genera un número aleatorio de 16 digitos
        _createZombie(_name, randDna); // Create a new Zombie without assigning a value
       
    }

  

}