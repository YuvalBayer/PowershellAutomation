# Powershell Automation

This repository includes powershell scripts used for automating task on a window device (11 pro).

## yml file Conda installation

I saved it from [Jeff Heaton's Github page](https://github.com/jeffheaton/t81_558_deep_learning/blob/master/install/tensorflow-install-jan-2020.ipynb) and made small modifications:

```
conda env create -v -f file_name.yml

conda activate env_name

python -m ipykernel install --user --name env_name --display-name "whatever, e.g., Python 3.7 (tensorflow)"
```
The last one is to install ipykernel and connect it with the new environment. 
According to [IPython](https://ipython.readthedocs.io/en/stable/install/kernel_install.html): "The Jupyter Notebook and other frontends automatically ensure that the IPython kernel is available. However, if you want to use a kernel with a different version of Python, or in a virtualenv or conda environment, you’ll need to install that manually."

For Tensorflow, I manually added the command of the Tensorflow extension:
```
pip install tensorflow-addons==0.14.0
```
TensorFlow Addons compatibility is described [here](https://github.com/tensorflow/addons). 

For PyTorch, including the geometric package, use manually installtion due to conflicts.

## Conda stuff

```
conda list --revisions
```

Let you see all of the environment versions (according to installations - installed packages shown as +, uninstalled shown as - and upgrades shown as ->)

The command

```
conda install --revision N
```

install your version N to the current version.