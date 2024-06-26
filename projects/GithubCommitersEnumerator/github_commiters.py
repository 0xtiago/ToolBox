import requests
import csv
import yaml
from datetime import datetime, timedelta

# Reading YAML file.
def read_config(file_path):
    with open(file_path, 'r') as file:
        config = yaml.safe_load(file)
    return config

# Configuration, repositories list e output csv files.
config_file = 'config.yaml'
repos_file = 'repositories.txt'
output_file = 'results.csv'

# Reading configuration in your config file.
config = read_config(config_file)
GITHUB_TOKEN = config['github_token']
DAYS_AGO = config['days_ago']

# Configuring the authorization header with Github token.
headers = {
    'Authorization': f'token {GITHUB_TOKEN}'
}

# Function to reading list of repositories
def read_repos_from_file(file_path):
    with open(file_path, 'r') as file:
        repos = [line.strip() for line in file if line.strip()]
    return repos

# Function to read the active commiters in the last days declared in the YAML file
def get_active_collaborators(repo):
    url = f'https://api.github.com/repos/{repo}/contributors'
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        error_message = f'Failed to access repository {repo}: {response.status_code}'
        print(error_message)
        return 0, error_message
    
    contributors = response.json()
    active_collaborators = 0
    days_ago = datetime.now() - timedelta(days=int(DAYS_AGO))
    
    for contributor in contributors:
        contributions_url = contributor['url'] + '/events'
        events_response = requests.get(contributions_url, headers=headers)
        if events_response.status_code != 200:
            continue
        events = events_response.json()
        for event in events:
            event_date = datetime.strptime(event['created_at'], '%Y-%m-%dT%H:%M:%SZ')
            if event_date > days_ago:
                active_collaborators += 1
                break
    
    return active_collaborators, 'Success'


# Function to write the results in the CSV file
def write_results_to_csv(results, file_path):
    with open(file_path, 'w', newline='') as csvfile:
        fieldnames = ['Repository', 'Active Users', 'Status']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        writer.writeheader()
        for result in results:
            writer.writerow(result)

# Reading list of repositorios
repos = read_repos_from_file(repos_file)

# Create the list of results
results = []

# Loop in all repos and getting the number of active users
for repo in repos:
    active_collaborators, status = get_active_collaborators(repo)
    print(f'Repository: {repo}, Active users in the last {DAYS_AGO} days: {active_collaborators}')
    results.append({
        'Repository': repo,
        'Active Users': active_collaborators,
        'Status': status
    })

# Write the results to CSV file.
write_results_to_csv(results, output_file)

    
