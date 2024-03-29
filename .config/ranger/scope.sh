#!/usr/bin/env bash

set -o noclobber -o noglob -o nounset -o pipefail
IFS=$'\n'

## If the option `use_preview_script` is set to `true`,
## then this script will be called and its output will be displayed in ranger.
## ANSI color codes are supported.
## STDIN is disabled, so interactive scripts won't work properly

## This script is considered a configuration file and must be updated manually.
## It will be left untouched if you upgrade ranger.

## Because of some automated testing we do on the script #'s for comments need
## to be doubled up. Code that is commented out, because it's an alternative for
## example, gets only one #.

## Meanings of exit codes:
## code | meaning    | action of ranger
## -----+------------+-------------------------------------------
## 0    | success    | Display stdout as preview
## 1    | no preview | Display no preview at all
## 2    | plain text | Display the plain content of the file
## 3    | fix width  | Don't reload when width changes
## 4    | fix height | Don't reload when height changes
## 5    | fix both   | Don't ever reload
## 6    | image      | Display the image `$IMAGE_CACHE_PATH` points to as an image preview
## 7    | image      | Display the file directly as an image

## Script arguments
FILE_PATH="${1}"         # Full path of the highlighted file
PV_WIDTH="${2}"          # Width of the preview pane (number of fitting characters)
## shellcheck disable=SC2034 # PV_HEIGHT is provided for convenience and unused
PV_HEIGHT="${3}"         # Height of the preview pane (number of fitting characters)
IMAGE_CACHE_PATH="${4}"  # Full path that should be used to cache image preview
PV_IMAGE_ENABLED="${5}"  # 'True' if image previews are enabled, 'False' otherwise.

FILE_EXTENSION="${FILE_PATH##*.}"
FILE_EXTENSION_LOWER="$(printf "%s" "${FILE_EXTENSION}" | tr '[:upper:]' '[:lower:]')"

## Settings
HIGHLIGHT_SIZE_MAX=262143  # 256KiB
HIGHLIGHT_TABWIDTH="${HIGHLIGHT_TABWIDTH:-8}"
HIGHLIGHT_STYLE="${HIGHLIGHT_STYLE:-pablo}"
HIGHLIGHT_OPTIONS="--replace-tabs=${HIGHLIGHT_TABWIDTH} --style=${HIGHLIGHT_STYLE} ${HIGHLIGHT_OPTIONS:-}"
PYGMENTIZE_STYLE="${PYGMENTIZE_STYLE:-autumn}"
BAT_STYLE="${BAT_STYLE:-plain}"
OPENSCAD_IMGSIZE="${RNGR_OPENSCAD_IMGSIZE:-1000,1000}"
OPENSCAD_COLORSCHEME="${RNGR_OPENSCAD_COLORSCHEME:-Tomorrow Night}"
SQLITE_TABLE_LIMIT=20  # Display only the top <limit> tables in database, set to 0 for no exhaustive preview (only the sqlite_master table is displayed).
SQLITE_ROW_LIMIT=5     # Display only the first and the last (<limit> - 1) records in each table, set to 0 for no limits.

handle_extension() {
    case "${FILE_EXTENSION_LOWER}" in
        ## Archive
        a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|\
        rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)
            atool --list -- "${FILE_PATH}" && exit 5
            bsdtar --list --file "${FILE_PATH}" && exit 5
            exit 1;;
        rar)
            ## Avoid password prompt by providing empty password
            unrar lt -p- -- "${FILE_PATH}" && exit 5
            exit 1;;
        7z)
            ## Avoid password prompt by providing empty password
            7z l -p -- "${FILE_PATH}" && exit 5
            exit 1;;

        ## PDF
        pdf)
            ## Preview as text conversion
            pdftotext -l 10 -nopgbrk -q -- "${FILE_PATH}" - | \
              fmt -w "${PV_WIDTH}" && exit 5
            mutool draw -F txt -i -- "${FILE_PATH}" 1-10 | \
              fmt -w "${PV_WIDTH}" && exit 5
            exiftool "${FILE_PATH}" && exit 5
            exit 1;;

        ## BitTorrent
        torrent)
            transmission-show -- "${FILE_PATH}" && exit 5
            exit 1;;

        ## OpenDocument
        odt|sxw)
            ## Preview as text conversion
            odt2txt "${FILE_PATH}" && exit 5
            ## Preview as markdown conversion
            pandoc -s -t markdown -- "${FILE_PATH}" && exit 5
            exit 1;;
        ods|odp)
            ## Preview as text conversion (unsupported by pandoc for markdown)
            odt2txt "${FILE_PATH}" && exit 5
            exit 1;;

        ## XLSX
        xlsx)
            ## Preview as csv conversion
            ## Uses: https://github.com/dilshod/xlsx2csv
            xlsx2csv -- "${FILE_PATH}" && exit 5
            exit 1;;

        ## HTML
        htm|html|xhtml)
            ## Preview as text conversion
            w3m -dump "${FILE_PATH}" && exit 5
            lynx -dump -- "${FILE_PATH}" && exit 5
            elinks -dump "${FILE_PATH}" && exit 5
            pandoc -s -t markdown -- "${FILE_PATH}" && exit 5
            ;;

        ## JSON
        json)
            jq --color-output . "${FILE_PATH}" && exit 5
            python -m json.tool -- "${FILE_PATH}" && exit 5
            ;;

        ## Jupyter Notebooks
        ipynb)
            jupyter nbconvert --to markdown "${FILE_PATH}" --stdout | env COLORTERM=8bit bat --color=always --style=plain --language=markdown && exit 5
            jupyter nbconvert --to markdown "${FILE_PATH}" --stdout && exit 5
            jq --color-output . "${FILE_PATH}" && exit 5
            python -m json.tool -- "${FILE_PATH}" && exit 5
            ;;

        ## Direct Stream Digital/Transfer (DSDIFF) and wavpack aren't detected
        ## by file(1).
        dff|dsf|wv|wvc)
            mediainfo "${FILE_PATH}" && exit 5
            exiftool "${FILE_PATH}" && exit 5
            ;; # Continue with next handler on failure
        webp)
            stat "${FILE_PATH}"
            exit 5
            ;;
    esac
}

handle_mime() {
    local mimetype="${1}"
    case "${mimetype}" in
        ## RTF and DOC
        text/rtf|*msword)
            ## Preview as text conversion
            ## note: catdoc does not always work for .doc files
            ## catdoc: http://www.wagner.pp.ru/~vitus/software/catdoc/
            catdoc -- "${FILE_PATH}" && exit 5
            exit 1;;

        ## DOCX, ePub, FB2 (using markdown)
        ## You might want to remove "|epub" and/or "|fb2" below if you have
        ## uncommented other methods to preview those formats
        *wordprocessingml.document|*/epub+zip|*/x-fictionbook+xml)
            ## Preview as markdown conversion
            pandoc -s -t markdown -- "${FILE_PATH}" && exit 5
            exit 1;;

        ## E-mails
        message/rfc822)
            ## Parsing performed by mu: https://github.com/djcb/mu
            mu view -- "${FILE_PATH}" && exit 5
            exit 1;;

        ## XLS
        *ms-excel)
            ## Preview as csv conversion
            ## xls2csv comes with catdoc:
            ##   http://www.wagner.pp.ru/~vitus/software/catdoc/
            xls2csv -- "${FILE_PATH}" && exit 5
            exit 1;;

        ## SQLite
        *sqlite3)
            ## Preview as text conversion
            sqlite_tables="$( sqlite3 "file:${FILE_PATH}?mode=ro" '.tables' )" \
                || exit 1
            [ -z "${sqlite_tables}" ] &&
                { echo "Empty SQLite database." && exit 5; }
            sqlite_show_query() {
                sqlite-utils query "${FILE_PATH}" "${1}" --table --fmt fancy_grid \
                || sqlite3 "file:${FILE_PATH}?mode=ro" "${1}" -header -column
            }
            ## Display basic table information
            sqlite_rowcount_query="$(
                sqlite3 "file:${FILE_PATH}?mode=ro" -noheader \
                    'SELECT group_concat(
                        "SELECT """ || name || """ AS tblname,
                                          count(*) AS rowcount
                         FROM " || name,
                        " UNION ALL "
                    )
                    FROM sqlite_master
                    WHERE type="table" AND name NOT LIKE "sqlite_%";'
            )"
            sqlite_show_query \
                "SELECT tblname AS 'table', rowcount AS 'count',
                (
                    SELECT '(' || group_concat(name, ', ') || ')'
                    FROM pragma_table_info(tblname)
                ) AS 'columns',
                (
                    SELECT '(' || group_concat(
                        upper(type) || (
                            CASE WHEN pk > 0 THEN ' PRIMARY KEY' ELSE '' END
                        ),
                        ', '
                    ) || ')'
                    FROM pragma_table_info(tblname)
                ) AS 'types'
                FROM (${sqlite_rowcount_query});"
            if [ "${SQLITE_TABLE_LIMIT}" -gt 0 ] &&
               [ "${SQLITE_ROW_LIMIT}" -ge 0 ]; then
                ## Do exhaustive preview
                echo && printf '>%.0s' $( seq "${PV_WIDTH}" ) && echo
                sqlite3 "file:${FILE_PATH}?mode=ro" -noheader \
                    "SELECT name FROM sqlite_master
                    WHERE type='table' AND name NOT LIKE 'sqlite_%'
                    LIMIT ${SQLITE_TABLE_LIMIT};" |
                    while read -r sqlite_table; do
                        sqlite_rowcount="$(
                            sqlite3 "file:${FILE_PATH}?mode=ro" -noheader \
                                "SELECT count(*) FROM ${sqlite_table}"
                        )"
                        echo
                        if [ "${SQLITE_ROW_LIMIT}" -gt 0 ] &&
                           [ "${SQLITE_ROW_LIMIT}" \
                             -lt "${sqlite_rowcount}" ]; then
                            echo "${sqlite_table} [${SQLITE_ROW_LIMIT} of ${sqlite_rowcount}]:"
                            sqlite_ellipsis_query="$(
                                sqlite3 "file:${FILE_PATH}?mode=ro" -noheader \
                                    "SELECT 'SELECT ' || group_concat(
                                        '''...''', ', '
                                    )
                                    FROM pragma_table_info(
                                        '${sqlite_table}'
                                    );"
                            )"
                            sqlite_show_query \
                                "SELECT * FROM (
                                    SELECT * FROM ${sqlite_table} LIMIT 1
                                )
                                UNION ALL ${sqlite_ellipsis_query} UNION ALL
                                SELECT * FROM (
                                    SELECT * FROM ${sqlite_table}
                                    LIMIT (${SQLITE_ROW_LIMIT} - 1)
                                    OFFSET (
                                        ${sqlite_rowcount}
                                        - (${SQLITE_ROW_LIMIT} - 1)
                                    )
                                );"
                        else
                            echo "${sqlite_table} [${sqlite_rowcount}]:"
                            sqlite_show_query "SELECT * FROM ${sqlite_table};"
                        fi
                    done
            fi
            exit 5;;

        ## Text
        text/* | */xml)
            ## Syntax highlight
            if [[ "$( stat --printf='%s' -- "${FILE_PATH}" )" -gt "${HIGHLIGHT_SIZE_MAX}" ]]; then
                exit 2
            fi
            if [[ "$( tput colors )" -ge 256 ]]; then
                local pygmentize_format='terminal256'
                local highlight_format='xterm256'
            else
                local pygmentize_format='terminal'
                local highlight_format='ansi'
            fi
            env HIGHLIGHT_OPTIONS="${HIGHLIGHT_OPTIONS}" highlight \
                --out-format="${highlight_format}" \
                -- "${FILE_PATH}" && exit 5
            env COLORTERM=8bit bat --color=always --style="${BAT_STYLE}" \
                -- "${FILE_PATH}" && exit 5
            pygmentize -f "${pygmentize_format}" -O "style=${PYGMENTIZE_STYLE}"\
                -- "${FILE_PATH}" && exit 5
            exit 2;;

        # ## DjVu
        # image/vnd.djvu)
        #     stat "${FILE_PATH}"
        #     # ## Preview as text conversion (requires djvulibre)
        #     # djvutxt "${FILE_PATH}" | fmt -w "${PV_WIDTH}" && exit 5
        #     # exiftool "${FILE_PATH}" && exit 5
        #     exit 1;;

        ## Image
        image/* | video/* | audio/*)
            stat "${FILE_PATH}"
            # ## Preview as text conversion
            # # img2txt --gamma=0.6 --width="${PV_WIDTH}" -- "${FILE_PATH}" && exit 4
            # exiftool "${FILE_PATH}" && exit 5
            exit 5;;

        # ## Video and audio
        # video/* | audio/*)
        #     mediainfo "${FILE_PATH}" && exit 5
        #     exiftool "${FILE_PATH}" && exit 5
        #     exit 1;;

        ## ELF files (executables and shared objects)
        application/x-executable | application/x-pie-executable | application/x-sharedlib)
            readelf -WCa "${FILE_PATH}" && exit 5
            exit 1;;
    esac
}

handle_fallback() {
    echo '----- File Type Classification -----' && file --dereference --brief -- "${FILE_PATH}" && exit 5
}


MIMETYPE="$( file --dereference --brief --mime-type -- "${FILE_PATH}" )"
handle_extension
handle_mime "${MIMETYPE}"
handle_fallback

exit 1
