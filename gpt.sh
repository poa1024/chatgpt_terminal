#!/usr/bin/env zsh

# Your OpenAI API key
API_KEY=$OPEN_AI_API_KEY

CODE_ONLY=false
RAW=false
HISTORY_SIZE=1000
GPT_VERSION='gpt-3.5-turbo'

# Parse command-line options
while getopts 'd:r:c' arg; do
  case $arg in
  d)
    CODE_ONLY=true
    shift "1"
    ;;
  r)
    RAW=true
    shift "1"
    ;;
  c)
    echo "" >"$TMPDIR/history.txt"
    exit 0
    ;;
  *)
    echo "Error: Invalid flag -$OPTARG" >&2
    exit 1
    ;;
  esac
done

# Truncate history
sh truncate.sh "$TMPDIR/history.txt" $HISTORY_SIZE

# Add request to history
REQ="$1"
echo "Q:$REQ" >>"$TMPDIR/history.txt"

# Prepare full dialog for API request
FULL_DIALOG=$(cat "$TMPDIR/history.txt")
[ "$CODE_ONLY" = true ] && FULL_DIALOG=$(echo "$FULL_DIALOG. CODE ONLY.")

# Create API request body
JSON_BODY=$(jq -n \
  --arg FULL_DIALOG "$FULL_DIALOG" \
  --arg GPT_VERSION "$GPT_VERSION" \
  '{
    "model": $GPT_VERSION,
    "messages": [{"role": "user", "content": $FULL_DIALOG}]
  }')

# Send API request and process response
if [ "$RAW" = true ]; then
  RES=$(curl https://api.openai.com/v1/chat/completions -s \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d $JSON_BODY)

  CHOICE_1=$(echo "$RES" | jq -r '.choices[0].message.content')
  CHOICE_1="${CHOICE_1#A:}"
  echo "A:$CHOICE_1" >>"$TMPDIR/history.txt"
else
  RES=$(curl https://api.openai.com/v1/chat/completions -s \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d $JSON_BODY |
    jq -r '.choices[0].message.content')
  RES="${RES#A:}"
  echo "A:$RES" >>"$TMPDIR/history.txt"
fi

# Extract code if -d flag is provided
if [ "$CODE_ONLY" = true ] && grep -q '```' <<<"$RES"; then
  RES=$(echo "$RES" | pcregrep -oM '```(.|\n|\r)*```' | grep -v '```')
fi

# Add empty line to history and output the response
echo "" >>"$TMPDIR/history.txt"
echo "$RES"
