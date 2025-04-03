declare module vsda {
	export class signer {
		sign(arg: string): string;
	}
	export class validator {
		createNewMessage(arg: string): string;
		validate(arg: string): 'ok' | 'error';
	}
}
//const vsda_location = '/usr/share/code/resources/app/node_modules.asar.unpacked/vsda/build/Release/vsda.node'; // Linux
const vsda_location = '/Applications/Visual Studio Code.app/Contents/Resources/app/node_modules/vsda/build/Release/vsda.node'; // macOS
const a: typeof vsda = require(vsda_location);
const signer: vsda.signer = new a.signer();
process.argv.forEach((value, index, array) => {
  if (index >= 2) {
    const r = signer.sign(value);
    console.log(r);
  }
});
