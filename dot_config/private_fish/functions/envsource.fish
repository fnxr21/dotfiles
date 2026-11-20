# Based on https://gist.github.com/nikoheikkila/dd4357a178c8679411566ba2ca280fcc
function envsource --description 'Export every KEY=value line of a .env file: envsource .env'
    for line in (grep -v -E '^\s*(#|$)' $argv)
        set -l item (string split -m 1 '=' -- (string replace -r '^export\s+' '' -- $line))
        # strip one pair of surrounding quotes: KEY="value" -> value
        set -gx $item[1] (string replace -r '^([\'"])(.*)\1$' '$2' -- $item[2])
        echo "Exported key $item[1]"
    end
end
