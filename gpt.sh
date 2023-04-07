#!/usr/bin/env zsh

# Your OpenAI API key
API_KEY=$OPEN_AI_API_KEY

CODE_ONLY=false
RAW=false
CLEAN=false
GPT_VERSION='gpt-3.5-turbo'

while getopts 'd:r:c:' arg; do
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
    CLEAN=true
    shift "1"
    ;;
  *)
    echo "Error: Invalid flag -$OPTARG" >&2
    exit 1
    ;;
  esac

done

if [ "$CLEAN" = true ]; then
  echo "" >"$TMPDIR/history.txt"
fi

sh truncate.sh "$TMPDIR/history.txt" 1000

REQ="$1"
echo "Q:$REQ" >>"$TMPDIR/history.txt"

FULL_DIALOG=$(cat "$TMPDIR/history.txt")

if [ "$CODE_ONLY" = true ]; then
  FULL_DIALOG=$(echo "$FULL_DIALOG. CODE ONLY.")
fi

REQ_BODY=$(jq -n \
  --arg FULL_DIALOG "$FULL_DIALOG" \
  --arg GPT_VERSION "$GPT_VERSION" \
  '{
                "model": $GPT_VERSION,
                "messages": [{"role": "user", "content": $FULL_DIALOG}]
              }')

echo $REQ_BODY

if [ "$RAW" = true ]; then
  RES=$(
    curl https://api.openai.com/v1/chat/completions -s \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $API_KEY" \
      -d $REQ_BODY
  )
  CHOICE_1=$(echo "$RES" | jq -r '.choices[0].message.content')
  CHOICE_1="${CHOICE_1#A:}"
  echo "A:$CHOICE_1" >>"$TMPDIR/history.txt"
else
  RES=$(curl https://api.openai.com/v1/chat/completions -s \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d $REQ_BODY |
    jq -r '.choices[0].message.content')
  RES="${RES#A:}"
  echo "A:$RES" >>"$TMPDIR/history.txt"
fi

if [ "$CODE_ONLY" = true ] && grep -q '```' <<<"$RES"; then
  RES=$(echo "$RES" | pcregrep -oM '```(.|\n|\r)*```' | grep -v '```')
fi

echo "" >>"$TMPDIR/history.txt"

echo "$RES"
