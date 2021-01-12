# chrispearce.co

Personal site of [Chris Pearce](https://chrispearce.co), Software Engineering & Product.

# Install (for development)

`npm install -g cssnano-cli html-minifier-terser tinypng-cli autoprefixer-cli`

# Develop

`npx http-server` in the `/src` folder

Manually refresh on changes... I know?!

# Build

As we're just using github pages we build into the `docs/` folder for distribution. Pushes to `master` branch publish a new version.

Building is currently just very basic minification.

Run `./build.sh`!
