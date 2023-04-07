# OpenAI API Interaction Script

This script is a command-line tool written in Zsh that interacts with the OpenAI API using the GPT-3.5 Turbo model to generate responses for given requests. It maintains a history of previous requests and responses, and provides options for controlling the output format and behavior.
    
Written with the help of chat GPT-3.5 (even the readme.md :))

## Requirements

1. Zsh
2. Curl
3. JQ

## Usage

\```bash
./script_name.sh [-d] [-r] [-c] "Your request"
\```

### Options

- `-d`: Display only code in the response if it contains code wrapped in triple backticks (\``````).
- `-r`: Display the raw response from the API.
- `-c`: Clear the history file.

### Examples

1. To get a response for a request:

\```bash
./script_name.sh "What is the capital of France?"
\```

2. To get a response containing only code (if any) and save it to a Python file:

\```bash
./script_name.sh -d "How to reverse a list in Python?" > reverse_list.py
\```

3. To get the raw response from the API:

\```bash
./script_name.sh -r "What is the capital of France?"
\```

4. To clear the history file:

\```bash
./script_name.sh -c "What is the capital of France?"
\```

## Environment Variables

- `OPEN_AI_API_KEY`: Set your OpenAI API key as an environment variable before running the script.

## Configuration

- `HISTORY_SIZE`: You can change the history size by modifying the `HISTORY_SIZE` variable in the script (default is 1000).
- `GPT_VERSION`: You can change the GPT version by modifying the `GPT_VERSION` variable in the script (default is 'gpt-3.5-turbo').
