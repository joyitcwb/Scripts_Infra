ls  /joy/backup/ | jq -R -s -c   'split("\n") | map({"{#DIR}": .[:10] | select(length > 0) })';
