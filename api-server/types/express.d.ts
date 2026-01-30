declare namespace Express {
  export interface Request {
    userId: number;
    userVerified: boolean;
    atmId: number;
  }
}
