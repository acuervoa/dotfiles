# Firma de commits y tags

La configuración actual no activa firma automáticamente porque la identidad
de usuario y la clave disponible son datos locales. La política recomendada
es firma SSH de Git, configurada por máquina y verificada antes de activarla:

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
git config --global tag.gpgSign true
```

Antes de aplicar esos valores:

1. Confirmar que la clave privada existe y que la pública corresponde a la
   identidad de GitHub/GitLab usada.
2. Configurar `gpg.ssh.allowedSignersFile` en un archivo local no versionado.
3. Crear un commit de prueba en una rama temporal y comprobar
   `git log --show-signature`.
4. Mantener `commit.gpgsign` desactivado si la máquina no tiene una clave
   dedicada o si el agente SSH no está disponible.

No se ejecutó ninguna de estas modificaciones durante la auditoría.
