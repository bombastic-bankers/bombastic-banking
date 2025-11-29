# Functional requirements: Bombastic Banking

This document specifies the functional requirements of Bombastic Banking.

- [1. User account creation](#1-user-account-creation)
- [2. User authentication](#2-user-authentication)
- [3. User account information](#3-user-account-information)
- [4. Touchless ATM sessions](#4-touchless-atm-sessions)
- [5. Withdrawal transactions](#5-withdrawal-transactions)
- [6. Deposit transactions](#6-deposit-transactions)
- [7. Direct transfer](#7-direct-transfer)
- [8. Voice commands](#8-voice-commands)
- [9. Transaction ledger](#9-transaction-ledger)

## 1. User account creation

The system must allow users to create accounts with their full name, email address, phone number and a six-digit PIN. The system must verify the user's email address and phone number before allowing account activation.

The system assumes one bank account per user.

## 2. User authentication

The system must authenticate users using either their email address and PIN, or their biometrics. Authenticated user sessions must expire after 2 minutes, requiring the user to re-authenticate.

## 3. User account information

The system must display to authenticated users their name, profile picture, account number, current account balance, and transaction history.

The system must allow users to update their name and profile picture.

## 4. Touchless ATM sessions

The system must allow authenticated users to establish a touchless ATM session by tapping their phone on an ATM's NFC tag.

During a touchless ATM session, the system must:

- Allow the user to configure and perform ATM transactions from their phone
- Prevent other users from interacting with the same ATM

The system must terminate a touchless ATM sessions when:
- The ATM transaction completes successfully
- The user explicitly exits the transaction flow before completion

Upon session termination, the ATM must return to its idle state, allowing any user to interact with it.

## 5. Withdrawal transactions

Once a touchless ATM session is established, the system must allow users to start a withdrawal.

The system must allow users to enter a withdrawal amount that is:
- In denominations of \$5
- No greater than the user's account balance
- Within the $2000/day withdrawal limit

Upon user confirmation of a withdrawal, the system must:
- Simulate dispensing the specified amount of cash with a 3s delay
- Instruct the user to collect their cash from the ATM's deposit slot
- Update the transaction ledger once cash is successfully dispensed

## 6. Deposit transactions

Once a touchless ATM session is established, the system must allow users to start a deposit.

The system must:

- Allow users to enter a simulated deposit amount by specifying per-denomination amounts, with the smallest denomination being \$0.10

- Simulate counting of the deposited cash with a 3s delay

If the counted deposit amount exceeds the $20,000/day deposit limit, the system must display an error message to the user and allow them to attempt another deposit. Otherwise, the system must display a per-denomination breakdown of the deposited cash.

Upon user confirmation of the counted deposit amount, the system must update the transaction ledger with the deposited amount

## 7. Direct transfer

The system must allow users to transfer money to other users by selecting the recipient from the phone's contact list, or by entering their phone number.

The system must allow users to enter a transfer amount that is no greater than their account balance.

After user confirmation of the transaction, the system must display the transaction's success or failure status.

## 8. Voice commands

The system must allow users to perform ATM withdrawals, ATM deposits, and direct transfers via voice commands.

- For ATM withdrawals, the system must allow users to say the withdrawal amount.
- For ATM deposits, the system must allow users to say instructions for initiating, counting and confirming the deposit. The system must verbally communicate the counted deposit amount.
- For direct deposits, the system must allow users to say the contact name or phone number of the recipient, the amount to transfer, and an optional note.

The system must confirm all transactions verbally before execution and provide audible feedback on success or failure.

## 9. Transaction ledger

The system must maintain a transaction ledger that records for each transaction:

- The user(s) involved
- The transaction amount
- The transaction timestamp
- The transaction type (ATM withdrawal / ATM deposit / direct transfer)
- A note optionally set by the sender

The ledger must be updated after each successful transaction.