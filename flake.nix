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
          full = true; # Include all tools
          recon = true; # Relevant tools for reconnaissance
          scan = false; # Relevant tools for scanning for vulnerabilities
          exploit = false; # Relevant tools for exploitation phase
          exdev = true; # Relevant tools for exploit development
          reverse = false; # Relevant tools for reverse engineering

          pythonDeps = builtins.concatLists [
            (if recon || full then [
              pkgs.python3Packages.pypcap
              pkgs.python3Packages.scapy
            ] else [ ])
            (if exdev || full then [
              pkgs.python3Packages.requests
              pkgs.python3Packages.scapy
              pkgs.python3Packages.ropper
              pkgs.python3Packages.pwntools
              pkgs.python3Packages.pycrypto
            ] else [ ])
            (if reverse || full then [
              pkgs.python3Packages.requests
              pkgs.python3Packages.scapy
              pkgs.python3Packages.ropper
              pkgs.python3Packages.pwntools
              pkgs.python3Packages.pycrypto
            ] else [ ])
          ];

          packages = builtins.concatLists [
            (if recon || full then [
              (pkgs.python3.withPackages (p: pythonDeps))
              pkgs.nmap
              pkgs.bloodhound
              pkgs.wprecon
              pkgs.urlhunter
              pkgs.dnsrecon
              pkgs.maltego
            ] else [ ])
            (if scan || full then [
              (pkgs.python3.withPackages (p: pythonDeps))
              pkgs.nmap
              pkgs.nikto
              pkgs.zap
              pkgs.openvas-scanner
            ] else [ ])
            (if exploit || full then [
              (pkgs.python3.withPackages (p: pythonDeps))
              pkgs.metasploit
              pkgs.sqlmap
              pkgs.thc-hydra
              pkgs.bloodhound
              pkgs.powersploit
            ] else [ ])
            (if exdev || full then [
              (pkgs.python3.withPackages (p: pythonDeps))
              pkgs.aflplusplus
              pkgs.radare2
              pkgs.binwalk
              pkgs.gdb
              pkgs.pwndbg
              pkgs.binutils
            ] else [ ])
            (if reverse || full then [
              (pkgs.python3.withPackages (p: pythonDeps))
              pkgs.aflplusplus
              pkgs.radare2
              pkgs.binwalk
              pkgs.gdb
              pkgs.pwndbg
              pkgs.binutils
              pkgs.ghidra-bin
            ] else [ ])
          ];
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
