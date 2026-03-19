import { useState, useEffect } from 'react';
import './index.css';

// Functional Component for Individual Product
const ProductItem = ({ product }) => (
  <div className="product-card">
    <h3>{product.name}</h3>
    <p>{product.description}</p>
    <p className="price">${product.price.toFixed(2)}</p>
  </div>
);

// Functional Component for adding a product
const AddProductForm = ({ onProductAdded }) => {
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [price, setPrice] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!name || !price) return;

    const apiUrl = import.meta.env.VITE_API_URL || '';
    try {
      const res = await fetch(`${apiUrl}/api/products`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ name, description, price: parseFloat(price) }),
      });
      if (res.ok) {
        const newProduct = await res.json();
        onProductAdded(newProduct);
        setName('');
        setDescription('');
        setPrice('');
      }
    } catch (err) {
      console.error('Failed to add product', err);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="add-product-form">
      <h2>Add New Product</h2>
      <input 
        type="text" 
        placeholder="Product Name" 
        value={name} 
        onChange={(e) => setName(e.target.value)} 
        required 
      />
      <input 
        type="text" 
        placeholder="Description" 
        value={description} 
        onChange={(e) => setDescription(e.target.value)} 
      />
      <input 
        type="number" 
        placeholder="Price" 
        value={price} 
        onChange={(e) => setPrice(e.target.value)} 
        required 
        step="0.01" 
      />
      <button type="submit">Add Product</button>
    </form>
  );
};

function App() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [healthStatus, setHealthStatus] = useState(null);

  useEffect(() => {
    const apiUrl = import.meta.env.VITE_API_URL || '';
    
    // Check backend health
    fetch(`${apiUrl}/api/health`)
      .then(res => res.json())
      .then(data => setHealthStatus(data.status))
      .catch(err => console.error('Error fetching health check:', err));

    // Fetch products
    fetch(`${apiUrl}/api/products`)
      .then(res => res.json())
      .then(data => {
        setProducts(data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Error fetching products:', err);
        setLoading(false);
      });
  }, []);

  const handleProductAdded = (newProduct) => {
    setProducts([...products, newProduct]);
  };

  return (
    <div className="container">
      <header className="header">
        <h1>ShopSmart</h1>
        {healthStatus && <span className={`status-badge ${healthStatus}`}>API: {healthStatus}</span>}
      </header>
      
      <main className="main-content">
        <AddProductForm onProductAdded={handleProductAdded} />
        
        <h2>Product Catalog</h2>
        {loading ? (
          <p>Loading products...</p>
        ) : products.length > 0 ? (
          <div className="product-grid">
            {products.map(product => (
              <ProductItem key={product.id} product={product} />
            ))}
          </div>
        ) : (
          <p>No products available. Add one above!</p>
        )}
      </main>
    </div>
  );
}

export default App;
