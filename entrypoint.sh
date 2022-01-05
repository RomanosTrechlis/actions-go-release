#!/bin/sh

set -eux

PROJECT_ROOT="/go/src/github.com/${GITHUB_REPOSITORY}"
PROJECT_NAME=$(basename $GITHUB_REPOSITORY)
NAME="${NAME:-${PROJECT_NAME}_${RELEASE_NAME}}_${GOOS}_${GOARCH}"

mkdir -p $PROJECT_ROOT
rmdir $PROJECT_ROOT
ln -s $GITHUB_WORKSPACE $PROJECT_ROOT
cd $PROJECT_ROOT
go get -v ./...

BASE_URL="https://api.github.com/repos/${GITHUB_REPOSITORY}"

getURLFromResponse() {
    r=$(echo ${response} | tr '\r\n' ' ' | jq -c '.[]' |
        while read i; do
            test=$(echo ${i} | jq -r .tag_name);
            if [ "$test" = "${RELEASE_NAME}" ]; then
               res=`echo "$i" | jq -r .upload_url`
               echo $res
               break;
            fi
        done
    )
    echo $r
}

getUploadURL() {
    CREATE_BODY="{\"tag_name\": \"${RELEASE_NAME}\"}"
    response=$(curl \
      -X POST \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Accept: application/vnd.github.v3+json" \
      "${BASE_URL}/releases" \
      -d "${CREATE_BODY}"
    )

    exists=$(echo ${response} |  jq -r .errors[0].code)
    if [ "${exists}" = "already_exists" ]; then 
        response=$(curl \
            -H "Authorization: Bearer ${GITHUB_TOKEN}" \
            -H "Accept: application/vnd.github.v3+json" \
            "${BASE_URL}/releases"
        )
        UPLOAD_URL=$(getURLFromResponse $response)
        N=`echo $UPLOAD_URL | sed 's/{?name,label}//g'`
        echo $N
    else
        UPLOAD_URL=`echo "${response}" | jq -r '.upload_url'`
        N=`echo $UPLOAD_URL | sed 's/{?name,label}//g'`
        echo $N
    fi
}

if [ -z "${CMD_PATH+x}" ]; then
  echo "::warning file=entrypoint.sh,line=6,col=1::CMD_PATH not set"
  export CMD_PATH="."
fi

EXT=''

if [ $GOOS == 'windows' ]; then
EXT='.exe'
fi

go build "${CMD_PATH}"
FILE_LIST="${PROJECT_NAME}${EXT}"

if [ -z "${EXTRA_FILES+x}" ]; then
    EXTRA_FILES=""
fi

FILE_LIST="${FILE_LIST} ${EXTRA_FILES}"
FILE_LIST=`echo "${FILE_LIST}" | awk '{$1=$1};1'`

ARCHIVE_EXT=".tar.gz"
MEDIA_TYPE='application/gzip'
if [ $GOOS == 'windows' ]; then
    ARCHIVE_EXT=".zip"
    MEDIA_TYPE='application/zip'
    zip -9r ${NAME}${ARCHIVE_EXT} ${FILE_LIST}
else
    tar cvfz ${NAME}${ARCHIVE_EXT} ${FILE_LIST}
fi

CHECKSUM=$(md5sum ${NAME}${ARCHIVE_EXT} | cut -d ' ' -f 1)

UPLOAD_URL=$(getUploadURL)
echo $UPLOAD_URL

curl \
  -X POST \
  --data-binary @${NAME}${ARCHIVE_EXT} \
  -H 'Content-Type: application/octet-stream' \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "${UPLOAD_URL}?name=${NAME}${ARCHIVE_EXT}"

curl \
  -X POST \
  --data $CHECKSUM \
  -H 'Content-Type: text/plain' \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "${UPLOAD_URL}?name=${NAME}_checksum.txt"