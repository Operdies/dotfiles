#/bin/bash
# Builds the vsdbgsign.ts file

npm i --save-dev @types/node
npm i -D typescript
npx tsc vsdbgsign.ts
