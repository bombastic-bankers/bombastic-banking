import jwt from 'jsonwebtoken';
import Ably from 'ably';
import { ATM_TOKEN, API_SERVER_URL } from '$env/static/private';

// TODO: Validation on this
const atmId = (jwt.decode(ATM_TOKEN) as jwt.JwtPayload).sub!;

export const channel = new Ably.Realtime({
	authUrl: `${API_SERVER_URL}/auth/ably`,
	authMethod: 'POST',
	authHeaders: { 'X-ATM-Token': ATM_TOKEN }
}).channels.get(`atm:${atmId}`);
