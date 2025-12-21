/**
 * Thrown when attempting to create a user with an email that already exists.
 */
export class EmailAlreadyExistsError extends Error {
  constructor(email: string) {
    super(`Email already in use: ${email}`);
    this.name = "EmailAlreadyExistsError";
  }
}

/**
 * Thrown when attempting to create a user with a phone number that already exists.
 */
export class PhoneNumberAlreadyExistsError extends Error {
  constructor(phoneNumber: string) {
    super(`Phone number already in use: ${phoneNumber}`);
    this.name = "PhoneNumberAlreadyExistsError";
  }
}
