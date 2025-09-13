# Running this container

## Building the image

From the directory containing the Dockerfile, build the image with:

```bash
docker build -t <image-name> .
```

## Running this container

### Linux / macOS

To run this image with a directory from your host mounted into the container’s working directory (`/home/repos`):

```bash
docker run -it \
  -v ~/projects/myapp:/home/repos \
  <image-name> \
  bash
```

- Any edits you make in `/home/repos` inside the container will be saved back to `~/projects/myapp` on the host.  
- If you **don’t want your changes to persist**, simply omit the `-v` flag.

Tip: You can mount any directory you like by replacing `~/projects/myapp` with the path to your project folder. For example, to mount the current directory from your host into the container, run:

```bash
docker run -it -v "$(pwd):/home/repos" <image-name> bash
```

### Windows PowerShell

```powershell
docker run -it `
  -v ${HOME}\projects\myapp:/home/repos `
  <image-name> `
  bash
```

### Windows Command Prompt

```cmd
docker run -it ^
  -v %USERPROFILE%\projects\myapp:/home/repos ^
  <image-name> ^
  bash
```

### Permissions note
Because the container runs as `root`, files created in the mounted directory may be owned by `root` on the host. If you want files to be owned by your host user, run the container with your host UID/GID (Linux/macOS):

```bash
docker run -it \
  -v ~/projects/myapp:/home/repos \
  -u $(id -u):$(id -g) \
  <image-name> \
  bash
```

Keep in mind that running as a non-root user inside the container may affect tools that expect root privileges (e.g., system-wide installs or tools with files in `/root`). If you hit permission issues, a quick fix is to `chown` the directory on the host after running:

```bash
sudo chown -R $(id -u):$(id -g) ~/projects/myapp
```
