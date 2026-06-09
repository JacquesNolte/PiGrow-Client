import { Gpio } from 'onoff';

// BCM pin 4 configured as an output line
const led: Gpio = new Gpio(4, 'out'); 

console.log('TypeScript GPIO container started. Blinking LED on BCM Pin 4...');

const iv: NodeJS.Timeout = setInterval(() => {
  led.writeSync(led.readSync() ^ 1); 
}, 200);

// Graceful cleanup on container termination
process.on('SIGINT', () => {
  clearInterval(iv);
  led.unexport();
  console.log('Cleaned up GPIO resources. Exiting.');
  process.exit(0);
});
