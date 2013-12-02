#/usr/bin/env python
#-*-coding=utf_8-*-
#
# MAC0460/4832 - Aprendizagem Computacional: Modelos, Algoritmos e Aplicações - 2013
# Exercício prático 3: Classificador k-NN, matriz de confusão
# 
# Aluno: Pedro Paulo Vezzá Campos - 7538743

from sklearn import datasets, neighbors, linear_model
from sklearn.cross_validation import train_test_split
from sklearn.metrics import confusion_matrix

import pylab as pl

# 3.0. Carregar o dataset DIGITS
# 3.1. selecionar dados de c classes (5 <= c <= 10)
# Foram escolhidas 7 classes para este exercício (Parâmetro da função load_digits)
digits = datasets.load_digits(7)

dados = digits.data
classes = digits.target

# 3.2. dividir os dados em treinamento / teste (eventualmente, testar diferentes divisões)
# O conjunto de dados foi dividido em 10% de dados para treinamento e 90% para teste
tamanho_treino = 0.2

divisao = train_test_split(dados, classes, train_size=tamanho_treino)
dados_treino, dados_teste, classes_treino, classes_teste = divisao

# 3.3. aplicar o classificador k-NN no conjunto de teste (variar eventualmente o k)
# O algoritmo vai ser aplicado para k = 7 vizinhos
knn = neighbors.KNeighborsClassifier(n_neighbors=7)

knn.fit(dados_treino, classes_treino)
resultado = knn.score(dados_teste, classes_teste)

print('Acurácia média do KNN: %f' % resultado)

# 3.4. plotar a matriz de confusão (e a visualização gráfica da mesma)

classes_resultado = knn.predict(dados_teste)

matriz_confusao = confusion_matrix(classes_teste, classes_resultado)
print(matriz_confusao)

pl.matshow(matriz_confusao)
pl.title(u'Matriz de Confusão')
pl.colorbar()
pl.ylabel(u'Classe verdadeira')
pl.xlabel(u'Classe prevista')
pl.show()

