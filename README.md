# DAPHNE-Nix

** /!\ Partial /!\ ** packaging of [DAPHNE](https://github.com/daphne-eu/daphne) in [Nix](https://nixos.org)

## Install Nix

```
# Install Nix
bash <(curl -L https://nixos.org/nix/install)

# Activate flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

## Use the binary cache

A binary cache is available at https://daphne-nix.cachix.org

```
# Install cachix
nix-env -iA cachix -f https://cachix.org/api/v1/install

# Enable the binary cache for your builds
cachix use daphne-nix
```

## Enter a shell with `daphne`


You can enter a shell with the packaged version of `daphne` with:

```
nix shell github:GuilloteauQ/daphne-nix#daphne
```

## Add `daphne` to your experimental repository

You can add a **reproducible** `daphne` in an experimental environment:

```nix
{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.05";
    daphne-nix.url = "github:GuilloteauQ/daphne-nix";
  };

  outputs = { self, nixpkgs, daphne-nix }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system} = {
        daphne-shell = pkgs.mkShell {
          buildInputs = [
            daphne-nix.packages.${system}.daphne
          ];
        };
      };
    };
}
```

## Modify `daphne`

You can modify the packaging of `daphne` with Nix, through overrides (read more [here](https://ryantm.github.io/nixpkgs/using/overrides/))


For example changing the sources:

```nix
# ...
daphne-nix.packages.${system}.daphne.overrideAttrs (finalAttrs: previousAttrs: {
  src = ./path/to/my/sources;
}))
# ...
```

