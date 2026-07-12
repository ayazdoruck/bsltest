import { DISCOVERY_UDP_PORT, TRANSFER_HTTP_PORT } from '@bslend/core';

function App(): React.JSX.Element {
  return (
    <div style={{ fontFamily: 'sans-serif', padding: 24 }}>
      <h1>Bslend (Faz 0 iskelet)</h1>
      <p>
        @bslend/core yuklendi: UDP {DISCOVERY_UDP_PORT} / HTTP {TRANSFER_HTTP_PORT}
      </p>
    </div>
  );
}

export default App;
