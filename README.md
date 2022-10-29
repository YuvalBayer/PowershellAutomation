# Powershell Automation

This repository includes powershell scripts used for automating task on a window device (11 pro).

## Tensorflow Conda installation

I saved it from [Jeff Heaton's Github page](https://github.com/jeffheaton/t81_558_deep_learning/blob/master/install/tensorflow-install-jan-2020.ipynb):

```
conda env create -v -f tensorflow.yml

conda activate tensorflow

python -m ipykernel install --user --name tensorflow --display-name "Python 3.7 (tensorflow)"
```
The last one is to install ipykernel and connect it with the new environment. 
According to [IPython](https://ipython.readthedocs.io/en/stable/install/kernel_install.html): "The Jupyter Notebook and other frontends automatically ensure that the IPython kernel is available. However, if you want to use a kernel with a different version of Python, or in a virtualenv or conda environment, you’ll need to install that manually."

I manually added the command of the Tensorflow extension:

```
pip install tensorflow-addons==0.14.0
```
TensorFlow Addons compatibility is described [here](https://github.com/tensorflow/addons). 