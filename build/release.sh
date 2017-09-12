set -e

if [[ -z $1 ]]; then
  echo "Enter new version: "
  read VERSION
else
  VERSION=$1
fi

read -p "Releasing $VERSION $RELEASE_TAG - are you sure? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Releasing $VERSION ..."

  npm run test

  # build
  VERSION=$VERSION npm run build

  # update packages
  cd packages/docsify-server-renderer
  npm version $VERSION
  if [[ -z $RELEASE_TAG ]]; then
    npm publish
  else
    npm publish --tag $RELEASE_TAG
  fi
  cd -

  # commit
  git add -A
  git commit -m "[build] $VERSION $RELEASE_TAG"
  npm version $VERSION --message "[release] $VERSION $RELEASE_TAG"

  # publish
  git push origin refs/tags/v$VERSION
  git push
  if [[ -z $RELEASE_TAG ]]; then
    npm publish
  else
    npm publish --tag $RELEASE_TAG
  fi
fi
