import os
import signal
import subprocess

script_dir = os.path.dirname(os.path.realpath(__file__))


def main():
    import argparse

    argparser = argparse.ArgumentParser()
    argparser.add_argument("xcode_path")

    args = argparser.parse_args()

    xcode_path = args.xcode_path

    _, ext = os.path.splitext(xcode_path)

    if not os.path.exists(xcode_path):
        print("xcode path doesn't exist")
        exit(1)

    if ext != ".xip":
        print("xcode path should be a .xip archive")
        exit(1)

    sdk_path = os.path.join(script_dir, "sdk.tar")

    subprocess.check_call(["docker", "build", "-t", "crosstools-ios-sdk", "context/"],
                          preexec_fn=os.setsid,
                          cwd=script_dir)

    with open(sdk_path, "wb"):
        pass

    p = None
    try:
        p = subprocess.Popen(
                [
                    "docker", "run", "--rm", "-t", "--user", str(os.getuid()),
                    "-v", "{}:/xcode.xip:ro".format(os.path.abspath(xcode_path)),
                    "-v", "{}:/sdk.tar".format(os.path.abspath(sdk_path)),
                    "crosstools-ios-sdk",
                ],
                preexec_fn=os.setsid,
                cwd=script_dir)
        p.wait()
    except KeyboardInterrupt:
        if p is not None:
            os.killpg(os.getpgid(p.pid), signal.SIGINT)


main()
