# sast_stress_poc

```bash
brew install xmlstarlet
```

## Veracode


```bash
bash bin/veracode/veracode_install.sh
```


## Checkmarx

```bash
brew install checkmarx/ast-cli/ast-cli
```


https://github.com/checkmarx/ast-cli
https://github.com/Checkmarx/homebrew-ast-cli 



# How to use 

```bash
./sast_stress.sh -t veracode -p ProjectName -s ../VulnNode -n 100
```
![Veracode Running](assets/images/veracode_running.png)

```bash
./sast_stress.sh -t checkmarx -p ProjectName -s ../VulnNode -n 100
```
![Checkmarx Running](assets/images/checkmarx_running.png)



# Environment

## Bash environment
- GNU bash, version 3.2.57(1)-release (arm64-apple-darwin23)
- zsh 5.9 (x86_64-apple-darwin23.0)

## Checkmarx
- CXOne CLI - 2.1.5

## Veracode

- Wrapper - VeracodeJavaAPI v24.4.13.0 c22.0.1
- Veracode CLI - Veracode CLI v2.25.0 -- 37d59bf
