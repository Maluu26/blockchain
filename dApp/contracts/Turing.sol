//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

// We import this library to be able to use console.log
import "hardhat/console.sol";


// This is the main building block for smart contracts.
contract Turing {
    // Some string type variables to identify the token.
    string public name = "Turing";
    string public symbol = "TUR";

    bool public voting;

    
    uint256 public totalSupply = 0;

    // An address type variable is used to store ethereum accounts.
    address public owner;

    // A mapping is a key/value map. Here we store each account balance.
    mapping(address => uint256) balances;

    mapping(address => uint256) public voteCount;

    mapping(string => mapping(string => bool)) public hasVote; 

    // The Transfer event helps off-chain aplications understand
    // what happens within your contract.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    mapping(string => address) public users;

    /**
     * Contract initialization.
     */
    constructor() {
        // The totalSupply is assigned to the transaction sender, which is the
        // account that is deploying the contract.
        users["roberta"] = 0x502542668aF09fa7aea52174b9965A7799343Df7;
        users["nome1"] =  0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        users["nome2"] = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        users["nome3"] = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
        users["nome4"] = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65;
        users["nome5"] = 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc;
        voting = true;
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }
    
    modifier onlyAdmin() {
        require(
            msg.sender == owner || msg.sender == users["roberta"],
            "Apenas o owner ou a professora podem executar esta funcao"
        );
        _;
    }

    

    function _getVoterCodename(address voter) internal view returns (string memory) {
        string[6] memory presetUsers = ["roberta", "nome1", "nome2", "nome3", "nome4", "nome5"];
        for (uint256 i = 0; i < presetUsers.length; i++) {
            if (users[presetUsers[i]] == voter) {
                return presetUsers[i];
            }
        }
        return "";
    }
    
    function updateUser(string memory codinome, address user_addr)public onlyAdmin{
        require(bytes(codinome).length >0, "Codinome nao pode ser vazio");
        users[codinome] = user_addr;
    }
    function votingOn()public onlyAdmin{
        voting = true ;
    }

    function votingOff()public onlyAdmin{
        voting = false ;
    }

    function vote(string memory codinomeCandidato, uint256 qtde_de_Turings)public{
        require(voting == true, "A votacao esta inativa");

        string memory codinomeEleitor = _getVoterCodename(msg.sender);
        require(bytes(codinomeEleitor).length > 0, "Apenas usuarios pre-autorizados podem votar");

        require(qtde_de_Turings > 0 && qtde_de_Turings <= 2, "Quantidade deve ser de 1 ou 2 Turings");

       
        address addrCandidato = users[codinomeCandidato];
        require(addrCandidato != address(0), "Candidato nao encontrado");

        require(msg.sender != addrCandidato, "Voce nao pode votar em si mesmo");
        require(!hasVote[codinomeEleitor][codinomeCandidato], "Voce ja votou neste codinome");
        
        hasVote[codinomeEleitor][codinomeCandidato] = true;
        totalSupply += qtde_de_Turings;
        balances[addrCandidato] += qtde_de_Turings;
        emit Transfer(address(0), addrCandidato, qtde_de_Turings);
        
        voteCount[msg.sender] += 1;
        if (voteCount[msg.sender] % 10 == 0) {
            totalSupply += 1;
            balances[msg.sender] += 1;
            emit Transfer(address(0), msg.sender, 1);
        }
    
    }
    function issueToken(string memory codinome ,uint256 qtde_de_Turings)public onlyAdmin{
        address recipient = users[codinome];
        require(recipient != address(0), "Usuario nao encontrado");
        require(qtde_de_Turings > 0, "Quantidade deve ser maior que zero");

    
        totalSupply += qtde_de_Turings;
        balances[recipient] += qtde_de_Turings;
        emit Transfer(address(0), recipient, qtde_de_Turings);
    }


    function transfer(address to, uint256 amount) external {
        // Check if the transaction sender has enough tokens.
        // If `require`'s first argument evaluates to `false` then the
        // transaction will revert.
        require(balances[msg.sender] >= amount, "Not enough tokens");

        // We can print messages and values using console.log, a feature of
        // Hardhat Network:
        console.log(
            "Transferring from %s to %s %s tokens",
            msg.sender,
            to,
            amount
        );

        // Transfer the amount.
        balances[msg.sender] -= amount;
        balances[to] += amount;

        // Notify off-chain applications of the transfer.
        emit Transfer(msg.sender, to, amount);
    }


    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}
