export default function Home() {
  return (
    <div style={{ padding: '2rem', fontFamily: 'Arial, sans-serif' }}>
      <h1>ICPC Backend API</h1>
      <p>This is a Next.js API backend for the ICPC Flutter application.</p>
      <h2>Available Endpoints:</h2>
      <ul>
        <li><code>GET /api/health</code> - Health check endpoint</li>
      </ul>
      <p><strong>Base URL:</strong> <code>http://localhost:3000</code></p>
      <p><strong>For Flutter app:</strong> Use this URL as your API base URL</p>
    </div>
  )
}


