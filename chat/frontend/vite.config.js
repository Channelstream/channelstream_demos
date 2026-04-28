// Vite build config for the channelstream chat demo frontend.
//
// Pyramid serves the bundled file via a Jinja template that hard-codes the
// filename `channelstream-demo.js`, so we use Rollup output options to emit
// exactly that filename to either FRONTEND_ASSSET_ROOT_DIR (set in Docker)
// or the local ../static directory during development.

import {defineConfig} from 'vite';
import path from 'node:path';

// Resolve the output directory: prefer the env var used by the Docker build,
// otherwise fall back to the sibling chat/static directory checked into the
// repo. This mirrors the previous webpack behaviour exactly.
const outDir =
    process.env.FRONTEND_ASSSET_ROOT_DIR ||
    path.resolve(__dirname, '../static');

export default defineConfig({
    // Emit a stable, predictable bundle name that matches what the Pyramid
    // template loads. We use `build.rollupOptions` (not `build.lib`) so that
    // dynamic imports are inlined into a single self-executing bundle, which
    // matches the previous single-file webpack output.
    build: {
        outDir,
        // Don't wipe sibling files in chat/static when building.
        emptyOutDir: false,
        // Browsers we care about all support modern ES features; skipping the
        // Babel/legacy step keeps build times small.
        target: 'es2020',
        // Disable module preload helper injection — we ship a single file.
        modulePreload: false,
        rollupOptions: {
            input: path.resolve(
                __dirname,
                'src/channelstream-demo/index.js'
            ),
            output: {
                format: 'iife',
                entryFileNames: 'channelstream-demo.js',
                // Keep any code-split or asset filenames stable too, in case
                // a future change introduces them.
                chunkFileNames: 'channelstream-demo-[name].js',
                assetFileNames: 'channelstream-demo-[name][extname]',
                inlineDynamicImports: true,
            },
        },
    },
});
