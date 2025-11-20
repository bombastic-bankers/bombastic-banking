import jwt from 'jsonwebtoken';
import Ably from 'ably';
import { ATM_TOKEN, API_SERVER_URL } from '$env/static/private';

const atmId = (jwt.decode(ATM_TOKEN) as jwt.JwtPayload).sub!;
console.log(`using ${API_SERVER_URL}/auth/ably as url`);
export const realtime = new Ably.Realtime({
	authUrl: `${API_SERVER_URL}/auth/ably`,
	authHeaders: { 'X-ATM-Token': ATM_TOKEN }
});
export const channel = realtime.channels.get(`atm:${atmId}`);
