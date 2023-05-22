# Info 
## Repositories
- [Lisa's repo](https://github.com/lisambrster/DrosophilaLarvalMuscleNuclei2DStardistSegmentation)
- [Stardist repo](https://github.com/stardist/stardist)


# 1. Install anaconda from web (only done once in your computer)
- [Download](https://www.anaconda.com/download-success)
- Anaconda is an ecosistem that helps you use python and many of the most import packages (ex jupiter notebook)



# 2. Git clone lisa's repo
## 2.1. Get repo's link
- Go to lisa's repository in Github
    -  [Lisa's repo](https://github.com/lisambrster/DrosophilaLarvalMuscleNuclei2DStardistSegmentation)

- Click on green "Code" button
- Click on `HTTPS` **NOT** `Github CLI`
- Copy repo's link
```
https://github.com/lisambrster/DrosophilaLarvalMuscleNuclei2DStardistSegmentation.git
```

## 2.2 Create parent folder for repository
- Use `Finder` to create parent repository

- Name it however you want: 
    - `stardist_main`

- Right click on folder and click on 
    -  `New terminal at folder`

- Go to terminal and run `pwd` and make sure you are in the right folder

```
pwd
```

- Example output 

```
/Users/therandajashari/Documents/tj_lab_analysis/stardist_main
```

- Run git clone command, to pull files from github. Use `HTTPS` url obtained in step `2.1`

```
git clone https://github.com/lisambrster/DrosophilaLarvalMuscleNuclei2DStardistSegmentation.git
```

- Sample output
```
(base) therandajashari@Therandas-MacBook-Pro stardist_main % git clone https://github.com/lisambrster/DrosophilaLarvalMuscleNuclei2DStardistSegmentation.git
Cloning into 'DrosophilaLarvalMuscleNuclei2DStardistSegmentation'...
remote: Enumerating objects: 42, done.
remote: Counting objects: 100% (42/42), done.
remote: Compressing objects: 100% (35/35), done.
remote: Total 42 (delta 16), reused 9 (delta 1), pack-reused 0
Receiving objects: 100% (42/42), 10.09 MiB | 24.04 MiB/s, done.
Resolving deltas: 100% (16/16), done.
```

- Verify that repo was created using `ls` (list files)

```
ls
```

- Sample output
```
(base) therandajashari@Therandas-MacBook-Pro stardist_main % ls
DrosophilaLarvalMuscleNuclei2DStardistSegmentation
```


## 2.3 Open VS code
- If you want a new VS code window, use: `SHIFT + COMMAND + N`
- Cick on: `File` -> `Open`
- Look for repository `DrosophilaLarvalMuscleNuclei2DStardistSegmentation`  under parent directory: `stardist_main`


# 3. Setup conda environment for lisa' repo 
- Open terminal in VS Code, click on `Terminal -> New Terminal`  

- Check conda environments installed on you computer 
```
conda env list
```

## Create conda environment
- Example command
```
conda create -n myenv python=3.9
```
- Create our enviroment

```
conda create -n startdist_env python=3.10
```

- Each environment is a folder where there are all the dependencies and python and pip. To check where the python.pip folders are: 

```
which python
```
- example output: 

```
/Users/therandajashari/anaconda3/bin/python
```

- To check where the pip is:
```
which pip
```
 - Example output 

```
/Users/therandajashari/anaconda3/bin/pip
```

- Activate conda environment 
```
conda activate stardist_env
```
- Now you check again which python and which pip
- Example output: 

```
/Users/therandajashari/anaconda3/envs/stardist_env/bin/python
```
- Check which environemnt conda is: 
```
conda env list 
```
-Example output: 
    - The star shows the folder where conda is now: 
```
# conda environments:
#
base                     /Users/therandajashari/anaconda3
stardist_env          *  /Users/therandajashari/anaconda3/envs/stardist_env
```

# 4. Now install python `dependencies` for the environment that was activated. 

```
pip install tensorflow 
```
and 

```
pip install stardist
```

To check the packages that were installed (insluding the dependencies of the two dependencies installed):

```
pip freeze
```

# 5. Run the script for nuclei segmentation

- You are already in the directory where the input images are so no need to write out the path. This depends where you are running it from. 

```
python 2D_Stardist_prediction.py -d 'images'
```



# Setup new env for M1 macs
- [Apple silicon instructions](https://github.com/stardist/stardist#apple-silicon)

```
conda create -y -n stardist_env_m1 python=3.9 
```


```
conda activate stardist_env_m1
```


```
conda install -c apple tensorflow-deps
```

```
pip install tensorflow-macos tensorflow-metal
```

```
pip install stardist
```