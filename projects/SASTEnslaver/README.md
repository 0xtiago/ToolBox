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