import { Gpio, BinaryValue } from 'onoff';

// BCM pin 4 configured as an output line
const led: Gpio = new Gpio(516, 'out');

console.log('TypeScript GPIO container started. Blinking LED on BCM Pin 4...');

const iv: NodeJS.Timeout = setInterval(() => {
  // The result of the XOR operation is explicitly cast to a BinaryValue
  const nextState = (led.readSync() ^ 1) as BinaryValue;
  led.writeSync(nextState);
}, 200);

// Graceful cleanup on container termination
process.on('SIGINT', () => {
  clearInterval(iv);
  led.unexport();
  console.log('Cleaned up GPIO resources. Exiting.');
  process.exit(0);
});
