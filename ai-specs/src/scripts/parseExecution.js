const fs = require('fs');

const stdin = process.stdin;
let data = '';

stdin.on('data', (chunk) => (data += chunk));
stdin.on('end', () => {
  try {
    const json = JSON.parse(data);
    const events = json.events || [];

    const filtered = events.filter(
      (e) =>
        e.type.endsWith('StateEntered') ||
        e.type.endsWith('StateExited') ||
        e.type === 'TaskFailed'
    );

    for (const e of filtered) {
      const name =
        e.stateEnteredEventDetails?.name ||
        e.stateExitedEventDetails?.name ||
        'UnknownStep';

      const input = e.stateEnteredEventDetails?.input || '-';
      const output = e.stateExitedEventDetails?.output || '-';

      const status = e.type === 'TaskFailed' ? '❌ Failed' : '✅ Success';

      console.log(`🧩 Paso: ${name}`);
      console.log(`   Tipo: ${e.type}`);
      console.log(`   📥 Input: ${input}`);
      console.log(`   📤 Output: ${output}`);
      console.log(`   🟢 Estado: ${status}`);
      console.log('---');
    }
  } catch (err) {
    console.error('❌ Error procesando JSON:', err.message);
    process.exit(1);
  }
});
