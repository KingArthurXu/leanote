FROM alpine:latest

ENV LEANOTE_VERSION=2.5

RUN apk add --no-cache --update wget ca-certificates \
    && wget https://iweb.dl.sourceforge.net/project/leanote-bin/${LEANOTE_VERSION}/leanote-linux-amd64-v${LEANOTE_VERSION}.bin.tar.gz \
    && tar -zxvf leanote-linux-amd64-v${LEANOTE_VERSION}.bin.tar.gz -C / \
    && mkdir -p /leanote/data/public/upload \
    && mkdir -p /leanote/data/files \
    && mkdir -p /leanote/data/mongodb_backup \
    ## copy data then delete
    && cp -r /leanote/mongodb_backup/* /leanote/data/mongodb_backup \  

    && rm -r /leanote/public/upload \
    && rm -r /leanote/mongodb_backup \
    && rm leanote-linux-amd64-v${LEANOTE_VERSION}.bin.tar.gz \
    && ln -s /leanote/data/public/upload /leanote/public/upload \
    && ln -s /leanote/data/files /leanote/files \
    && ln -s /leanote/data/mongodb_backup /leanote/mongodb_backup

RUN echo '@community http://dl-cdn.alpinelinux.org/alpine/edge/community/' >> /etc/apk/repositories \
    && echo '@main http://dl-cdn.alpinelinux.org/alpine/edge/main/' >> /etc/apk/repositories \
    && apk add --no-cache --update libressl2.5-libcrypto@main libressl2.5-libssl@main mongodb@community \

    && sed -i '1a mkdir -p /leanote/data/data '                        /leanote/bin/run.sh \
    && sed -i '2a mongod --dbpath /leanote/data/data &'                /leanote/bin/run.sh \
    && sed -i '3a sleep 8 '                                            /leanote/bin/run.sh \
    && sed -i '4a if [ ! -f "/leanote/date/data/leanote.0" ]; then '   /leanote/bin/run.sh \
    && sed -i '5a      mongorestore -h localhost -d leanote --dir /leanote/mongodb_backup/leanote_install_data/' /leanote/bin/run.sh \
    && sed -i '6a fi' 


VOLUME /leanote/data/

EXPOSE 9000

CMD ["sh", "/leanote/bin/run.sh"]
