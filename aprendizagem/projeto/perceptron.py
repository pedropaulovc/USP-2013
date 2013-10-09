#!/usr/bin/env python
#-*- coding=utf-8 -*-
# MAC0460 - Aprendizagem Computacional: Modelos, Algoritmos e Aplicações - 2013
# Projeto Final: Simulador gráfico do algoritmo Perceptron
# Alunos: Camila Fernandez Achutti - 6795610
#         Pedro Paulo Vezzá Campos - 7538743

from pylab import norm, rand 
import matplotlib.pyplot as plt
from time import sleep

class Perceptron:
	"""
	Classe que implementa o algoritmo Perceptron propriamente
	dito. Adaptado de:
	
	http://glowingpython.blogspot.com.br/2011/10/perceptron.html
	"""
	def __init__(self, eta, max_iterations):
		""" Construtor do objeto Perceptron, recebe a taxa de
		aprendizado (eta) e o número máximo de iterações
		que o algoritmo pode executar durante um treinamento. """
		self.w = rand(2)*2-1 # weights
		self.learningRate = eta
		self.max_iterations = max_iterations
		self.history = [list(self.w)]

	def response(self,x):
		""" Para um ponto x = [a, b] informa a classificação
		calculada pelo algoritmo. """
		y = x[0]*self.w[0]+x[1]*self.w[1] # dot product between w and x
		if y >= 0:
			return 1
		else:
			return -1

	def updateWeights(self,x,iterError):
		"""
		Atualiza o vetor de pesos, w, seguindo a fórmula
		para um tempo t + 1:
			w(t + 1) = w(t) + eta * (d - r) * x
		com d sendo o resultado desejado e r a resposta do 
		algoritmo perceptron
		"""
		self.w[0] += self.learningRate*iterError*x[0]
		self.w[1] += self.learningRate*iterError*x[1]
		self.history.append(list(self.w));

	def train(self,data):
		""" 
		Treina o algoritmo com base nos dados passados via
		parâmetro. O parâmetro é da seguinte forma:
		
		data = [
			[x1, y1, r1],
			[x2, y2, r2],
			...
		]
		"""
		learned = False
		iteration = 0
		while not learned:
			globalError = 0.0
			for x in data: # for each sample
				if iteration >= self.max_iterations:
					break
				r = self.response(x)    
				if x[2] != r: # if we have a wrong response
					iterError = x[2] - r # desired response - actual response
					self.updateWeights(x,iterError)
					globalError += abs(iterError)
					iteration += 1
					
			if globalError == 0.0 or iteration >= self.max_iterations: # stop criteria
				print 'iterations',iteration
				learned = True # stop learning
				
	def getHistory(self):
		"""
		Retorna todos os vetores de pesos produzidos durante o
		treinamento do algoritmo
		"""
		return list(self.history);
    
def generateData(n):
	""" 
	Gera dois conjuntos de dados 2D linearmente separáveis
	com n amostras. Para cada elemento, a terceira coordenada
	indica a classe do elemento.
	"""
	xb = (rand(n)*2-1)/2-0.5
	yb = (rand(n)*2-1)/2+0.5
	xr = (rand(n)*2-1)/2+0.5
	yr = (rand(n)*2-1)/2-0.5
	inputs = []
	for i in range(len(xb)):
		inputs.append([xb[i],yb[i],1])
		inputs.append([xr[i],yr[i],-1])
	return inputs
 

class PerceptronGUI:
	"""
	Classe reponsável por exibir graficamente a execução
	do algoritmo Perceptron
	"""
	def treinar(self, eta, max_iteracoes, treinamento, teste):
		"""
		Exibe a interface contendo o conjunto de dados,
		a reta separadora iniciada e as iterações do algoritmo
		até a convergência ou o limite de iterações seja
		atinjido.
		"""
		self.trainset = treinamento # train set generation
		self.perceptron = Perceptron(eta, max_iteracoes)   # perceptron instance
		self.perceptron.train(self.trainset)  # training
		self.testset = teste  # test set generation

		plt.ion()
		self.fig = plt.figure()
		self.ax = self.fig.add_subplot(111)

		# plot of the separation line.
		# The separation line is orthogonal to w
	
		self.fig.canvas.draw()
		self.ax.set_title('starting perceptron. traning data:')
	
		for y in self.trainset:
			if y[2] == 1:
				self.ax.plot(y[0], y[1], 'oc')
			else:
				self.ax.plot(y[0], y[1], 'om')

		self.fig.canvas.draw()
		sleep(2)
		self.ax.set_title('initial separation line:')
	
		w0 = self.perceptron.getHistory()[0]
		n = norm(w0)
		ww = w0/n
		ww1 = [ww[1],-ww[0]]
		ww2 = [-ww[1],ww[0]]
		self.line, = self.ax.plot([ww1[0], ww2[0]],[ww1[1], ww2[1]],'--k')
		self.fig.canvas.draw()

		sleep(2)
		for i, w in enumerate(self.perceptron.getHistory()):
			self.ax.set_title('iteration {0}'.format(i))
			sleep(2)
			n = norm(w)
			ww = w/n
			ww1 = [ww[1],-ww[0]]
			ww2 = [-ww[1],ww[0]]
			self.line.set_data([ww1[0], ww2[0]],[ww1[1], ww2[1]])
			self.fig.canvas.draw()

		self.ax.set_title('the algorithm converged in {0} iterations'.format(len(self.perceptron.getHistory()) - 1))
		self.fig.canvas.draw()
	
	def testar(self):
		"""
		Remove o conjunto de dados de treinamento e aplica a
		classificação calculada no conjunto de dados de teste.
		Exibe os dados bem e mal classificados.
		"""
		self.ax.set_title('removing training data')
		for _ in self.trainset:
			self.ax.lines.pop(0)
			self.fig.canvas.draw()
	
		self.ax.set_title('adding test data')
		# Perceptron test
		misclassified = 0
		for x in self.testset:
			r = self.perceptron.response(x)
			if r != x[2]: # if the response is not correct
				misclassified += 1
			self.ax.set_title('{0}/{1} instances misclassified'.format(misclassified, len(self.testset)))
			if x[2] == 1 and r == 1:
				self.ax.plot(x[0],x[1],'ob')  
			elif x[2] == -1 and r == -1:
				self.ax.plot(x[0],x[1],'or')
			else:
				self.ax.plot(x[0],x[1],'Dy')
			self.fig.canvas.draw()
		
		plt.show()

