---
title: Model Evaluation
categories: translation
---

## 11.0 Introduction

## 简介

In this chapter we will examine strategies for evaluating the quality of models created
through our learning algorithms. It might appear strange to discuss model evaluation
before discussing how to create them, but there is a method to our madness. Models
are only as useful as the quality of their predictions, and thus fundamentally our goal
is not to create models (which is easy) but to create high-quality models (which is
hard). Therefore, before we explore the myriad learning algorithms, we first set up
how we can evaluate the models they produce.


在这一章中，我们要来探讨评估策略，以此筛选通过我们学习算法创建的模型。在讨论怎么创建模型之前就讨论模型的评估，这看起来有点奇怪，但不失为一种大胆的方法。模型存在的意义是被用来做出高质量的预测，因此基本上来说，我们的目标不是创建模型（简单的），而是创建高质量的模型（困难的）。因此在我们毫无目标的在海量的学习算法中寻找之前，我们首先需要确定我们怎么去评估通过这些算法创建的模型。

## 11.1 Cross-Validating Models

## 11.1 交互验证模型

### Problem 
### 问题

You want to evaluate how well your model will work in the real world.

你想要在真实世界中验证你的模型工作的足够好。

### Solution
### 解决方案

Create a pipeline that preprocesses the data, trains the model, and then evaluates it
using cross-validation:

创建一个预处理数据的流水线，然后训练这个模型，最后使用交互验证来评估：

```python

# Load libraries
from sklearn import datasets
from sklearn import metrics
from sklearn.model_selection import KFold, cross_val_score
from sklearn.pipeline import make_pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler
# Load digits dataset

digits = datasets.load_digits()
# Create features matrix
features = digits.data
# Create target vector
target = digits.target
# Create standardizer
standardizer = StandardScaler()
# Create logistic regression object
logit = LogisticRegression()
# Create a pipeline that standardizes, then runs logistic regression
pipeline = make_pipeline(standardizer, logit)
# Create k-Fold cross-validation
kf = KFold(n_splits=10, shuffle=True, random_state=1)
# Conduct k-fold cross-validation
cv_results = cross_val_score(pipeline, # Pipeline
 features, # Feature matrix
 target, # Target vector
 cv=kf, # Cross-validation technique
 scoring="accuracy", # Loss function
 n_jobs=-1) # Use all CPU scores
# Calculate mean
cv_results.mean()
0.96493171942892597

```

### Discussion
### 讨论

At first consideration, evaluating supervised-learning models might appear straight‐
forward: train a model and then calculate how well it did using some performance
metric (accuracy, squared errors, etc.). However, this approach is fundamentally
flawed. If we train a model using our data, and then evaluate how well it did on that
data, we are not achieving our desired goal. Our goal is not to evaluate how well the
model does on our training data, but how well it does on data it has never seen before
(e.g., a new customer, a new crime, a new image). For this reason, our method of
evaluation should help us understand how well models are able to make predictions
from data they have never seen before.


第一个考虑，评估监督学习模型可能表现的很直接：训练一个模型然后通过使用一些性能指标来计算它的表现（准确性、均方误差，等等）。然而这种方式有一个基本的缺陷。如果我们用我们的数据去训练一个模型，然后用同样的数据评估它的表现，这样达不到我们的期望目标。我们的目标不是在我们的训练数据上评估模型，而应该是是用它从来没见过的数据来评估（比如，一个新的消费者、一次新的犯罪或者一张新的图片）。由于这些原因，我们的评估方法应该帮助我们去理解这些模型是否足够好的从未知的数据中去做出预测。


One strategy might be to hold off a slice of data for testing. This is called validation
(or hold-out). In validation our observations (features and targets) are split into two
sets, traditionally called the training set and the test set. We take the test set and put it
off to the side, pretending that we have never seen it before. Next we train our model
using our training set, using the features and target vector to teach the model how to make the best prediction. Finally, we simulate having never before seen external data
by evaluating how our model trained on our training set performs on our test set.
However, the validation approach has two major weaknesses. First, the performance
of the model can be highly dependent on which few observations were selected for
the test set. Second, the model is not being trained using all the available data, and
not being evaluated on all the available data.

一种策略可以是保留一部分数据用来测试模型。这种方法被称作校验（或者叫留出法）。在实际验证中，我们把处理的对象数据（特征或者目标）分割成两部分，传统上被称作训练集和测试集。我们取出测试集然后放到一边，假装我们从来没遇到过这些数据。下一步我们可以使用训练集来训练我们的模型，使用特征和目标向量来教会模型如何做出最好的预测。最终我们使用测试集来模拟从来没有遇到过的外部数据，来评估我们的模型训练结果。然而这种校验方法有两个主要的缺陷。首先，模型的性能高度依赖我们选出的少量测试数据。其次，模型没有被所有数据有效的训练，也没有被所有的有效数据校验。


A better strategy, which overcomes these weaknesses, is called k-fold cross-validation
(KFCV). In KFCV, we split the data into k parts called “folds.” The model is then
trained using k – 1 folds—combined into one training set—and then the last fold is
used as a test set. We repeat this k times, each time using a different fold as the test
set. The performance on the model for each of the k iterations is then averaged to
produce an overall measurement.
In our solution, we conducted k-fold cross-validation using 10 folds and outputted
the evaluation scores to cv_results: 

一个被称作k-fold 交叉验证（KFCV）的方法能够克服这些缺点。在KFCV中，我们分割这些数据为k组，我们叫它为"叠"。然后使用k-1叠数据来训练模型，然后用最后一叠数据校验。然后我们重复K次，每一次都可以使用不同的叠作为测试数据来校验模型。我们取每一次模型被训练的结果来进行平均处理，然后得到一个整体的衡量结果。

在我们的方案中，应用KFCV思想，我们通过分割出10叠数据然后输出评估得分到变量cv_results：

```python

# View score for all 10 folds
cv_results
array([ 0.97222222, 0.97777778, 0.95555556, 0.95 , 0.95555556,
 0.98333333, 0.97777778, 0.96648045, 0.96089385, 0.94972067])

```

There are three important points to consider when we are using KFCV. First, KFCV
assumes that each observation was created independent from the other (i.e., the data
is independent identically distributed [IID]). If the data is IID, it is a good idea to
shuffle observations when assigning to folds. In scikit-learn we can set shuffle=True
to perform shuffling.

当我们使用KFCV思想来训练模型时，这里有三个重要的关键点。首先KFCV数据采样是被独立创建的（例如，数据是独立同分布的[IID]）.
如果数据是满足IID原则，那么拆分数据叠的时候，打乱叠的顺序会是一个好主意。在 scikit-learn 中，，我们可以设置变量shuffle为true来进行打乱操作。

Second, when we are using KFCV to evaluate a classifier, it is often beneficial to have
folds containing roughly the same percentage of observations from each of the differ‐
ent target classes (called stratied k-fold). For example, if our target vector contained
gender and 80% of the observations were male, then each fold would contain 80%
male and 20% female observations. In scikit-learn, we can conduct stratified k-fold
cross-validation by replacing the KFold class with StratifiedKFold.
Finally, when we are using validation sets or cross-validation, it is important to pre‐
process data based on the training set and then apply those transformations to both
the training and test set. For example, when we fit our standardization object, stand
ardizer, we calculate the mean and variance of only the training set. Then we apply
that transformation (using transform) to both the training and test sets:

其次，当我们使用KFCV来评估一个分类器时，

```python

# Import library
from sklearn.model_selection import train_test_split
# Create training and test sets
features_train, features_test, target_train, target_test = train_test_split(
 features, target, test_size=0.1, random_state=1)
11.1 Cross-Validating Models | 181
# Fit standardizer to training set
standardizer.fit(features_train)
# Apply to both training and test sets
features_train_std = standardizer.transform(features_train)
features_test_std = standardizer.transform(features_test)

```

The reason for this is because we are pretending that the test set is unknown data. If
we fit both our preprocessors using observations from both training and test sets,
some of the information from the test set leaks into our training set. This rule applies
for any preprocessing step such as feature selection.
scikit-learn’s pipeline package makes this easy to do while using cross-validation tech‐
niques. We first create a pipeline that preprocesses the data (e.g., standardizer) and
then trains a model (logistic regression, logit):


```python

# Create a pipeline
pipeline = make_pipeline(standardizer, logit)
Then we run KFCV using that pipeline and scikit does all the work for us:
# Do k-fold cross-validation
cv_results = cross_val_score(pipeline, # Pipeline
 features, # Feature matrix
 target, # Target vector
 cv=kf, # Cross-validation technique
 scoring="accuracy", # Loss function

```

cross_val_score comes with three parameters that we have not discussed that are
worth noting. cv determines our cross-validation technique. K-fold is the most com‐
mon by far, but there are others, like leave-one-out-cross-validation where the num‐
ber of folds k equals the number of observations. The scoring parameter defines our
metric for success, a number of which are discussed in other recipes in this chapter.
Finally, n_jobs=-1 tells scikit-learn to use every core available. For example, if your
computer has four cores (a common number for laptops), then scikit-learn will use
all four cores at once to speed up the operation.

### See Also

- Why every statistician should know about cross-validation (http://bit.ly/2Fzhz6X)
- Cross-Validation Gone Wrong (http://bit.ly/2FzfIiw)

