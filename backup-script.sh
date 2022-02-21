#!/bin/sh
# コマンドパス
s_TAR_COMMAND='/usr/bin/tar'
s_AWS_COMMAND='/usr/local/bin/aws'

# 作業ディレクトリ等
s_TMP_DIRECTORY='/root/backup'

# IAMアカウントとS3情報
s_AWS_ACCESS_KEY_ID='XXXXXXXXXXXXXXXXXX'
s_AWS_SECRET_ACCESS_KEY='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
s_S3_BUCKET='backup.system'
s_S3_DIRECTORY='example.com'

if [ $# != 1 ];then
    echo "引数なし"
    exit 1
fi

# ディレクトリの初期化
rm $s_TMP_DIRECTORY/*

# DATE値の取得
s_DATE=`date '+%Y%m%d%T' | tr -d :`

# ファイル名の生成
if [ $1 = "full" ]; then
    echo "full"
    BACKUP_FILENAME="BackupFiles-html-${s_DATE}-full.tar.gz"
elif [ $1 = "diff" ]; then
    echo "diff"
    BACKUP_FILENAME="BackupFiles-html-${s_DATE}-diff.tar.gz"
else
    exit 1
fi

# 差分オプションの生成
DIFF_OPTION=""
if [ $1 = "diff" ]; then
    DIFF_DATE=`date +%Y-%m-%d --date '1 day ago'`
    DIFF_OPTION=" -N ${DIFF_DATE}"
fi

# TARボールの作成
cd /var/www;$s_TAR_COMMAND zcvf $s_TMP_DIRECTORY/$BACKUP_FILENAME$DIFF_OPTION html &> /dev/null

# S3アップロード
export AWS_ACCESS_KEY_ID=$s_AWS_ACCESS_KEY_ID;
export AWS_SECRET_ACCESS_KEY=$s_AWS_SECRET_ACCESS_KEY;
export AWS_DEFAULT_REGION='ap-northeast-1';
export AWS_DEFAULT_OUTPUT='text';
$s_AWS_COMMAND s3 cp "$s_TMP_DIRECTORY/$BACKUP_FILENAME" s3://$s_S3_BUCKET/$s_S3_DIRECTORY/$BACKUP_FILENAME

exit 0
