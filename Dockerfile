FROM node:10 as build

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y \
        yarn \
    && rm -rf /var/lib/apt/lists/*

COPY package.json .
COPY packages/peregrine/package.json ./packages/peregrine/package.json
COPY packages/pwa-buildpack/package.json ./packages/pwa-buildpack/package.json
COPY packages/upward-js/package.json ./packages/upward-js/package.json
COPY packages/upward-spec/package.json ./packages/upward-spec/package.json
COPY packages/venia-concept/package.json ./packages/venia-concept/package.json
RUN yarn install

COPY babel.config.js browserslist.js ./
COPY packages ./packages

RUN cd packages/venia-concept/ && \
    cp .env.dist .env && \
    sed -i 's/#   UPWARD_JS_PORT=8008/UPWARD_JS_PORT=8008/' .env

RUN yarn run build


FROM node:10-alpine

WORKDIR /usr/src/app
COPY --from=build /usr/src/app /usr/src/app

ENV PORT 8008
EXPOSE 8008

CMD [ "yarn", "run", "stage:venia" ]
