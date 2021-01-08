# INVOKE
#
# @author      Sam Craig <sam@talisman.dev>
# @link        https://github.com/talismanco/talismanpkgs
# ------------------------------------------------------------------------------


from invoke import Collection, task

import dotenv
import os
import pathlib
import platform
import subprocess
import sys

from scripts.python import strings as sstrings

# Get the current working directory for the root of the project.
rootdir = pathlib.Path.cwd()

# Cross compilation targets for build outputs.
cctargets = [("darwin", "386"), ("darwin", "amd64"), ("freebsd", "386"), ("freebsd", "amd64"), ("freebsd", "arm"), ("linux", "386"),
             ("linux", "amd64"), ("linux", "arm"), ("openbsd", "386"), ("openbsd", "amd64"), ("windows", "386"), ("windows", "amd64")]

# === SETUP ===


@task()
def __clean(context):
    """
    Remove all generated configuration artifacts
    """
    context.run(
        "find . -type f -name '.env.*' -o -name '*.env' | xargs rm -f")


@task(pre=[__clean])
def __setup(context, stage="development"):
    context.run(f'python ./scripts/python/setup.py {rootdir} {stage}')

    # Instantiate the environment variables in `.env`
    # and `.tool-versions.env` via `dotenv`.
    dotenv.load_dotenv(".env")
    dotenv.load_dotenv(".tool-versions.env")

    # Set the project commit hash.
    os.environ["PROJECT_COMMIT"] = sstrings.normalize(subprocess.check_output(
        ["git", "rev-parse", "HEAD"]))

    # Set the current operating system & CPU architecture of the current
    # developmentenvironment
    os.environ["PROJECT_SYSTEM"] = platform.system().lower()
    os.environ["PROJECT_ARCH"] = platform.machine().lower()


@task(pre=[__setup], aliases=["i"])
def init(context):
    """
    Initialize the development environment
    """
    # Install python build dependencies.
    context.run("pip install -r requirements.txt")

    # Install npm build dependencies.
    context.run("npm install")


# === BUILD ===

@task(pre=[__setup], default=True, name="self", aliases=["s"])
def build_self(context, docker=False, static="static", arch="amd64"):
    """
    Compile the application according to the local development
    environment.
    """
    commit = os.getenv("PROJECT_COMMIT")
    project = os.getenv("PROJECT_NAME")
    system = os.getenv("PROJECT_SYSTEM")
    version = os.getenv("PROJECT_VERSION")

    golang = os.getenv("GOLANG_VERSION")

    if docker:
        # Execute the `./docker/build.dockerfile` and pass
        # necessary build arguments.
        context.run(f'docker build \
            --file ./docker/build.dockerfile \
            --tag {project} \
            --build-arg ARCH={arch} \
            --build-arg COMMIT={commit} \
            --build-arg GOLANG_VERSION={golang} \
            --build-arg OS={system} \
            --build-arg PROJECT={project} \
            --build-arg STATIC_FLAG={static} \
            .')

        # Create a container with a the above image and record
        # its id.
        image = f'{project}:latest'
        container = sstrings.normalize(
            subprocess.check_output(["docker", "create", image]))

        # Copy the contents of the build from the container to
        # the local build directory, and then delete the container
        context.run(
            f'docker cp {container}:/app/build/bin/{project} ./build/bin/{project}')
        context.run(f'docker rm --volumes {container}')
    else:
        os.environ["GO111MODULE"] = "on"
        os.environ["CGO_ENABLED"] = "0"

        # Build the executable with the native `go build` command
        context.run(f'go build \
            -ldflags \'-extldflags "-fno-PIC {static}" -w -s -X release.version={version} -X release.commit={commit}\'  \
            -mod=readonly \
            -v -o ./build/bin/{project} ./cmd/{project}')


@task(pre=[__setup], name="cross", aliases=["c"])
def build_cross(context, docker=False, static="static"):
    """
    Cross-compile the application for several platforms
    """
    commit = os.getenv("PROJECT_COMMIT")
    project = os.getenv("PROJECT_NAME")
    version = os.getenv("PROJECT_VERSION")

    golang = os.getenv("GOLANG_VERSION")

    for system, arch in cctargets:
        # Establish the output directory for the current
        # build target.
        targetdir = f'./build/dist/{system}/{arch}'

        # Create the `targetdir` if it doesn't exist.
        pathlib.Path(targetdir).mkdir(parents=True, exist_ok=True)
        
        if docker:
            # Execute the `./docker/build.dockerfile` and pass
            # necessary build arguments.
            context.run(f'docker build \
                --file ./docker/build.dockerfile \
                --tag {project} \
                --build-arg ARCH={arch} \
                --build-arg COMMIT={commit} \
                --build-arg GOLANG_VERSION={golang} \
                --build-arg OS={system} \
                --build-arg PROJECT={project} \
                --build-arg STATIC_FLAG={static} \
                .')

            # Create a container with a the above image and record
            # its id.
            image = f'{project}:latest'
            container = sstrings.normalize(
                subprocess.check_output(["docker", "create", image]))

            # Copy the contents of the build from the container to
            # the local build directory, and then delete the container
            context.run(
                f'docker cp {container}:/app/build/bin/{project} {targetdir}/{project}')
            context.run(f'docker rm --volumes {container}')
        else:
            os.environ["GO111MODULE"] = "on"
            os.environ["CGO_ENABLED"] = "0"
            os.environ["GOOS"] = system
            os.environ["GOARCH"] = arch

            # Build the executable with the native `go build` command
            context.run(f'go build \
                -ldflags \'-extldflags "-fno-PIC {static}" -w -s -X release.version={version} -X release.commit={commit}\' \
                -mod=readonly \
                -v -o {targetdir}/{project} ./cmd/{project}')


build = Collection("build")
build.add_task(build_self)
build.add_task(build_cross)


# === CLEAN ===

@task(default=True, name="all")
def clean_all(context):
    """
    Run all `clean` tasks
    """
    clean_builds(context)
    clean_deps(context)


@task(name="builds", aliases=["b"])
def clean_builds(context):
    """
    Remove all build artifacts
    """
    context.run("rm -rf ./build/bin/*")
    context.run("rm -rf ./build/dist/*")


@task(name="deps", aliases=["d"])
def clean_deps(context):
    """
    Remove all dependency artifacts
    """
    context.run("rm -rf ./vendor/*")


clean = Collection("clean", clean_all)
clean.add_task(clean_builds)
clean.add_task(clean_deps)


# === RUN ===

@task(pre=[__setup], aliases=["r"])
def run(context, build=False, docker=False, static="static", arch="amd64"):
    """
    Compiles and runs the named main Go package
    """
    project = os.getenv("PROJECT_NAME")

    if build:
        context.run(f'./target/dist/bin/{project}')
    elif docker:
        commit = os.getenv("PROJECT_COMMIT")
        project = os.getenv("PROJECT_NAME")
        system = os.getenv("PROJECT_SYSTEM")
        version = os.getenv("PROJECT_VERSION")

        golang = os.getenv("GOLANG_VERSION")

        # Execute the `./docker/run.dockerfile` and pass
        # necessary build arguments.
        context.run(f'docker build \
            --file ./docker/run.dockerfile \
            --tag {project} \
            --build-arg ARCH={arch} \
            --build-arg COMMIT={commit} \
            --build-arg GOLANG_VERSION={golang} \
            --build-arg OS={system} \
            --build-arg PROJECT={project} \
            --build-arg STATIC_FLAG={static} \
            .')
        context.run(f'docker run --interactive --rm {project}:latest')
    else:
        context.run(f'go run ./cmd/{project}')

# === TEST ===


@task(pre=[__setup], default=True, name="all")
def test_all(context):
    """
    Run all `test` tasks
    """
    test_golangci_lint(context)
    test_unit(context)


@task(pre=[__setup], name="golangci-lint", aliases=["gl"])
def test_golangci_lint(context):
    """
    Run `golangci-lint`
    """
    context.run("golangci-lint run \
        --verbose \
        --out-format 'junit-xml' \
        --mem-profile-path ./test/mem-profile.out \
        --cpu-profile-path ./test/cpu-profile.out \
        --trace-path ./test/trace.out \
        --fix \
        | tee ./test/coverage.xml")


@task(pre=[__setup], name="unit", aliases=["u"])
def test_unit(context, static="static"):
    """
    Run unit tests
    """
    context.run(f'go test -tags {static} \
        -covermode=atomic \
        -bench=. \
        -race \
        -coverprofile=./test/coverage.out \
        -v ./...')


test = Collection("test", test_all)
test.add_task(test_golangci_lint)
test.add_task(test_unit)

# === UPDATE ===


@task(pre=[__setup], default=True, name="all")
def update_all(context):
    """
    Run all `update` tasks
    """
    update_niv(context)
    update_npm(context)


@task(pre=[__setup], name="niv")
def update_niv(context):
    """
    Update niv dependencies
    """
    context.run("niv update")


@task(pre=[__setup], name="npm")
def update_npm(context):
    """
    Update npm packages
    """
    context.run("npm run update")


update = Collection("update", update_all)
update.add_task(update_niv)
update.add_task(update_npm)

#

namespace = Collection()
namespace.add_task(init)
namespace.add_task(run)


namespace.add_collection(build)
namespace.add_collection(clean)
namespace.add_collection(test)
namespace.add_collection(update)
