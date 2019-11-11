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


在这一章中，我们将探讨评估策略，以此筛选通过我们学习算法创建的模型。在讨论怎么创建模型之前就讨论模型的评估，这看起来有点奇怪，但不失为一种大胆的方法。模型存在的意义是被用来做出高质量的预测，因此基本上来说，我们的目标不是创建模型（简单的），而是创建高质量的模型（困难的）。因此在我们毫无目标的在海量的学习算法中寻找之前，我们首先需要确定我们怎么去评估通过这些算法创建的模型。

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

创建一个预处理数据的流水线，训练这个模型，然后使用交互验证来评估：

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


首先要考虑一点，评估监督学习模型可能表现的很直接：训练一个模型然后通过使用一些性能指标来计算它的表现（准确性、均方误差，等等）。然而这种方式有一个基本的缺陷。如果我们用我们的数据去训练一个模型，然后用同样的数据评估它的表现，这样达不到我们的验证目标。我们的目标不是在我们的训练数据上评估模型，而应该是用它从来没见过的数据来评估（比如，一个新的消费者、一次新的犯罪或者一张新的图片）。由于这些原因，我们的评估方法应该帮助我们去理解这些模型是否足够好的从未知数据中去做出预测。


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

其中一种策略可以是保留一部分数据用来测试模型。这种方法被称作校验（或者叫留出法）。在实际验证中，我们把我们的采样数据（特征或者目标）分割成两部分，传统上我们叫它们训练集和测试集。我们取出测试集然后放到一边，假装我们从来没遇到过这些数据。下一步我们可以使用训练集来训练我们的模型，使用特征和目标向量来教会模型如何做出最好的预测。最终我们使用测试集来模拟从来没有遇到过的外部数据，来评估我们的模型训练结果。然而这种校验方法有两个主要的缺陷。首先，模型的性能高度依赖我们选出来作为测试集的采样数据。其次，模型没有被所有数据有效的训练，也没有被所有的有效数据校验。


A better strategy, which overcomes these weaknesses, is called k-fold cross-validation
(KFCV). In KFCV, we split the data into k parts called “folds.” The model is then
trained using k – 1 folds—combined into one training set—and then the last fold is
used as a test set. We repeat this k times, each time using a different fold as the test
set. The performance on the model for each of the k iterations is then averaged to
produce an overall measurement.
In our solution, we conducted k-fold cross-validation using 10 folds and outputted
the evaluation scores to cv_results: 

一个更好的策略，被称作 k-fold 交叉验证（KFCV）的方法能够克服这些缺点。在KFCV中，我们分割这些数据为k组，我们叫它为"叠"。然后使用k-1叠数据来训练模型，然后用最后一叠做数据校验。我们通过重复K次，使得每一次都可以使用不同的叠作为测试数据来校验模型。我们取每一次模型被训练的结果来进行平均处理，然后得到一个整体的衡量结果。

在我们的方案中，应用KFCV思想，我们通过分割出10叠数据然后输出评估得分到变量 cv_results 中：

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

当我们使用KFCV思想来训练模型时，这里有三个重要的关键点。首先KFCV假定每个采样数据是独立于其它采样创建的（例如，数据是独立同分布的[IID]）.
如果数据是满足IID原则，那么拆分数据叠的时候，打乱叠的顺序会是一个好主意。在 scikit-learn 中，，我们可以设置变量shuffle为true来进行打乱操作。

Second, when we are using KFCV to evaluate a classifier, it is often beneficial to have
folds containing roughly the same percentage of observations from each of the differ‐
ent target classes (called stratied k-fold). For example, if our target vector contained
gender and 80% of the observations were male, then each fold would contain 80%
male and 20% female observations. In scikit-learn, we can conduct stratified k-fold
cross-validation by replacing the KFold class with StratifiedKFold.
Finally, when we are using validation sets or cross-validation, it is important to pre‐
process data based on the training set and then apply those transformations to both
the training and test set. For example, when we fit our standardization object, stand
ardizer, we calculate the mean and variance of only the training set. Then we apply
that transformation (using transform) to both the training and test sets:

其次，当我们使用 KFCV 来评估一个分类器时，它的优势在于粗略的对采样数据按照不同目标类以相同比例来划分 "叠"（被称作分层 k-fold）。举个例子，如果我们目标矢量包含了性别并且80%的采样数据是男性，那么每个"叠"应该包含80%男性和20%的女性采样数据。
在 scikit-learn 框架中，我们能通过使用 StratifiedKFold 类替换 KFold，即可实现分层 k-fold 交叉验证。最终当我们使用验证数据集或者交叉验证，最重要的是根据训练集去预处理数据，然后应用这些同样的处理方式到训练集和测试集。举例来说，当我们用 fit 操作我们的 standardization 对象和 standardizer 时，我们仅对训练集来计算平方差和方差。然后我们应用这些变换（使用transform 方法）对训练集和测试集都进行处理：

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

这么做的原因是我们假装测试数据是未知的。如果我们使用来自训练集和测试集的采样数据对我们的预处理器 fit 操作，那么一些信息就会从测试集泄露进训练集。这个规则应用于任何预处理流程，例如特性选择。当使用交叉验证技术时，scikit-learn 的 pipeline 包让这些变得非常简单。我们首先创建一个流水线去预处理这些数据（例如，standardizer） 然后训练这些我们的模型（逻辑回归，logit算法）:


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

cross_val_score 方法需要三个参数，我们没有讨论但是这里值得一提，cv 决定我们的交叉验证技术。K-fold 是目前最通用的技术，但是还是有一些其他技术可以选择，比如创建和采样数据个数相同"叠"的 leave-one-out-cross-validation 。scoring 参数定义了我们对成功的衡量标准，我们将会在本章中其他小节大量讨论。最后，n_jobs=-1 是告诉 scikit-learn 去使用每一个可用的CPU核心。举例来说，如果你的计算机有四个核心（笔记本通常的配置），然后 scikit-learn 将使用四个全部核心来加速运行。

### See Also

- Why every statistician should know about cross-validation (http://bit.ly/2Fzhz6X)
- Cross-Validation Gone Wrong (http://bit.ly/2FzfIiw)

### 查看更多

- 为什么数据科学家都应该知道交叉验证 (http://bit.ly/2Fzhz6X)
- 交叉验证走在错误的道路上 (http://bit.ly/2FzfIiw)

## 11.2 Creating a Baseline Regression Model

## 11.2 创建一个基线回归模型

### Problem
You want a simple baseline regression model to compare against your model

你需要创建一个基线回归模型来和你的模型对比



### Solution

Use scikit-learn’s DummyRegressor to create a simple model to use as a baseline

使用 scikit-learn 的 DummyRegressor 来创建一个简单模型作为基准对比使用

```Python


# Load libraries
from sklearn.datasets import load_boston
from sklearn.dummy import DummyRegressor
from sklearn.model_selection import train_test_split
# Load data
boston = load_boston()
# Create features
features, target = boston.data, boston.target
# Make test and training split
features_train, features_test, target_train, target_test = train_test_split(
 features, target, random_state=0)
# Create a dummy regressor
dummy = DummyRegressor(strategy='mean')
# "Train" dummy regressor
dummy.fit(features_train, target_train)
# Get R-squared score
dummy.score(features_test, target_test)
-0.0011193592039553391


```

To compare, we train our model and evaluate the performance score:
来对比，我们训练我们的模型然后进行性能评分：

```Python 

# Load library
from sklearn.linear_model import LinearRegression
# Train simple linear regression model
ols = LinearRegression()
ols.fit(features_train, target_train)
# Get R-squared score
ols.score(features_test, target_test)
0.63536207866746675

```

### Discussion

### 讨论

DummyRegressor allows us to create a very simple model that we can use as a baseline
to compare against our actual model. This can often be useful to simulate a “naive”
existing prediction process in a product or system. For example, a product might
have been originally hardcoded to assume that all new users will spend $100 in the
first month, regardless of their features. If we encode that assumption into a baseline
model, we are able to concretely state the benefits of using a machine learning
approach.

DummyRegressor 允许我们的创建一个非常简单的模型，用来作为基线参考，从而可以和我们的真实模型作为对比。在一个系统或者产品中，它是非常有用的去模拟一个原始存在的预测处理机制。举例来说，一个软件产品可能通过传统的方式被硬编码的方式编写了一些程序逻辑，根据用户特性，假定所有的用户将要在第一个月花费100美元。如果我们编写这个假设进入一个基线模型，我们能实实在在的看到机器学习技术被加入到软件中的优势。

DummyRegressor uses the strategy parameter to set the method of making predic‐
tions, including the mean or median value in the training set. Furthermore, if we set
strategy to constant and use the constant parameter, we can set the dummy
regressor to predict some constant value for every observation:

DummyRegressor 使用 strategy 参数去设置做出预测的方法，包括在返回一个测试集中的均值或中值。此外，如果我们设置strategy参数为constant 并且使用 constant 参数，DummyRegressor 会固定返回传给 constant 参数的值。

```Python 

# Create dummy regressor that predicts 20's for everything
clf = DummyRegressor(strategy='constant', constant=20)
clf.fit(features_train, target_train)
# Evaluate score
clf.score(features_test, target_test)
-0.065105020293257265


```

One small note regarding score. By default, score returns the coefficient of determi‐
nation (R-squared, R) score:


where yi is the true value of the target observation, yi is the predicted value, and ȳ is the mean value for the target vector. The closer R 2
is to 1, the more of the variance in the target vector that is explained by the features.


顺带提一下性能得分的计算方法，默认情况下，返回的分值为测定结果（R-squared, `$R^2$`）得分的系数：

这里的 `$y_i$` 是目标采样数据为真的值，`$\hat{y_i}$` 为预测值， `$\overline{y}$` 为目标向量的平均值。

`$R^2$` 越是趋近于1，说明在目标矢量中越多的变化越能被特征解释。

`$R^2 =  1-  \frac{ \sum(y_i-\hat{y_i}) }{\sum(y_i-\overline{y_i}) } $`


## 11.3 Creating a Baseline Classification Model

### Problem

You want a simple baseline classifier to compare against your model.

你需要一个简单的基线分类器去对比你的模型

### Solution 

Use scikit-learn’s DummyClassifier:

使用 scikit-learn 的 DummyClassifier

```Python

# Load libraries
from sklearn.datasets import load_iris
from sklearn.dummy import DummyClassifier
from sklearn.model_selection import train_test_split
# Load data
iris = load_iris()
# Create target vector and feature matrix
features, target = iris.data, iris.target
# Split into training and test set
features_train, features_test, target_train, target_test = train_test_split(
features, target, random_state=0)
# Create dummy classifier
dummy = DummyClassifier(strategy='uniform', random_state=1)
# "Train" model
dummy.fit(features_train, target_train)
# Get accuracy score
dummy.score(features_test, target_test)
0.42105263157894735

```

By comparing the baseline classifier to our trained classifier, we can see the improvement:

通过把训练后的分类器和基线分类器进行对比，我们能看到这些提升:


```python


# Load library
from sklearn.ensemble import RandomForestClassifier
# Create classifier
classifier = RandomForestClassifier()
# Train model
classifier.fit(features_train, target_train)
# Get accuracy score
classifier.score(features_test, target_test)
0.94736842105263153

```

### Discussion

A common measure of a classifier’s performance is how much better it is than ran‐
dom guessing. scikit-learn’s DummyClassifier makes this comparison easy. The strat
egy parameter gives us a number of options for generating values. There are two par‐
ticularly useful strategies. First, stratified makes predictions that are proportional
to the training set’s target vector’s class proportions (i.e., if 20% of the observations in
the training data are women, then DummyClassifier will predict women 20% of the time).
 Second, uniform will generate predictions uniformly at random between the
different classes. For example, if 20% of observations are women and 80% are men,
uniform will produce predictions that are 50% women and 50% men.

一个通常的做法去衡量分类器工作的有多好的方式是把它的结果和随机猜测对比。scikit-learn 的DummyClassifier让这项比较变得简单。

strategy 参数为我们生成值提供了大量选项。这里有两个特别有用的策略。 首先是 stratified 使做出的虚拟预测让目标矢量属性在训练集中成比例分布（例如，如果训练集中，20%的采样数据是女性，DummyClassifier 将当次预测出20%为女性。其次是 uniform，这种方式将生成预测均匀的在不同类中随机生成。举例来说，如果观察对象包含了20%的女性和80%的男性，uniform 将生成预测结果为50%的女性和50%的男性。

### See Also

### 查看更多

- scikit-learn documentation: DummyClassifier (http://bit.ly/2Fr178G)
- scikit-learn 文档：DummyClassifier (http://bit.ly/2Fr178G)


## 11.4 Evaluating Binary Classifier Predictions

## 11.4 评估二元分类器预测

### Problem

### 问题

Given a trained classification model, you want to evaluate its quality.

给定一个训练后的分类器模型，你需要评估它的质量

### Solution

### 方案


Use scikit-learn’s cross_val_score to conduct cross-validation while using the scor
ing parameter to define one of a number of performance metrics, including accuracy,
, recall, and F1.
Accuracy is a common performance metric. It is simply the proportion of observa‐
tions predicted correctly:

当使用 scoring 参数来定义大量性能指标中的一个时，使用 scikit-learn 的 cross_val_score 去实现交叉验证，包括准确率，精确率，召回率，F值。
准确率是一个常用性能指标。它是简单的计算正确预测的采样数据比值。

`$ Accuracy = \frac{TP + TN}{TP + TN + FP + FN} $ `

where:

- TP is the number of true positives. Observations that are part of the positive class
  (has the disease, purchased the product, etc.) and that we predicted correctly.
- TN is the number of true negatives. Observations that are part of the negative
  class (does not have the disease, did not purchase the product, etc.) and that we
  predicted correctly.
- FP is the number of false positives. Also called a Type I error. Observations pre‐
  dicted to be part of the positive class that are actually part of the negative class.
- FN is the number of false negatives. Also called a Type II error. Observations pre‐
  dicted to be part of the negative class that are actually part of the positive class.

这里：

- TP是真阳性的采样数量，采样中具有正向类型的（患有疾病，购买了产品等等）并且我们的预测正确。
- TN是真阴性的采样数量，采样中具有负向类型的（没有患有疾病，没有购买产品等等）并且我们预测正确。
- FP是假阳性的采样数量，又被成为I型错误。采样中被预测为正向分类但是实际上为负向分类的。
- FN是假阴性的采样数量，又被称为II型错误，采样中被预测为负向类型，但实际上为正向分类的。


We can measure accuracy in three-fold (the default number of folds) cross-validation
by setting scoring="accuracy":

我们能通过设置scoring参数为accuracy来衡量accuracy在三个"叠"（默认数量）的交叉验证：