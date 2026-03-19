const { createProduct, getAllProducts } = require('../src/controllers/product');
const { PrismaClient } = require('@prisma/client');

jest.mock('@prisma/client', () => {
  const mPrismaClient = {
    product: {
      findMany: jest.fn(),
      create: jest.fn()
    }
  };
  return { PrismaClient: jest.fn(() => mPrismaClient) };
});

const prisma = new PrismaClient();

describe('Product Controller Unit Tests', () => {
  let req, res;

  beforeEach(() => {
    req = { body: {} };
    res = {
      json: jest.fn(),
      status: jest.fn().mockReturnThis()
    };
    jest.clearAllMocks();
  });

  it('getAllProducts should return a list of products', async () => {
    const mockProducts = [{ id: 1, name: 'Prod1', price: 10 }];
    prisma.product.findMany.mockResolvedValue(mockProducts);

    await getAllProducts(req, res);

    expect(prisma.product.findMany).toHaveBeenCalledTimes(1);
    expect(res.json).toHaveBeenCalledWith(mockProducts);
  });

  it('createProduct should return 201 and the created product', async () => {
    req.body = { name: 'Prod2', price: 20 };
    const mockCreated = { id: 2, name: 'Prod2', price: 20, description: null };
    prisma.product.create.mockResolvedValue(mockCreated);

    await createProduct(req, res);

    expect(prisma.product.create).toHaveBeenCalledWith({
      data: { name: 'Prod2', description: null, price: 20 }
    });
    expect(res.status).toHaveBeenCalledWith(201);
    expect(res.json).toHaveBeenCalledWith(mockCreated);
  });
});
