FROM amberframework/amber:v0.9.0

WORKDIR /app

COPY shard.* /app/
RUN shards install 

COPY . /app

RUN rm -rf /app/node_modules

CMD amber watch
