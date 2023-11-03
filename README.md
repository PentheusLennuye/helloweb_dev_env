# HelloWeb Development Environment

Builds, publishes and tags the HelloWeb Development Environment to ensure that
all HelloWeb builders (including automated ones) run off a common build
environment.

To build and publish:

```sh
VERSION=$(git describe --abbrev=0)  # tag without additional information
docker build -t docker.cummings-online.local/helloweb_dev_environment:$VERSION
```

To retag from rc to production

```sh
OLD_VERSION=<previous tag, i.e 1.2.3-rc2>
NEW_VERSION=<new tag, i.e. 1.2.3>
docker tag docker.cummings-online.local/helloweb_dev_environment:OLD_VERSION \
           docker.cummings-online.local/helloweb_dev_environment:NEW_VERSION

# If automating code, git tag -a <TAG> && git push --tag to main
```

Remember to advise developers (and automated builders) of the new development
environment!

