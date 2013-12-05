#!/usr/bin/env python
#-*- coding=utf-8 -*-
# MAC0460 - Aprendizagem Computacional: Modelos, Algoritmos e Aplicações - 2013
# Projeto Final: Simulador gráfico do algoritmo Perceptron
# Alunos: Camila Fernandez Achutti - 6795610
#         Pedro Paulo Vezzá Campos - 7538743

from pylab import norm, rand 
import matplotlib.pyplot as plt
from time import sleep
from threading import Semaphore
import random

class Perceptron:
	"""
	Classe que implementa o algoritmo Perceptron propriamente
	dito. Adaptado de:
	
	http://glowingpython.blogspot.com.br/2011/10/perceptron.html
	"""
	def __init__(self, eta, max_iterations, dimension):
		""" Construtor do objeto Perceptron, recebe a taxa de
		aprendizado (eta) e o número máximo de iterações
		que o algoritmo pode executar durante um treinamento. """
		self.w = rand(dimension)*2-1 # weights
		self.learningRate = eta
		self.max_iterations = max_iterations
		self.history = [list(self.w)]
		self.dimension = dimension;

	def response(self,x):
		""" Para um ponto x = [a, b] informa a classificação
		calculada pelo algoritmo. """
		y = 0
		for i in xrange(0,self.dimension):
			y += x[i]*self.w[i]
		#y = x[0]*self.w[0]+x[1]*self.w[1] # dot product between w and x
		
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
		for i in xrange(0, self.dimension):
			self.w[i] += self.learningRate*iterError*x[i]
		self.history.append(list(self.w));

	def train(self,data):
		""" 
		Treina o algoritmo com base nos dados passados via
		parâmetro. O parâmetro é da seguinte forma:
		
		data = [
			[x1, y1, ..., r1],
			[x2, y2, ..., r2],
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
				if x[self.dimension] != r: # if we have a wrong response
					iterError = x[self.dimension] - r # desired response - actual response
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
	
def generateData(n, dimension):
	""" 
	Gera dois conjuntos de dados linearmente separáveis
	com n amostras. Para cada elemento, a terceira coordenada
	indica a classe do elemento.
	"""
	x = []
	y = []
	inputs = []
	
	for _ in range(n):
		x = []
		for i in range(dimension):
			x.append(random.uniform(0,1))
		x.append(1)
		inputs.append(x)

	for _ in range(n):
		y = []
		for i in xrange(dimension):
			y.append(random.uniform(-1, 0))
		y.append(-1)
		inputs.append(y)

	return inputs
 

class PerceptronGUI:
	"""
	Classe reponsável por exibir graficamente a execução
	do algoritmo Perceptron
	"""
	def onclick(self, event):
		# print 'button=%d, x=%d, y=%d, xdata=%f, ydata=%f'%(
		# 	event.button, event.x, event.y, event.xdata, event.ydata)
		if event.button == 1:
			categoria = 1
			cor = 'oc'
		else:
			categoria = -1
			cor = 'om'

		try:
			self.ax.plot(event.xdata, event.ydata, cor)
			self.pontos_inseridos.append([event.xdata, event.ydata, categoria])
		except:
			pass

		self.fig.canvas.draw()

	def inserir_dados_via_mouse(self, titulo):
		self.pontos_inseridos = []

		plt.ion()
		self.fig = plt.figure()
		self.ax = self.fig.add_subplot(111)
		self.ax.axis([-1,1,-1,1])
		self.ax.set_autoscale_on(False)
		self.ax.set_title(titulo)

		self.fig.canvas.mpl_connect('button_press_event', self.onclick)

		plt.show(block=True)

		return self.pontos_inseridos

	def alterar_eixos(self, x, y):
		self.x = x
		self.y = y
		if self.showing_train_data:
			data = self.trainset
		else:
			data = self.testset

		while len(self.ax.lines) > 0:
			self.ax.lines.pop(0)

		w0 = self.perceptron.getHistory()[-1]
		n = norm(w0)
		ww = w0/n
		ww1 = [ww[y],-ww[x]]
		ww2 = [-ww[y],ww[x]]
		self.line, = self.ax.plot([ww1[0], ww2[0]],[ww1[1], ww2[1]],'--k')

		for point in data:
			if self.showing_train_data:
				if point[-1] == 1:
					self.ax.plot(point[x], point[y], 'oc')
				else:
					self.ax.plot(point[x], point[y], 'om')
			else:
				r = self.perceptron.response(point)
				if point[-1] == 1 and r == 1:
					self.ax.plot(point[x],point[y],'ob')  
				elif point[-1] == -1 and r == -1:
					self.ax.plot(point[x],point[y],'or')
				else:
					self.ax.plot(point[x],point[y],'Dy')

		print 
		self.ax.set_title('axis {0}, {1}'.format(str(x + 1), str(y + 1)))
		self.fig.canvas.draw()

	def treinar(self, eta, max_iteracoes, treinamento, teste, dimension):
		"""
		Exibe a interface contendo o conjunto de dados,
		a reta separadora iniciada e as iterações do algoritmo
		até a convergência ou o limite de iterações seja
		atingido.
		"""
		self.showing_train_data = True
		self.trainset = treinamento # train set generation
		self.perceptron = Perceptron(eta, max_iteracoes, dimension)   # perceptron instance
		self.perceptron.train(self.trainset)  # training
		self.testset = teste  # test set generation
		self.x = 0
		self.y = 0

		plt.ion()
		self.fig = plt.figure()
		self.ax = self.fig.add_subplot(111)

		# plot of the separation line.
		# The separation line is orthogonal to w
	
		self.fig.canvas.draw()
		self.ax.set_title('starting perceptron. traning data:')
	
		for y in self.trainset:
			if y[dimension] == 1:
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
	
	def testar(self, dimension):
		"""
		Remove o conjunto de dados de treinamento e aplica a
		classificação calculada no conjunto de dados de teste.
		Exibe os dados bem e mal classificados.
		"""
		self.showing_train_data = False
		self.ax.set_title('removing training data')
		while len(self.ax.lines) > 0:
			self.ax.lines.pop(0)
			self.fig.canvas.draw()
		
		w0 = self.perceptron.getHistory()[-1]
		n = norm(w0)
		ww = w0/n
		ww1 = [ww[self.y],-ww[self.x]]
		ww2 = [-ww[self.y],ww[self.x]]
		self.line, = self.ax.plot([ww1[0], ww2[0]],[ww1[1], ww2[1]],'--k')
		self.fig.canvas.draw()

		self.ax.set_title('adding test data')
		# Perceptron test
		misclassified = 0
		for x in self.testset:
			r = self.perceptron.response(x)
			if r != x[dimension]: # if the response is not correct
				misclassified += 1
			self.ax.set_title('{0}/{1} instances misclassified'.format(misclassified, len(self.testset)))
			if x[dimension] == 1 and r == 1:
				self.ax.plot(x[self.x],y[self.y],'ob')  
			elif x[dimension] == -1 and r == -1:
				self.ax.plot(x[self.x],y[self.y],'or')
			else:
				self.ax.plot(x[self.x],y[self.y],'Dy')
			self.fig.canvas.draw()
		
		plt.show()

