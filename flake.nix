{
  description = "NixOS Security Lab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };


  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { system = "${system}"; config.allowUnfree = true; };
          full = false; # Include all tools
          recon = true; # Relevant tools for reconnaissance
          scan = false; # Relevant tools for scanning for vulnerabilities
          exploit = false;
          exdev = true;

          packages =
            (if recon || full then [
              pkgs.nmap
              pkgs.bloodhound
              pkgs.wprecon
              pkgs.urlhunter
              pkgs.dnsrecon
              pkgs.maltego
            ] else [ ]) ++
            (if scan || full then [
              pkgs.nmap
              pkgs.nikto
              pkgs.zap
              pkgs.openvas-scanner
            ] else [ ]) ++
            (if exploit || full then [
              pkgs.metasploit
              pkgs.sqlmap
              pkgs.thc-hydra
              pkgs.bloodhound
              pkgs.powersploit
            ] else [ ]) ++
            (if exdev || full then [
              (pkgs.python3.withPackages (python-pkgs: [
                python-pkgs.ropper
                python-pkgs.pwntools
                python-pkgs.pycrypto
              ]))
              pkgs.aflplusplus
              pkgs.radare2
              pkgs.binwalk
              pkgs.gdb
              pkgs.pwndbg
              pkgs.binutils
            ] else [ ]);
        in
        {
          inherit pkgs;
          devShells.default = pkgs.mkShell
            {
              buildInputs = packages;
            };
        }
      );
}
