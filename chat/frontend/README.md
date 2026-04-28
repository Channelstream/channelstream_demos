# Channelstream chat demo — frontend

LitElement-based web components bundled with [Vite](https://vitejs.dev/).
The build emits a single self-executing bundle to
`../static/channelstream-demo.js`, which the Pyramid app serves at
`/static/channelstream-demo.js` (see `chat/templates/demo.jinja2`).

## Layout

    src/channelstream-demo/
        index.js                  # entry point
        polyfills.js
        channelstream-chat-demo/  # top-level chat component
        app-views/                # admin + chat views
        chat-avatar/              # avatar component (gravatar wrapper)
        redux/                    # store + reducers (app, chat_view, server_info, ...)

## Local development

Requires Node 18+.

    npm install        # only on first run, or after package.json changes
    npm run dev        # `vite build --watch` — rebuilds chat/static/channelstream-demo.js on every save

`npm run dev` does **not** start a Vite dev server — the Pyramid app serves
the bundle off disk. Just refresh the browser to pick up changes.

For a one-off production build:

    npm run build

The output dir can be overridden with `FRONTEND_ASSSET_ROOT_DIR` (used by
the Docker build to point at the image's static dir).

## Adding dependencies

    npm install <package>

`package-lock.json` will be created/updated; commit it.

## Docker development

The repo's `docker-compose.dev.yml` overlay runs this directory in a
container with `npm run dev`, bind-mounting the host `chat/` so source
edits trigger rebuilds:

    docker compose -f docker-compose.yml -f docker-compose.dev.yml up

See the top-level `README.md` for full Docker instructions.
