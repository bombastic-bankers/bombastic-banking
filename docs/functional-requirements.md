# Functional requirements: Bombastic Banking

This document specifies the functional requirements of Bombastic Banking.

- [1. User account management](#1-user-account-management)
- [2. User authentication](#2-user-authentication)
- [3. Account information display](#3-account-information-display)
- [4. Touchless session management](#4-touchless-session-management)
- [5. Withdrawal transactions](#5-withdrawal-transactions)
- [6. Deposit transactions](#6-deposit-transactions)
- [7. ATM display requirements](#7-atm-display-requirements)
- [8. Transaction ledger](#8-transaction-ledger)

## 1. User account management

The system must allow users to create accounts with their email address and password. User credentials must be validated and securely stored.

## 2. User authentication

The system must authenticate users using either their email address and password, or their biometrics. Upon successful authentication, the system must issue a session token that expires after 2 minutes.

## 3. Account information display

The system must display to authenticated users:
- Their name
- Their account number
- Their current account balance

The system assumes one bank account per user.

## 4. Touchless ATM session management

The system must support touchless ATM sessions, which link an authenticated mobile user to a specific ATM.

The system must allow users to establish a touchless session by reading an ATM's unique identifier from its NFC tag.

During a touchless ATM session:
- The ATM must indicate that a touchless ATM session is in progress
- The ATM must prevent direct ATM interaction
- The user must be able to initiate ATM transactions from their mobile device

The system must terminate touchless ATM sessions when:
- An ATM transaction completes successfully
- The user explicitly exits the transaction flow before completion

Upon session termination, the ATM must return to its idle state, allowing for direct ATM interaction.

## 5. Withdrawal transactions

Once a touchless ATM session is established, the system must allow users to initiate withdrawal transactions.

The system must allow users to enter a withdrawal amount, with input validation for:
- Currency increments
- Account balance limits
- Bank-imposed limits

Upon user confirmation of a withdrawal, the system must:
- Command the ATM to dispense the specified amount of cash
- Display a message on the ATM indicating the amount being dispensed
- Instruct the user to collect cash from the cash tray
- Update the transaction ledger after cash is dispensed
- Communicate transaction success or failure to the user

For the prototype, cash dispensing is simulated with a 3-second delay.

## 6. Deposit transactions

Once a touchless session is established, the system must allow users to initiate deposit transactions.

Upon user selection of a deposit transaction, the system must:
- Command the ATM to prepare to receive a cash deposit
- Instruct the user to enter the deposit amount manually (for the prototype)

Upon user confirmation to proceed with the deposit, the system must:
- Command the ATM to receive and count the deposited cash
- Display a message on the ATM indicating cash is being counted
- Display the total amount counted
- Update the transaction ledger with the deposited amount
- Communicate transaction success or failure to the user

For the prototype, cash counting is simulated with a 3-second delay.

## 7. ATM display requirements

The ATM display must show:
- An idle screen when no touchless session is active
- A prompt to refer to the mobile device during an active touchless session
- Transaction-specific status messages (e.g., "withdrawing $100" or "$50 deposited")
- Instructions for collecting withdrawn cash or depositing cash

## 8. Transaction ledger

The system must maintain a transaction ledger that records for each transaction:
- The user involved
- The ATM used
- The transaction amount
- The transaction timestamp

The ledger must be updated after each successful withdrawal or deposit transaction.