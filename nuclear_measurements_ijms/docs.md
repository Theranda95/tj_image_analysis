# Setup Github repository 

## Create repo 
- Once you create repository, get the URL (https://github.com/Theranda95/tj_image_analysis.git)


## Setup repo on Mac
- Go to location where you want to set it up

```
git clone https://github.com/Theranda95/tj_image_analysis.git
```


# Terminal Commands

## Create folder
- Use keyword mkdir 

```
mkdir testing
```


## Check files under one folder
```
ls
```


## Check absolute 
- pwd (path to current directory)
```
pwd
```


# Git Commands

- Check the status of your files

```
git status
```

- Add the files so you can keep track of changes
```
git add <name_of_file_1> <name_of_file_2> ...
```

```
git add .
```


## Git commit 
- Write message for changes 

```
git commit -m "First commit"
```


## Git log
- Check the commits that you have done
```
git log
```


## Git push
- Upload code to github

```
git push
```
## When you need to quit 

```
q
```
## Removing a file (as deleting it from the local folder) 
```
rm filename
```
## Removing deleted files from git 

```
git rm
```

## Create .gitignore to omit files from being tracked by git
```
touch .gitgnore
```

- Write in .gitgnore files what you want to ignore
```
*.pdf
*.docx
*.txt
```
