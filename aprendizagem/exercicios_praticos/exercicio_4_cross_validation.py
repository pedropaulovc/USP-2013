#/usr/bin/env python
#-*-coding=utf_8-*-
#
# MAC0460/4832 - Aprendizagem Computacional: Modelos, Algoritmos e Aplicações - 2013
# Exercício prático 4: Cross-validation
# 
# Aluno: Pedro Paulo Vezzá Campos - 7538743


from sklearn import datasets, metrics, cross_validation
from sklearn.svm import SVC
from sklearn.naive_bayes import GaussianNB

# 4.0. Carregar o dataset IRIS
iris = datasets.load_iris()

# 4.1. escolher um tipo de classificador
classificador = GaussianNB()

# 4.2. aplicar a validação cruzada 5-fold
resultado = cross_validation.cross_val_score(classificador, iris.data, iris.target, cv=5)

# 4.3. imprimir acurácia média
print("Acurácia média: %0.2f (+/- %0.2f)" % (resultado.mean(), resultado.std() * 2))
