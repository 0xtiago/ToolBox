# Github Commiters Enumerator

Para baixar este projeto em específico, basta acessar o site https://download-directory.github.io e passar o endereço completo da pasta, assim como no exemplo abaixo.

download-directory.github.io?url=https://github.com/0xtiago/ToolBox/tree/main/projects/GithubCommitersEnumerator

## Instalação e Configuração

```bash
pip install pyyaml
```

Configurar o token no arquivo `config.yaml`.

```yaml
github_token: "seu_token_aqui"
```

Crie um arquivo chamado `repositorios.txt` e adicione os repositórios desejados, um por linha, no formato `owner/repo`.


Run the script

```bash
python3 github_commiters.py
```

