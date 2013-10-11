#!/usr/bin/env python
#-*- coding=utf-8 -*-
import csv
import os
import os.path
import re

template_grafico = '''
\\begin{{figure}}[h]\\centering
\\begin{{tikzpicture}}\\begin{{axis}}[
    ybar stacked,
    legend style={{
        legend columns={1},
        at={{(xticklabel cs:0.5)}},
        anchor=north,
        draw=none
    }},
    xtick=data,
    width=0.7\\textwidth,
    symbolic x coords={{? -- ?,1974 -- 1978,1979 -- 1983,1984 -- 1988,1989 -- 1993,1994 -- 1998,1999 -- 2003,2004 -- 2008,2009 -- 2013}},
    x tick label style={{rotate=45,anchor=east}},
]
{0}
\\legend{{{2}}}
\\end{{axis}}\\end{{tikzpicture}}
\\caption{{{3}}}
\\end{{figure}}
'''

template_resposta = '\\addplot[{0},fill={0}] coordinates {{ {1} }};'

cores = {
	'Pública':'verde',
	'Parte em escola pública e parte em escola privada':'laranja',
	'Particular':'azul',
	'Sim':'verde',
	'Não':'vermelho',
	'O estágio interferiu de forma negativa no BCC':'vermelho',
	'O BCC interferiu de forma negativa no estágio':'laranja',
	'Ambos se complementaram':'verde',
	'Muito estimulado':'azul',
	'Parcialmente estimulado':'verde',
	'Pouco estimulado':'laranja',
	'Nada estimulado':'vermelho',
	'Não me inseri no mercado de trabalho':'violeta',
	'Totalmente':'azul',
	'Muito':'verde',
	'Razoavelmente':'laranja',
	'Mais ou menos':'amarelo',
	'Pouco':'laranja',
	'Nada':'vermelho',
	'Satisfatório':'azul',
	'Pouco satisfatório':'laranja',
	'Insatisfatório':'vermelho',
	'Não sei':'violeta',
	'Suficiente':'azul',
	'Deficiente':'vermelho',
	'Sem resposta': 'violeta',
	'N/A': 'violeta'
}

ordem_cores = {
	'violeta': 0, #Para Sem resposta, N/A, etc...
	'vermelho': 1,
	'laranja': 2,
	'amarelo': 3,
	'verde': 4,
	'azul': 5,
}

geracoes = [
	'? -- ?',
	'1974 -- 1978',
	'1979 -- 1983',
	'1984 -- 1988',
	'1989 -- 1993',
	'1994 -- 1998',
	'1999 -- 2003',
	'2004 -- 2008',
	'2009 -- 2013'
]

pos_geracao = {
	'? -- ?':0,
	'1974 -- 1978':1,
	'1979 -- 1983':2,
	'1984 -- 1988':3,
	'1989 -- 1993':4,
	'1994 -- 1998':5,
	'1999 -- 2003':6,
	'2004 -- 2008':7,
	'2009 -- 2013':8,
}

arquivos = ['em_que_tipo_de_escola_cursou_o_ensino_medio',
 'fez_cursinho_para_entrar',
 'em_que_ano_concluiu_o_bcc',
 'grupo',
 'fez_estagio_durante_o_bcc',
 'o_estagio_atrapalhou_o_bcc_relacao_entre_o_estagio_e_o_bcc',
 'o_bcc_atrapalhou_o_estagio_relacao_entre_o_estagio_e_o_bcc',
 'ambos_se_complementaram_relacao_entre_o_estagio_e_o_bcc',
 'outros_relacao_entre_o_estagio_e_o_bcc',
 'nao_houve_contribuicao_contribuicoes_do_estagio',
 'aperfeicoamento_em_computacao_contribuicoes_do_estagio',
 'emprego_na_empresa_que_estagiou_contribuicoes_do_estagio',
 'emprego_outra_empresa_contribuicoes_do_estagio',
 'experiencia_profissional_contribuicoes_do_estagio',
 'outros_contribuicoes_do_estagio',
 'fez_ic_durante_o_bcc',
 'ic_atrapalhou_o_bcc_relacao_entre_a_ic_e_o_bcc',
 'bcc_atrapalhou_a_ic_relacao_entre_a_ic_e_o_bcc',
 'ambos_se_complementaram_relacao_entre_a_ic_e_o_bcc',
 'outros_relacao_entre_a_ic_e_o_bcc',
 'nao_houve_contribuicao_contribuicoes_da_ic',
 'aperfeicoamento_em_computacao_contribuicoes_da_ic',
 'emprego_em_empresa_contribuicoes_da_ic',
 'outros_contribuicoes_da_ic',
 'nao_realizou_outro_curso_alem_do_bcc',
 'graduacao_realizou_outro_curso_alem_do_bcc',
 'pos_graduacao_realizou_outro_curso_alem_do_bcc',
 'especializacao_realizou_outro_curso_alem_do_bcc',
 'apos_o_bcc_sentiu_se_estimulado_a_continuar_os_seus_estudos',
 'sem_levar_em_consideracao_o_estagio_trabalhou_durante_o_bcc',
 'trabalho_atrapalhou_o_bcc_relacao_entre_o_trabalho_e_o_bcc',
 'bcc_atrapalhou_o_trabalho_relacao_entre_o_trabalho_e_o_bcc',
 'ambos_se_complementaram_relacao_entre_o_trabalho_e_o_bcc',
 'outros_relacao_entre_o_trabalho_e_o_bcc',
 'nao_houve_contribuicao_contribuicoes_do_trabalho',
 'aperfeicoamento_em_computacao_contribuicoes_do_trabalho',
 'emprego_em_outra_empresa_contribuicoes_do_trabalho',
 'experiencia_profissional_contribuicoes_do_trabalho',
 'outros_contribuicoes_do_trabalho',
 'por_quantos_anos_trabalhou_em_computacao_depois_de_se_formar',
 'analista_de_sistema_atividade_exercida_logo_apos_se_formar',
 'consultor_atividade_exercida_logo_apos_se_formar',
 'pos_graduando_atividade_exercida_logo_apos_se_formar',
 'professor_atividade_exercida_logo_apos_se_formar',
 'programador_atividade_exercida_logo_apos_se_formar',
 'trainee_atividade_exercida_logo_apos_se_formar',
 'outros_atividade_exercida_logo_apos_se_formar',
 'se_sentiu_preparado_para_o_mercado_logo_apos_se_formar',
 'trabalha_na_area_de_computacao',
 'pesquisatrabalha_em_qual_tipo_de_atividade',
 'software_para_terceirostrabalha_em_qual_tipo_de_atividade',
 'consultoriatrabalha_em_qual_tipo_de_atividade',
 'software_propria_empresatrabalha_em_qual_tipo_de_atividade',
 'educacaotreinamentotrabalha_em_qual_tipo_de_atividade',
 'empreendedorismotrabalha_em_qual_tipo_de_atividade',
 'outrostrabalha_em_qual_tipo_de_atividade',
 'universidade_qual_setor_se_encaixa_a_empresa_que_trabalha',
 'industria_qual_setor_se_encaixa_a_empresa_que_trabalha',
 'servicos_qual_setor_se_encaixa_a_empresa_que_trabalha',
 'financeiro_qual_setor_se_encaixa_a_empresa_que_trabalha',
 'comercio_qual_setor_se_encaixa_a_empresa_que_trabalha',
 'outros_qual_setor_se_encaixa_a_empresa_que_trabalha',
 'classifique_seu_trabalho_atual',
 'situacao_financeira',
 'satisfacao_profissional',
 'satisfacao_social',
 'satisfacao_pessoal',
 'escolheria_outra_profissao_reavaliando_opcoes',
 'cursaria_outro_curso_reavaliando_opcoes',
 'escolheria_mesma_profissao_reavaliando_opcoes',
 'cursaria_o_bcc_novamente_reavaliando_opcoes',
 'faria_mais_estagios_reavaliando_opcoes',
 'participaria_de_seminarios_reavaliando_opcoes',
 'participaria_em_conferencias_reavaliando_opcoes',
 'seguiria_a_carreira_academica_reavaliando_opcoes',
 'faria_graduacao_adicional_reavaliando_opcoes',
 'faria_mais_cursos_de_extensao_reavaliando_opcoes',
 'sairia_do_pais_para_estudo_reavaliando_opcoes',
 'faria_mais_cursos_de_linguas_reavaliando_opcoes',
 'sairia_do_pais_para_trabalho_reavaliando_opcoes',
 'optaria_profissao_mais_rentavel_reavaliando_opcoes',
 'optaria_trabalho_mais_agradavel_reavaliando_opcoes',
 'utilidade_bcc',
 'utilidade_matematica',
 'utilidade_probabilidade_ou_estatistica',
 'utilidade_fisica',
 'utilidade_teoricas',
 'utilidade_sistemas',
 'o_utilidade_no_estagio_para_a_sua_atividade_profissional',
 'considera_que_a_formacao_teorica_do_bcc_foi',
 'considera_que_a_formacao_pratica_do_bcc_foi'] 

def mapear_resposta_cor(resposta, totais):
	"""
	Entrada:
		resposta = 'Muito estimulado'
		totais = [('? -- ?', '2'), ('1974 -- 1978', '2'), ('1979 -- 1983', '5')]
	Saída:
		('azul', '(? -- ?, 2) (1974 -- 1978, 2), (1979 -- 1983, 5)')
	"""
	#Garantindo que todos os totais considerem todas as gerações existentes
	totais_completo = [(g, 0) for g in geracoes]
	for geracao, total in totais:
		totais_completo[pos_geracao[geracao]] = (geracao, total)

	return (cores[resposta], ' '.join(['({0}, {1})'.format(*t) for t in totais_completo]))

def gerar_codigo(pergunta, legenda):
	plots = [mapear_resposta_cor(resposta, totais) for resposta, totais in pergunta.iteritems()]
	plots.sort(key=lambda item: ordem_cores[item[0]])
	
	string_plots = '\n'.join([template_resposta.format(*p) for p in plots])
	string_ordem_itens = ','.join(sorted(pergunta.keys(), key=lambda x: ordem_cores[cores[x]]))
	
	return template_grafico.format(string_plots, 3, string_ordem_itens, legenda)


def mapear_grupo(id):
	id = int(id)
	if id == -1:
		return '? -- ?'
	return '' + str(1969 + id * 5) + ' -- ' + str(1973 + id * 5)


if __name__ == '__main__':
	for arquivo in arquivos:
		print '%' * 80
		print '%' * 80
		print '\section{' + arquivo + '}'
		with open('./csv/' + arquivo + '.csv', 'rb') as arq_csv:
			reader = csv.reader(arq_csv)
			linhas = list(reader)
	
		linhas.pop(0)
		pergunta = {}
		try:
			for l in linhas:
				if l[1] == '':
					l[1] = 'Sem resposta'
				if l[1] not in pergunta:
					pergunta[l[1]] = []
				pergunta[l[1]].append((mapear_grupo(l[0]), l[2]))

			print gerar_codigo(pergunta, arquivo)
			print "\clearpage"
		except:
			print "ERRO"
			
