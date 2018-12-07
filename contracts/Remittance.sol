
pragma solidity ^0.4.24;

import "./Owned.sol";

contract Remittance is Owned {

	struct Payment {
        address recipient;
		uint deadline;
		uint amount;
	}
	
	mapping (bytes32 => Payment) paymentDetails;

    event LogPaymentAndSecretRegistration(bytes32 indexed hashedPasswords, address indexed payee, uint amount, uint limitInMinutes, uint currentTime);
    event LogWithdrawalByPayee(address indexed payee, bytes32 indexed hashedPasswords, uint amount, uint currentTime);
    event LogWithdrawalByOwner(address indexed currentOwner, bytes32 indexed secretForPayment, uint amount);

	constructor() public {

	}

    // register client payment
    // owner generates + hash OTPs and store them outside of contract in advance
	function registerPaymentWithSecret(bytes32 hashedPasswords, address payee, uint limitInMinutes) public onlyOwner payable {
		require(payee != 0);
		require(msg.value > 0);
		require(limitInMinutes > 0);

		bytes32 commonSecret = keccak256(abi.encodePacked(hashedPasswords, payee));
        Payment storage payment = paymentDetails[commonSecret];
        require(payment.recipient == 0);

		paymentDetails[commonSecret] = Payment(payee,now + limitInMinutes * 1 minutes, msg.value);
		emit LogPaymentAndSecretRegistration(hashedPasswords, payee, msg.value, limitInMinutes, now);
	}
	
	// for payee to withdraw money in case of successful verification
	function withdraw(bytes32 hashedPasswords) public {
	    bytes32 inputSecret = keccak256(abi.encodePacked(hashedPasswords, msg.sender));
	    Payment storage payment = paymentDetails[inputSecret];

	    require(now <= payment.deadline);
	    uint amount = payment.amount;
	    require(amount > 0);

	    payment.amount = 0;
	    payment.deadline = 0;
	    msg.sender.transfer(amount);
	    emit LogWithdrawalByPayee(msg.sender, hashedPasswords, amount, now);
	}
	
	// for owner of contract (e.g., in case of overdue payments)
	// owner knows all hashed passwords and relevant address thus can directly use secret as mpping key
	function withdrawByOwner(bytes32 secret) public onlyOwner{
	    Payment storage payment = paymentDetails[secret];
	    uint amount = payment.amount;
	    require(amount > 0);
	    payment.amount = 0;
	    payment.deadline = 0;
	    msg.sender.transfer(amount);
	    emit LogWithdrawalByOwner(msg.sender, secret, amount);
	}
}