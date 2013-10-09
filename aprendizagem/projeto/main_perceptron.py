#!/usr/bin/env python
#-*- coding=utf-8 -*-
# MAC0460 - Aprendizagem Computacional: Modelos, Algoritmos e Aplicações - 2013
# Projeto Final: Simulador gráfico do algoritmo Perceptron
# Alunos: Camila Fernandez Achutti - 6795610
#         Pedro Paulo Vezzá Campos - 7538743

import pygtk
import gtk
import perceptron
import csv

if gtk.pygtk_version < (2,3,90):
   print "PyGtk 2.3.90 or later required for this example"
   raise SystemExit

class Main:
	"""Classe que contém a interface gráfica com o usuário.
	Desenha a interface, trata os eventos e carrega o
	algoritmo Perceptron principal."""
	def destruir_janela(self, widget, data=None):
		"""Trata o evento de fechamento da janela principal"""
		gtk.main_quit()
	
	def obter_opcao_entrada(self):
		"""Retorna a forma de entrada escolhida pelo usuário.
		
		Valores de retorno possíveis: ["Método de entrada",
		"Arquivo externo", "Sorteio aleatório",
		"Clique com o mouse"]"""
		model = self.metodos_entrada.get_model()
		index = self.metodos_entrada.get_active()
		
		return model[index][0]
	
	def tratar_opcao_entrada(self, combobox):
		"""Trata o evento de mudança na forma de entrada
		escolhida pelo usuário.
		
		Caso seja escolhido via arquivos externos, abre as
		janelas de escolha de arquivos necessárias."""
		model = combobox.get_model()
		index = combobox.get_active()
		if not index:
			return
		if model[index][0] == "Arquivo externo":
			self.exibir_aviso(
				"Forneça o arquivo de\n\nTREINAMENTO\n\nno formato CSV com três colunas: (x, y, classe = (-1 ou 1))", gtk.MESSAGE_INFO)
			resultado = self.arquivo_treinamento.run()
			self.arquivo_treinamento.hide()
			if resultado == gtk.RESPONSE_OK:
				self.caminho_arquivo_treinamento = self.arquivo_treinamento.get_filename()
			elif resultado == gtk.RESPONSE_CANCEL:
				self.metodos_entrada.set_active(0)
				return
			
			self.exibir_aviso(
				"Forneça o arquivo de\n\nTESTE\n\nno formato CSV com três colunas: (x, y, classe = (-1 ou 1))", gtk.MESSAGE_INFO)
			resultado = self.arquivo_teste.run()
			self.arquivo_teste.hide()
			if resultado == gtk.RESPONSE_OK:
				self.caminho_arquivo_teste = self.arquivo_teste.get_filename()
			elif resultado == gtk.RESPONSE_CANCEL:
				self.metodos_entrada.set_active(0)
	
	def exibir_aviso(self, texto, tipo=gtk.MESSAGE_ERROR):
		"""Exibe um aviso na forma de popup.
		
		Parâmetros: o texto a ser exibido e a severidade do
		aviso."""
		aviso = gtk.MessageDialog(type=tipo, buttons=gtk.BUTTONS_CLOSE)
		aviso.set_markup(texto)
		aviso.run()
		aviso.destroy()

	def criar_menu_metodos_entrada(self):
		"""Cria uma combobox para a escolha
		da forma de entrada dos dados no programa."""
		opcoes = ["Método de entrada", "Arquivo externo", "Sorteio aleatório", "Clique com o mouse"]
		entrada = gtk.combo_box_new_text()
		for o in opcoes:
			entrada.append_text(o)
		entrada.set_active(0)
		entrada.connect('changed', self.tratar_opcao_entrada)
		return entrada
	
	def criar_janela_escolha_arquivo(self):
		"""Cria uma nova janela de escolha de arquivo"""
		return gtk.FileChooserDialog("Abrir..",
									None,
									gtk.FILE_CHOOSER_ACTION_OPEN,
									(gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL,
									gtk.STOCK_OPEN, gtk.RESPONSE_OK))
	
	def criar_campo_entrada(self, texto):
		"""Cria um novo campo de entrada de texto com valor
		default definido via parâmetro."""
		campo = gtk.Entry()
#		campo.connect("activate", self.enter_callback, entry)
		campo.set_max_length(5)
		campo.set_text(texto)
		return campo

	def criar_botao(self, texto, tratador):
		"""Cria um novo botão com o texto e o tratador de
		evento de clique definidos via parâmetro."""
		botao = gtk.ToggleButton(texto)
		botao.connect("clicked", tratador)
		return botao
	
	def criar_label(self, texto):
		"""Retorna uma label contendo o texto passado via
		parâmetro"""
		return gtk.Label(texto)
	
	def treinar_perceptron(self, event):
		"""Trata o evento de clique no botão de treinamento.
		Carrega os dados de entrada e invoca o simulador."""
		entrada_escolhida = self.obter_opcao_entrada()
		if entrada_escolhida == "Método de entrada":
			self.exibir_aviso("Escolha o método de entrada de dados")
			return
		
		eta = float(self.eta.get_text())
		max_iteracoes = int(self.num_iteracoes.get_text())
		
		if entrada_escolhida == "Arquivo externo":
			with open(self.caminho_arquivo_treinamento, 'rb') as arq_csv:
				reader = csv.reader(arq_csv)
				treinamento = [[float(x), float(y), int(z)] for [x,y,z] in reader]
			
			with open(self.caminho_arquivo_teste, 'rb') as arq_csv:
				reader = csv.reader(arq_csv)
				teste = [[float(x), float(y), int(z)] for [x,y,z] in reader]
		else:
			treinamento = perceptron.generateData(30)
			teste = perceptron.generateData(20)
		
		self.perceptron_gui = perceptron.PerceptronGUI()
		self.perceptron_gui.treinar(eta, max_iteracoes, treinamento, teste)
		self.botao_testar.set_sensitive(True)
	
	def testar_perceptron(self, event):
		"""Trata o evento de clique no botão de teste do
		algoritmo. Invoca a rotina correspondente do simulador."""
		self.perceptron_gui.testar()
		self.botao_testar.set_sensitive(False)
#		try:
#			self.perceptron_gui.testar()
#		except:
#			self.exibir_aviso("Treine o perceptron antes!")
	
	def __init__(self):
		"""Construtor da interface gráfica. Desenha todos os
		elementos visuais e cadastra os respectivos tratadores
		de eventos."""
		window = gtk.Window(gtk.WINDOW_TOPLEVEL)
		window.set_size_request(400, 300)
		window.set_title("Perceptron")
		window.connect("delete_event", lambda w,e: gtk.main_quit())

		vbox = gtk.VBox(False, 0)
		window.add(vbox)
		vbox.show()
		
		self.metodos_entrada = self.criar_menu_metodos_entrada()
		self.arquivo_treinamento = self.criar_janela_escolha_arquivo()
		self.arquivo_teste = self.criar_janela_escolha_arquivo()
		vbox.pack_start(self.metodos_entrada, True, True, 0)
		self.metodos_entrada.show()

		hbox = gtk.HBox(False, 0)
		vbox.add(hbox)
		hbox.show()
		
		self.label_eta = self.criar_label("eta")
		hbox.pack_start(self.label_eta, True, True, 0)
		self.label_eta.show()
		
		self.eta = self.criar_campo_entrada("1")
		hbox.pack_start(self.eta, True, True, 0)
		self.eta.show()
		
		self.label_iteracoes = self.criar_label("máx iterações")
		hbox.pack_start(self.label_iteracoes, True, True, 0)
		self.label_iteracoes.show()
		
		self.num_iteracoes = self.criar_campo_entrada("100")
		hbox.pack_start(self.num_iteracoes, True, True, 0)
		self.num_iteracoes.show()
		
		self.botao_treinar = self.criar_botao("Treinar", self.treinar_perceptron )
		vbox.pack_start(self.botao_treinar, True, True, 0)
		self.botao_treinar.show()
		
		self.botao_testar = self.criar_botao("Testar", self.testar_perceptron )
		vbox.pack_start(self.botao_testar, True, True, 0)
		self.botao_testar.set_sensitive(False)
		self.botao_testar.show()
		
		window.show()

	def main(self):
		"""Inicia o laço eterno da biblioteca gráfica."""
		gtk.main()

if __name__ == "__main__":
	main = Main()
	main.main()
