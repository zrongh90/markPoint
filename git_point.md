1、在初始化一个远程仓库时使用git init --bare而非git init。因为git init --bare方法创建了一个裸库，只保留git的提交信息，不允许用户在上面进行操作，这样更符合远程仓库的理念。
	git init is for working.git init --bare is for sharing
	
2、git config --global core.quotepath false(不会对0x80以上的字符进行quote),--global配置文件对应于某一用户(例如tmpusr)，其配置文件位于~/.gitconfig
	[tmpusr@ansible ~]$ cat .gitconfig 
	[user]
		email = huangzr@drcbank.com
	[core]
		quotepath = false
	[i18n]
		logOutputEncoding = utf-8
		commitEncoding = utf-8
