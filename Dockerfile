FROM dockerfile/go

RUN \
  apt-get update && \
  apt-get install -y mercurial meld && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir -p /gopath/src/github.com/google/cayley
RUN mkdir -p /opt/cayley

RUN go get github.com/badgerodon/peg \
  github.com/barakmich/glog \
  github.com/julienschmidt/httprouter \
  github.com/petar/GoLLRB/llrb \
  github.com/peterh/liner \
  github.com/robertkrimen/otto \
  github.com/russross/blackfriday \
  github.com/syndtr/goleveldb/leveldb \
  github.com/syndtr/goleveldb/leveldb/cache \
  github.com/syndtr/goleveldb/leveldb/iterator \
  github.com/syndtr/goleveldb/leveldb/opt \
  github.com/syndtr/goleveldb/leveldb/util \
  github.com/boltdb/bolt \
  gopkg.in/mgo.v2 \
  gopkg.in/mgo.v2/bson
  # github.com/cznic/mathutil \

RUN \
  git clone -q https://github.com/cznic/mathutil /gopath/src/github.com/cznic/mathutil && \
  cd /gopath/src/github.com/cznic/mathutil && \
  go build .

RUN git clone -q https://github.com/bkendall/cayley /gopath/src/github.com/google/cayley
WORKDIR /gopath/src/github.com/google/cayley
RUN git checkout fix-mongo-cache-no-tests

RUN go build .
EXPOSE 64210

RUN wget -qO- https://bootstrap.pypa.io/get-pip.py | python
RUN pip install supervisor
ADD ./supervisord.conf /supervisord.conf

CMD ["supervisord", "-n", "-c", "/supervisord.conf"]
