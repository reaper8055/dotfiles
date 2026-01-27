## Build

```bash
docker build -t dev-container:latest . &> build.log
```

## Run

```bash
docker run --rm -it -v "$HOME"/Projects:/home/ubuntu/work -w /home/ubuntu/work dev-container:latest zsh
```
