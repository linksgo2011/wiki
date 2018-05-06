---
title: Creating a Baseline Regression Model
categories: translation
---

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

使用 scikit-learn 的DummyClassifier

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

strategy 参数给了我们大量选项去生成值。这里有两个特别有用的策略。 首先是stratified使得预测让目标矢量属性在训练集中成比例分布（例如，如果训练集中，20%的调查对象是女性，DummyClassifier将当次预测出20%为女性）。其次是uniform，这种方式将生成预测均匀的在不同类中随机生成。距离俩说，如果观察对象包含了20%的女性和80%的男性，uniform将生成预测结果为50%的女性和50%的男性。

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

当使用scoring单数来定义大量性能指标中的一个时，使用 scikit-learn 的cross_val_score去实现交叉验证，包括准确率，精确率，召回率，F值。
准确率是一个常用性能指标。它是简单的计算正确预测的调查对象比值。

{公式}

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

解释：

- TP是真阳性的采样数量，采样中具有正向类型的（患有疾病，购买了产品等等）并且我们的预测正确。
- TN是真阴性的采样数量，采样中具有负向类型的（没有患有疾病，没有购买产品等等）并且我们预测正确。
- FP是假阳性的采样数量，又被成为I型错误。采样中被预测为正向分类但是实际上为负向分类的。
- FN是假阴性的采样数量，又被称为II型错误，采样中被预测为负向类型，但实际上为正向分类的。


We can measure accuracy in three-fold (the default number of folds) cross-validation
by setting scoring="accuracy":

我们能通过设置scoring参数为accuracy来衡量accuracy在三个"叠"（默认数量）的交叉验证：
