pre_build() {
  local next_version=$1

  echo $1
  echo "::set-output name=next-version::$next_version"
}

pre_build