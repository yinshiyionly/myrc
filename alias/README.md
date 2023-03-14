### 这里是一些别名文件

docker 的别名文件 alias-for-docker.alias
git    的别名文件 alias-for-git.alias

### how to usage

```bash
# step1  软链 .alias 目录
$ sudo ln -s $PWD/alias ~/.alias

# step2  使系统加载
# in ~/.bashrc or ~/.zshrc
echo "source ~/.alias/alias-for-docker.alias\nsource ~/.alias/alias-for-git.alias" >> ~/.bashrc
```
