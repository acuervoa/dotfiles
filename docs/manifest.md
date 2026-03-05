# Manifest (rollback manual)

Los manifests viven en `.manifests/<TIMESTAMP>.manifest` y registran los
symlinks creados por el bootstrap.

## Formato

Cada línea sigue el formato:

```
LINK <src> -> <dest>
```

Ejemplo:

```
LINK /home/user/dotfiles/stow/bash/.bashrc -> /home/user/.bashrc
LINK /home/user/dotfiles/stow/nvim/.config/nvim -> /home/user/.config/nvim
```

## Uso en rollback manual

1. Filtra las líneas `LINK` para encontrar los enlaces creados.
2. Elimina los symlinks que apunten al repo (si vas a restaurar backups).
3. Restaura los backups desde `.backups/<TIMESTAMP>/` si corresponde.

Notas:
- Si el symlink apunta a otro destino, no lo toques.
- Usa `bash ./scripts/rollback.sh` cuando sea posible.

## FAQ

**El symlink no coincide con el manifest**

- No lo elimines automáticamente.
- Verifica manualmente el destino con `readlink` y decide caso por caso.

**Cómo identificar symlinks fuera del repo**

- Usa `readlink -f <dest>` y verifica que empiece con la ruta del repo.
- Si no apunta al repo, no lo elimines automáticamente.
