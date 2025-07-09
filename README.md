
This project is a docker environment for the UC Irvine / Secure Systems Lab Multicompiler

The project hasn't been maintained in many years, so the build enviornment depends on old libraries and environments until it can be updated to current. 

To build the docker image: 
```
./build.sh 
```
or
```
docker build -t multicompiler .
```

To run and mount a workspace directory: 
```
./run.sh
```
or
``` 
docker run -it -v $(pwd)/workspace:/workspace multicompiler
```


To compile with clang and basic options and no randomization
```
clang -o output.bin source.c 
```

To compile with clang and diversification options
```
clang \
  -fno-stack-protector \
  -frandom-seed=1234 \
  -mllvm -randomize-machine-registers \
  -mllvm -shuffle-stack-frames \
  -mllvm -shuffle-globals \
  -mllvm -randomize-function-list \
  -Xclang -nop-insertion \
  -o output.bin \ 
  source.c 
```


LTO may need additional pre-requisites installed
```
clang \
    -flto \
    -Wl,-plugin-opt=random-seed="$SEED" \
    -Wl,-plugin-opt=randomize-function-list \
    -Wl,-plugin-opt=randomize-machine-registers \
    -Wl,-plugin-opt=shuffle-stack-frames \
    -Wl,-plugin-opt=shuffle-globals \
    -Wl,-plugin-opt=nop-insertion \
    -o output.bin \
    source.c
```

