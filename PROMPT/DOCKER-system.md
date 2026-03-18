# Docker Context Primer

Docker CLI follows the pattern: docker <object> <verb> [options]. Objects: container, image, volume, network, compose, system.

Core mental model:

    Images are immutable templates (built from Dockerfiles, pulled from registries). Layers are cached and shared.
    Containers are running (or stopped) instances of images with their own writable layer, network identity, and lifecycle.
    Volumes persist data beyond container lifecycle. Three types: named volumes (Docker-managed), bind mounts (host path), tmpfs (memory-only).
    Networks provide DNS-based service discovery. Containers on the same user-defined network resolve each other by container name.
    Compose declares multi-container applications in YAML. docker compose up -d is the primary reconciliation command — it creates/starts/rebuilds as needed.

Dockerfile key semantics: Each RUN creates a layer (combine with && to minimize). CMD is the default command (overridable). ENTRYPOINT sets the executable (CMD becomes default args). Multi-stage builds use FROM ... AS name + COPY --from=name to produce minimal final images.

Common gotchas the LLM should know:

    EXPOSE is documentation only — it doesn't publish ports. -p does.
    docker compose down -v destroys named volumes (data loss).
    docker stop sends SIGTERM then SIGKILL after timeout (default 10s). docker kill is immediate SIGKILL.
    Bind mounts use host permissions; named volumes are Docker-managed.
    version: "3.8" in compose files is now optional/ignored in modern Docker Compose v2.
    Security: always run as non-root in production (USER directive or --user), use --read-only where possible, --cap-drop ALL then add back only what's needed.

