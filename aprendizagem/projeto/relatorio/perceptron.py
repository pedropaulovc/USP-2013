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
				if x[self.dimension] != r:
					iterError = x[self.dimension] - r 
					self.updateWeights(x,iterError)
					globalError += abs(iterError)
					iteration += 1
			#critério de parada		
			if globalError == 0.0 or iteration >= self.max_iterations:
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