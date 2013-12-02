#/usr/bin/env python
#-*-coding=utf_8-*-
#
# MAC0460/4832 - Aprendizagem Computacional: Modelos, Algoritmos e Aplicações - 2013
# Exercício prático 2: PCA
# 
# Aluno: Pedro Paulo Vezzá Campos - 7538743


from sklearn import datasets
from sklearn.decomposition import PCA

import pylab as pl

# 2.0. Carregar o dataset DIGITS
digits = datasets.load_digits()

# 2.1. mostrar uma observação (matriz 8x8) do dataset
pl.matshow(digits.images[0]) 
pl.gray()
pl.show() 

# 2.2. selecionar c classes (2 <= c < 10)

digits_0_a_4 = datasets.load_digits(5)


# 2.3. calcular o PCA relativamente às classes selecionadas, e selecionar
#      as duas primeiras componentes

apos_pca = PCA(n_components=2).fit_transform(digits_0_a_4.data)

# 2.4. plotar os dados selecionados usando essas duas componentes

pl.figure(1, figsize=(8, 6))
pl.clf()

pl.scatter(apos_pca[:, 0], apos_pca[:, 1], c=digits_0_a_4.target, cmap=pl.cm.Paired)
pl.title(u"Primeiras duas direções PCA, dígitos de 0 a 4")
pl.xlabel(u"1o autovetor")
pl.ylabel(u"2o autovetor")

x_min, x_max = apos_pca[:, 0].min() - .5, apos_pca[:, 0].max() + .5
y_min, y_max = apos_pca[:, 1].min() - .5, apos_pca[:, 1].max() + .5

pl.xlim(x_min, x_max)
pl.ylim(y_min, y_max)
pl.xticks(())
pl.yticks(())

# 2.5. eventualmente, repetir o processo para outra seleção de classes

digits_5_a_9 = datasets.load_digits(10)
indices = digits_5_a_9.target >= 5

digits_5_a_9.data = digits_5_a_9.data[indices]
digits_5_a_9.target = digits_5_a_9.target[indices]
digits_5_a_9.images = digits_5_a_9.images[indices]


# 2.5.1. calcular o PCA relativamente às classes selecionadas, e selecionar
#      as duas primeiras componentes

apos_pca = PCA(n_components=2).fit_transform(digits_5_a_9.data)

# 2.5.2. plotar os dados selecionados usando essas duas componentes

pl.figure(2, figsize=(8, 6))
pl.clf()

pl.scatter(apos_pca[:, 0], apos_pca[:, 1], c=digits_5_a_9.target, cmap=pl.cm.Paired)
pl.title(u"Primeiras duas direções PCA, dígitos de 5 a 9")
pl.xlabel(u"1o autovetor")
pl.ylabel(u"2o autovetor")

x_min, x_max = apos_pca[:, 0].min() - .5, apos_pca[:, 0].max() + .5
y_min, y_max = apos_pca[:, 1].min() - .5, apos_pca[:, 1].max() + .5

pl.xlim(x_min, x_max)
pl.ylim(y_min, y_max)
pl.xticks(())
pl.yticks(())

pl.show()
