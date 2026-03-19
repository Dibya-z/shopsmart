import { render, screen } from '@testing-library/react';
import App from './App';
import { describe, it, expect, vi } from 'vitest';

describe('App', () => {
    it('renders ShopSmart title & functional components', () => {
        global.fetch = vi.fn((url) => {
            if (url.includes('/api/health')) {
                return Promise.resolve({
                    json: () => Promise.resolve({ status: 'ok' })
                });
            }
            if (url.includes('/api/products')) {
                return Promise.resolve({
                    json: () => Promise.resolve([{ id: 1, name: 'Test Product', price: 10 }])
                });
            }
            return Promise.reject(new Error('Not Found'));
        });

        render(<App />);
        const titleElement = screen.getByText(/ShopSmart/i);
        expect(titleElement).toBeInTheDocument();
    });
});
