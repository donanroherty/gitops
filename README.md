## Creating a self-hosted Github Action runner

```sh
mkdir actions-runner && cd actions-runner
curl -o actions-runner-osx-x64-2.314.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.314.1/actions-runner-osx-x64-2.314.1.tar.gz
echo "3faff4667d6d12c41da962580168415d628e3ffba9924b9ac995752087efc921  actions-runner-osx-x64-2.314.1.tar.gz" | shasum -a 256 -c
tar xzf ./actions-runner-osx-x64-2.314.1.tar.gz

./config.sh --url https://github.com/donanroherty/gitops --token ABKOX7ZPRKKJ3KJYLE5MYITF635IA
./run.sh
```