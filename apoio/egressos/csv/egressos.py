import psycopg2
import csv
import re

def make_csv(coluna, cur):
	
	cur.execute(
	"""SELECT grupo , "{0}" , COUNT( * )
	FROM completos
	GROUP BY grupo , "{0}"
	ORDER BY grupo, "{0}\"""".format(coluna))
	
	resultado = cur.fetchall()
	
	nome_arquivo = re.sub(r'[^A-Za-z0-9_]', r'', coluna)
	with open(nome_arquivo + '.csv', 'wb') as arq:
		writer = csv.writer(arq)
		writer.writerow(["grupo", coluna, "COUNT(*)"])
		writer.writerows(resultado)

colunas = ['em_que_tipo_de_escola_cursou_o_ensino_medio',
 'fez_cursinho_para_entrar',
 'em_que_ano_concluiu_o_bcc',
 'grupo',
 'fez_estagio_durante_o_bcc',
 '[o_estagio_atrapalhou_o_bcc]_relacao_entre_o_estagio_e_o_bcc',
 '[o_bcc_atrapalhou_o_estagio]_relacao_entre_o_estagio_e_o_bcc',
 '[ambos_se_complementaram]_relacao_entre_o_estagio_e_o_bcc',
 '[outros]_relacao_entre_o_estagio_e_o_bcc',
 '[nao_houve_contribuicao]_contribuicoes_do_estagio',
 '[aperfeicoamento_em_computacao]_contribuicoes_do_estagio',
 '[emprego_na_empresa_que_estagiou]_contribuicoes_do_estagio',
 '[emprego_outra_empresa]_contribuicoes_do_estagio',
 '[experiencia_profissional]_contribuicoes_do_estagio',
 '[outros]_contribuicoes_do_estagio',
 'fez_ic_durante_o_bcc',
 '[ic_atrapalhou_o_bcc]_relacao_entre_a_ic_e_o_bcc',
 '[bcc_atrapalhou_a_ic]_relacao_entre_a_ic_e_o_bcc',
 '[ambos_se_complementaram]_relacao_entre_a_ic_e_o_bcc',
 '[outros]_relacao_entre_a_ic_e_o_bcc',
 '[nao_houve_contribuicao]_contribuicoes_da_ic',
 '[aperfeicoamento_em_computacao]_contribuicoes_da_ic',
 '[emprego_em_empresa]_contribuicoes_da_ic',
 '[outros]_contribuicoes_da_ic',
 '[nao]_realizou_outro_curso_alem_do_bcc',
 '[graduacao]_realizou_outro_curso_alem_do_bcc',
 '[pos_graduacao]_realizou_outro_curso_alem_do_bcc',
 '[especializacao]_realizou_outro_curso_alem_do_bcc',
 'apos_o_bcc_sentiu_se_estimulado_a_continuar_os_seus_estudos',
 'sem_levar_em_consideracao_o_estagio,_trabalhou_durante_o_bcc',
 '[trabalho_atrapalhou_o_bcc]_relacao_entre_o_trabalho_e_o_bcc',
 '[bcc_atrapalhou_o_trabalho]_relacao_entre_o_trabalho_e_o_bcc',
 '[ambos_se_complementaram]_relacao_entre_o_trabalho_e_o_bcc',
 '[outros]_relacao_entre_o_trabalho_e_o_bcc',
 '[nao_houve_contribuicao]_contribuicoes_do_trabalho',
 '[aperfeicoamento_em_computacao]_contribuicoes_do_trabalho',
 '[emprego_em_outra_empresa]_contribuicoes_do_trabalho',
 '[experiencia_profissional]_contribuicoes_do_trabalho',
 '[outros]_contribuicoes_do_trabalho',
 'por_quantos_anos_trabalhou_em_computacao_depois_de_se_formar',
 '[analista_de_sistema]_atividade_exercida_logo_apos_se_formar',
 '[consultor]_atividade_exercida_logo_apos_se_formar',
 '[pos_graduando]_atividade_exercida_logo_apos_se_formar',
 '[professor]_atividade_exercida_logo_apos_se_formar',
 '[programador]_atividade_exercida_logo_apos_se_formar',
 '[trainee]_atividade_exercida_logo_apos_se_formar',
 '[outros]_atividade_exercida_logo_apos_se_formar',
 'se_sentiu_preparado_para_o_mercado_logo_apos_se_formar',
 'trabalha_na_area_de_computacao',
 '[pesquisa]trabalha_em_qual_tipo_de_atividade',
 '[software_para_terceiros]trabalha_em_qual_tipo_de_atividade',
 '[consultoria]trabalha_em_qual_tipo_de_atividade',
 '[software_propria_empresa]trabalha_em_qual_tipo_de_atividade',
 '[educacao/treinamento]trabalha_em_qual_tipo_de_atividade',
 '[empreendedorismo]trabalha_em_qual_tipo_de_atividade',
 '[outros]trabalha_em_qual_tipo_de_atividade',
 '[universidade_qual_setor_se_encaixa_a_empresa_que_trabalha',
 '[industria_qual_setor_se_encaixa_a_empresa_que_trabalha',
 '[servicos_qual_setor_se_encaixa_a_empresa_que_trabalha',
 '[financeiro_qual_setor_se_encaixa_a_empresa_que_trabalha',
 '[comercio_qual_setor_se_encaixa_a_empresa_que_trabalha',
 '[outros_qual_setor_se_encaixa_a_empresa_que_trabalha',
 'classifique_seu_trabalho_atual',
 'situacao_financeira',
 'satisfacao_profissional',
 'satisfacao_social',
 'satisfacao_pessoal',
 '[escolheria_outra_profissao]_reavaliando_opcoes',
 '[cursaria_outro_curso]_reavaliando_opcoes',
 '[escolheria_mesma_profissao]_reavaliando_opcoes',
 '[cursaria_o_bcc_novamente]_reavaliando_opcoes',
 '[faria_mais_estagios]_reavaliando_opcoes',
 '[participaria_de_seminarios]_reavaliando_opcoes',
 '[participaria_em_conferencias]_reavaliando_opcoes',
 '[seguiria_a_carreira_academica]_reavaliando_opcoes',
 '[faria_graduacao_adicional]_reavaliando_opcoes',
 '[faria_mais_cursos_de_extensao]_reavaliando_opcoes',
 '[sairia_do_pais_para_estudo]_reavaliando_opcoes',
 '[faria_mais_cursos_de_linguas]_reavaliando_opcoes',
 '[sairia_do_pais_para_trabalho]_reavaliando_opcoes',
 '[optaria_profissao_mais_rentavel]_reavaliando_opcoes',
 '[optaria_trabalho_mais_agradavel]_reavaliando_opcoes',
 'utilidade_bcc',
 'utilidade_matematica',
 'utilidade_probabilidade_ou_estatistica',
 'utilidade_fisica',
 'utilidade_teoricas',
 'utilidade_sistemas',
 'o_utilidade_no_estagio_para_a_sua_atividade_profissional',
 'considera_que_a_formacao_teorica_do_bcc_foi',
 'considera_que_a_formacao_pratica_do_bcc_foi']
 
conn = psycopg2.connect("host=data.ime.usp.br port=23001 user=u7538743 password=... dbname=bd_7538743")
cur = conn.cursor()


