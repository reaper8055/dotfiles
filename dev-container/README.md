## Build

```bash
docker build -t dev-container:latest .
```

## Run

```bash
docker run --rm -it -v "$HOME"/Projects:/home/ubuntu/work -w /home/ubuntu/work dev-container:latest zsh
```
