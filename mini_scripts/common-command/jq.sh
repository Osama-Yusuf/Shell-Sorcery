# Beatify the json in between log text
jq -rR 'index("{") as $ix | .[0:$ix], ( .[$ix:]|fromjson)'

# Beatify the json only result without any additional text
jq .
