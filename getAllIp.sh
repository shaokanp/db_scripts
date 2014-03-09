aws ec2 describe-instances --filter "Name=instance-state-name,Values=running" | grep "                                    " | grep  "Private" | grep -o -P "\d+\.\d+\.\d+\.\d+" | grep -v '^10\.'
