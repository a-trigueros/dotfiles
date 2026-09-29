# Autostart des services (mise + pitchfork) sur macOS

## Fichiers à versionner (dotfiles), sans secrets

- ~/.config/mise/config.toml            # [tools] pitchfork + [bootstrap.services.pitchfork]
- ~/.config/autostart-services/mise.toml # [daemons.*]
- ~/.config/pitchfork/config.toml        # [settings.supervisor] auto_start = false
- ~/.config/agentgateway/config.yaml
Les secrets (token 1Password, clés API) se provisionnent à part, jamais dans le dépôt.

## 0. Prérequis

brew install mise
which mise   # noter le chemin, l'adapter dans config.toml (/opt/homebrew/bin/mise sur Apple Silicon)
which fnox bifrost agentgateway

### Si ce ne sont pas des outils mise : les déclarer dans [tools] du mise.toml

### ou ajouter leur dossier au PATH du service (launchd n'a que /usr/bin:/bin:/usr/sbin:/sbin)

## 1. Règles à respecter (pièges déjà rencontrés)

- UN SEUL propriétaire du démarrage : jamais `pitchfork boot enable` en plus du service mise.
- Poser auto_start = false AVANT tout lancement, sinon une commande `mise daemons ...`
  ou `pitchfork ...` démarre un superviseur "sauvage" qui bloque le service launchd.
- Ne pas laisser `auto = [...]` dans les daemons : il les relance à chaque prompt dans le dossier.
- Le service launchd est un LaunchAgent : démarre au login, pas avant la session.

## 2. Installation

mise trust ~/.config/autostart-services
cd ~/.config/autostart-services && mise install

### Test du superviseur en premier plan (voit les erreurs), puis Ctrl-C

mise x -- pitchfork supervisor run --boot

### Service géré

mise bootstrap --dry-run
mise bootstrap
mise bootstrap services status        # user-service:pitchfork doit être running

### Enregistrer les daemons puis relancer le service pour que --boot les démarre

mise daemons register                 # (à valider : peut nécessiter un superviseur actif)
launchctl kickstart -k gui/$(id -u)/dev.mise.pitchfork

## 3. Vérification

ps aux | grep '[p]itchfork supervisor'   # un seul, avec "run --boot"
mise daemons ls                          # bifrost + agentgateway en running

### Puis fermer la session et la rouvrir, refaire les deux commandes ci-dessus

## 4. Diagnostic si ça ne démarre pas

launchctl print gui/$(id -u)/dev.mise.pitchfork   # state, last exit code, arguments
pitchfork boot status                             # doit dire "disabled"
mise daemons logs bifrost

## 6. Désinstallation d'un daemon

1. `mise daemons stop {name}`
2. retirer ou commenter la déclaration du daemon du mise.toml
3. `mise daemons register`
4. `pitchfork clean --daemon {name}`
5. Vérifier: `mise daemons ls` `pitchfork list`

## 5. Désinstallation

mise daemons stop
mise bootstrap services remove pitchfork

### retirer le bloc [bootstrap.services.pitchfork] de la config globale
