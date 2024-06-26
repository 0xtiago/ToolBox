import requests
import yaml
from datetime import datetime, timedelta

# Função para ler a configuração do arquivo YAML
def read_config(file_path):
    with open(file_path, 'r') as file:
        config = yaml.safe_load(file)
    return config

# Arquivo de configuração e arquivo contendo a lista de repositórios
config_file = 'config.yaml'
repos_file = 'repositorios.txt'

# Ler a configuração do arquivo YAML
config = read_config(config_file)
GITHUB_TOKEN = config['github_token']

# Cabeçalhos para autenticação na API do GitHub
headers = {
    'Authorization': f'token {GITHUB_TOKEN}'
}

# Função para ler a lista de repositórios a partir de um arquivo
def read_repos_from_file(file_path):
    with open(file_path, 'r') as file:
        repos = [line.strip() for line in file if line.strip()]
    return repos

# Função para obter colaboradores ativos nos últimos 60 dias
def get_active_collaborators(repo):
    url = f'https://api.github.com/repos/{repo}/contributors'
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        print(f'Erro ao acessar o repositório {repo}: {response.status_code}')
        return 0
    
    contributors = response.json()
    active_collaborators = 0
    sixty_days_ago = datetime.now() - timedelta(days=60)
    
    for contributor in contributors:
        contributions_url = contributor['url'] + '/events'
        events_response = requests.get(contributions_url, headers=headers)
        if events_response.status_code != 200:
            continue
        events = events_response.json()
        for event in events:
            event_date = datetime.strptime(event['created_at'], '%Y-%m-%dT%H:%M:%SZ')
            if event_date > sixty_days_ago:
                active_collaborators += 1
                break
    
    return active_collaborators

# Ler a lista de repositórios a partir do arquivo
repos = read_repos_from_file(repos_file)

# Loop pelos repositórios e printa o número de colaboradores ativos
for repo in repos:
    active_collaborators = get_active_collaborators(repo)
    print(f'Repositório: {repo}, Colaboradores ativos nos últimos 60 dias: {active_collaborators}')
