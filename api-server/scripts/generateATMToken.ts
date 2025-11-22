import "dotenv/config";
import jwt from "jsonwebtoken";

const atmIdString = process.env.npm_config_id;
if (!atmIdString) {
  console.error("Provide ATM ID with --id=<atmId>");
  process.exit(1);
}
const atmId = +atmIdString;
if (isNaN(atmId)) {
  console.error("ATM ID must be a number");
  process.exit(1);
}

const jwtSecret = process.env.JWT_SECRET;
if (!jwtSecret) {
  console.error("JWT_SECRET environment variable must be set");
  process.exit(1);
}

const jwtIssuer = process.env.JWT_ISSUER;
if (!jwtIssuer) {
  console.error("JWT_ISSUER environment variable must be set");
  process.exit(1);
}

console.log(jwt.sign({ iss: jwtIssuer, sub: `atm|${atmId}` }, jwtSecret));
