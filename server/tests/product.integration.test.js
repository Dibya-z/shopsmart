const request = require('supertest');
const app = require('../src/app');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

describe('Product API Integration Tests', () => {
  beforeAll(async () => {
    // Clear the database before tests
    await prisma.product.deleteMany();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('should create a new product', async () => {
    const res = await request(app)
      .post('/api/products')
      .send({
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99
      });
    
    expect(res.statusCode).toEqual(201);
    expect(res.body).toHaveProperty('id');
    expect(res.body.name).toBe('Test Product');
  });

  it('should fetch all products', async () => {
    const res = await request(app).get('/api/products');
    expect(res.statusCode).toEqual(200);
    expect(Array.isArray(res.body)).toBeTruthy();
    expect(res.body.length).toBeGreaterThan(0);
  });
});
