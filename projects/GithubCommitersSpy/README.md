# Github Commiters Spy

This script enumerates active committers in specified GitHub repositories over a given number of days. It fetches the data using the GitHub API and outputs the results to CSV files.

The objective behind this project was to facilitate the survey of the real number of users who collaborate in the Github repositories of important company projects, and thus be able to price SAST and SCA licenses with greater accuracy.

## Special Thanks
- Michelle Mesquita | https://github.com/michelleamesquita
- Murillo Rocha | https://github.com/6drocha

## Downloading

To download a specific project, simply access the website https://download-directory.github.io and provide the full folder address, as in the example below.

```
https://download-directory.github.io?url=https://github.com/0xtiago/ToolBox/tree/main/projects/GithubCommitersSpy
```


## Features

- Fetch active committers from specified GitHub repositories.
- Retrieve commit data from the main branch within a specified number of days.
- Output results to CSV files, including detailed commit counts per user.
- Display an ASCII art banner at the start of execution.

## Requirements

- Python 3.x
- `requests` library
- `pyyaml` library
- `termcolor` library
- `emoji` library

## Installation

1. Clone the repository or download the script files.
2. Install the required Python libraries:
    ```sh
    pip install -r requirements.txt
    ```

## Configuration

1. Create a `config.yaml` file with the following content and replace `your_github_token` with your GitHub personal access token:
    ```yaml
    github_token: "your_github_token"
    ```

2. Create a `repositories.txt` file and add the repositories you want to analyze, one per line, in the format `owner/repo` or `https://github.com/owner/repo`.

## Usage

Run the script with the desired number of days to check for active committers using the `-d` flag:

```sh
python gh_commiters_spy.py -d 90
````

Receiving the number of collaborators in default branch in the last 90 days.

![alt text](assets/images/demonstration.gif)

## Support

☕ If this tool helped you, how about inviting me for a coffee?? 😄



[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/tiagotavares)


