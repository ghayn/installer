#!/bin/zsh

function process_input() {
    local text="$1"
    local callback="$2"

    while true; do
        echo -n "$text (y/N): "
        read response
        response=${response:l}  # 将输入转换为小写

        if [[ "$response" == "y" ]]; then
            "$callback"
            break
        elif [[ "$response" == "n" ]]; then
            echo "Operation canceled."
            break
        else
            echo "Invalid input. Please enter 'y' or 'n'."
        fi
    done
}

function password_input() {
    local text="$1"
    local password
    echo -n $text >&2  # 将提示消息发送到stderr来强制显示信息
    read -s password
    echo "$password"
}

function escape_backslashes() {
    local input="$1"
    local escaped_input=$(echo "$input" | sed 's/\\/\\\\\\\\/g')
    echo "$escaped_input"
}


function autoinput() {
    local command="$1"         # 传递的命令
    local match_string="$2"    # 匹配的字符串
    local auto_fill_string=$(escape_backslashes "$3")            # 自动填写的字符串

    echo "$auto_fill_string"

    /usr/bin/expect <<-EOF
        set timeout -1
        spawn $command

        expect {
            -re $match_string {
                send "$auto_fill_string\r"
                exp_continue
            }
            eof
        }
EOF
}
