{
  description = "NixOS Security Lab";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: {
    devShells.default = { system, ... }: 
      let
        pkgs = import nixpkgs { inherit system; };

        full = builtins.getEnv "FULL" == "1";       # Include all tools
        recon = builtins.getEnv "RECON" == "1";     # Relevant tools for reconnaissance
        scan = builtins.getEnv "SCAN" == "1";       # Relevant tools for scanning for vulnerabilities
        exploit = builtins.getEnv "EXPLOIT" == "1";
        exdev = builtins.getEnv "EXDEV" == "1";
        report = builtins.getEnv "REPORT" == "1";

        packages = 
          (if recon || full then [ 
            pkgs.nmap
            pkgs.bloodhound
            pkgs.wprecon
            pkgs.urlhunter
            pkgs.dnsrecon
            pkgs.maltego
          ] else []) ++
          (if scan || full then [ 
            pkgs.nmap
            pkgs.nikto
            pkgs.zap
            pkgs.openvas-scanner
          ] else []) ++
          (if exploit || full then [ 
            pkgs.metasploit
            pkgs.sqlmap
            pkgs.thc-hydra
            pkgs.bloodhound
            pkgs.powersploit
          ] else []) ++
          (if exdev || full then [ 
            (pkgs.python3.withPackages (python-pkgs: [
              python-pkgs.ropper
              python-pkgs.pwntools
              python-pkgs.pycrypto
            ]))
            pkgs.aflplusplus
            pkgs.radare2
            pkgs.binwalk-full
            pkgs.gdb
            pkgs.pwndbg
            pkgs.binutils
            pkgs.libc
          ] else []);
      in
      {
        packages = packages;
      };
  };
}