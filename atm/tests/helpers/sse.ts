import type { Page } from '@playwright/test';

/**
 * Sets up EventSource mocking for SSE testing.
 * Stubs the EventSource constructor to allow tests to inject messages.
 */
export async function setupSSEMock(page: Page) {
	await page.addInitScript(() => {
		let instance: MockEventSource | null = null;

		class MockEventSource extends EventTarget {
			readonly CONNECTING = 0 as const;
			readonly OPEN = 1 as const;
			readonly CLOSED = 2 as const;
			readonly url: string;
			readyState: number = this.CONNECTING;
			withCredentials = false;
			onopen: ((this: EventSource, ev: Event) => any) | null = null;
			onmessage: ((this: EventSource, ev: MessageEvent) => any) | null = null;
			onerror: ((this: EventSource, ev: Event) => any) | null = null;

			constructor(url: string | URL) {
				super();
				this.url = url.toString();
				instance = this;
				setTimeout(() => {
					this.readyState = this.OPEN;
					this.onopen?.call(this as any, new Event('open'));
				}, 0);
			}

			close() {
				this.readyState = this.CLOSED;
			}

			__simulateMessage(data: any) {
				if (this.readyState !== this.OPEN) return;
				const event = new MessageEvent('message', { data });
				this.onmessage?.call(this as any, event);
				this.dispatchEvent(event);
			}
		}

		(window as any).EventSource = MockEventSource;
		(window as any).__getMockEventSource = () => instance;
	});

	return {
		receiveEvent: async (type: string, data?: any) => {
			await page.evaluate(
				({ type, data }) => {
					(window as any).__getMockEventSource()?.__simulateMessage(
						JSON.stringify({ type, data })
					);
				},
				{ type, data }
			);
		}
	};
}
