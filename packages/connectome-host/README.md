# connectome-host

Build and run from this checkout:

```sh
nix build --accept-flake-config .#connectome-host
./result/bin/connectome-host ./result/share/connectome-host/recipes/mock-test.json
```

The mock recipe needs no credentials and enables the web console at
<http://127.0.0.1:7340>. It exercises the same host and native Chronicle store
as a real provider. Recipes shipped upstream are installed under
`result/share/connectome-host/recipes`.

For a real agent, pass your own recipe:

```sh
nix run --accept-flake-config .#connectome-host -- /path/to/recipe.json
```

The default provider uses `ANTHROPIC_API_KEY` or `ANTHROPIC_AUTH_TOKEN`.
Other providers and recipe options are documented in the
[upstream README](https://github.com/anima-research/connectome-host#recipes).
State is written to `./data` in your working directory; set `DATA_DIR` to
choose another location. For daemon operation, add `--headless`.

Update both the host and web UI dependency hashes with:

```sh
nix run nixpkgs#nix-update -- --flake connectome-host --subpackage web
```
