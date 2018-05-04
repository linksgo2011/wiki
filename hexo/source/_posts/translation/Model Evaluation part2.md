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

DummyRegressor 允许我们的创建一个非常简单的模型，用来作为基线参考，从而可以和我们的真实模型作为对比。它是非常有用的，在系统或者产品中，去模拟一个原始存在的预测处理机制。举例来说，一个产品可能原始的硬编码了一些逻辑，更具用户特性，所有的用户将要在第一个月花费100美元。如果我们编码这些逻辑进入一个基线模型，我们从这些逻辑基础上来结合机器学习的优势。

DummyRegressor uses the strategy parameter to set the method of making predic‐
tions, including the mean or median value in the training set. Furthermore, if we set
strategy to constant and use the constant parameter, we can set the dummy
regressor to predict some constant value for every observation:

DummyRegressor 使用 strategy 参数去设置

```Python 

# Create dummy regressor that predicts 20's for everything
clf = DummyRegressor(strategy='constant', constant=20)
clf.fit(features_train, target_train)
# Evaluate score
clf.score(features_test, target_test)
-0.065105020293257265


```

One small note regarding score. By default, score returns the coefficient of determi‐
nation (R-squared, R
2
) score:

where yi
 is the true value of the target observation, yi
 is the predicted value, and ȳ is
the mean value for the target vector.
The closer R
2
is to 1, the more of the variance in the target vector that is explained by
the features.

## 11.3 Creating a Baseline Classification Model

### Problem

You want a simple baseline classifier to compare against your model.

### Solution 

Use scikit-learn’s DummyClassifier:

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

By comparing the baseline classifier to our trained classifier, we can see the improve‐
ment:

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
the training data are women, then DummyClassifier will predict women 20% of the
11.3 Creating a Baseline Classification Model | 185
time). Second, uniform will generate predictions uniformly at random between the
different classes. For example, if 20% of observations are women and 80% are men,
uniform will produce predictions that are 50% women and 50% men.


### See Also

- scikit-learn documentation: DummyClassifier (http://bit.ly/2Fr178G)

## 11.4 Evaluating Binary Classifier Predictions

### Problem

Given a trained classification model, you want to evaluate its quality.

### Solution

Use scikit-learn’s cross_val_score to conduct cross-validation while using the scor
ing parameter to define one of a number of performance metrics, including accuracy,
precision, recall, and F1
.
Accuracy is a common performance metric. It is simply the proportion of observa‐
tions predicted correctly:

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

We can measure accuracy in three-fold (the default number of folds) cross-validation
by setting scoring="accuracy":