/*******************************************************************************
 * Laboratório de Bancos de Dados - 2013
 * Aluno: Pedro Paulo Vezzá Campos - 7538743
 * Aula 16: Permissões
 ******************************************************************************/
 
/* Exercício: You are the DBA for the VeryFine Toy Company and create a relation called Employees with
fields ename, dept, and salary. For authorization reasons, you also define views EmployeeNames (with
ename as the only attribute) and DeptInfo with fields dept and avgsalary. The latter lists the average
salary for each department. */
--1. Show the view definition statements for EmployeeNames and DeptInfo.

/*** NOTA: Tabela Employees utilizada para fins de teste ***/
CREATE TABLE Employees (
ename varchar(20),
dept varchar(20),
salary int4
);

CREATE VIEW EmployeeNames AS
SELECT ename
FROM Employees;

CREATE VIEW DeptInfo AS
SELECT dept, AVG(salary)
FROM Employees
GROUP BY dept;

--2. What privileges should be granted to a user who needs to know only average department salaries
--    for the Toy and CS departments?

CREATE VIEW CSToyInfo AS
SELECT dept, AVG(salary)
FROM Employees
WHERE dept = 'Toy' OR dept = 'CS'
GROUP BY dept;

GRANT SELECT ON CSToyInfo TO usuario;

--3. You want to authorize your secretary to fire people (you will probably tell him whom to fire, but
--    you want to be able to delegate this task), to check on who is an employee, and to check on
--    average department salaries. What privileges should you grant?

GRANT SELECT, DELETE ON EmployeeNames TO secretary;
GRANT SELECT ON DeptInfo TO secretary;


--4. Continuing with the preceding scenario, you do not want your secretary to be able to look at the
--    salaries of individuals. Does your answer to the previous question ensure this? Be specific: Can
--    your secretary possibly find out salaries of some individuals (depending on the actual set of
--    tuples), or can your secretary always find out the salary of any individual he wants to?

Sim. A secretária só tem acesso ao nome dos funcionários e médias dos departamentos. Como ela não sabe
quantos funcionários um departamento tem, não tem como inferir o salário de um indivíduo.

--5. You want to give your secretary the authority to allow other people to read the EmployeeNames
--view. Show the appropriate command.

GRANT SELECT ON EmployeeNames TO secretary WITH GRANT OPTION;

--6. Your secretary defines two new views using the EmployeeNames view. The first is called
--    AtoRNames and simply selects names that begin with a letter in the range A to R. The second is
--    called HowManyNames and counts the number of names. You are so pleased with this
--    achievement that you decide to give your secretary the right to insert tuples into the
--    EmployeeNames view. Show the appropriate command and describe what privileges your
--    secretary has after this command is executed.

Devemos criar um trigger e uma stored procedure para gerenciar a inserção na view:

CREATE OR REPLACE FUNCTION InsertEmployeeName()
RETURNS TRIGGER AS $InsertEmployeeName$
BEGIN
   INSERT INTO Employees(ename, dept, salary) VALUES (NEW.ename, NULL, NULL);
   RETURN NEW;
END;
$InsertEmployeeName$ LANGUAGE plpgsql;

CREATE TRIGGER Insert_employee_name INSTEAD OF INSERT ON EmployeeNames
FOR EACH ROW
EXECUTE PROCEDURE InsertEmployeeName();

GRANT INSERT ON EmployeeNames TO secretary;

Após o GRANT, a secretária poderá inserir novos valores na relação EmployeeNames,
atualizando consequentemente a relação Employee.

--7. Your secretary allows Todd to read the EmployeeNames relation and later quits. You then revoke
--    the secretary’s privileges. What happens to Todd’s privileges?

Os privilégios de Todd são removidos. Não há mais um caminho no grafo de
autorização entre o dono da relação (O DBA) e Todd.

--8. Give an example of a view update on the preceding schema that cannot be implemented through
--    updates to Employees.

Não compreendi o enunciado do exercício.

--9. You decide to go on an extended vacation, and to make sure that emergencies can be handled,
--    you want to authorize your boss Joe to read and modify the Employees relation and the
--    EmployeeNames relation (and Joe must be able to delegate authority, of course, since he is too
--    far up the management hierarchy to actually do any work). Show the appropriate SQL
--    statements. Can Joe read the DeptInfo view?

GRANT SELECT, UPDATE ON Employees TO joe WITH GRANT OPTION;

GRANT SELECT, UPDATE ON EmployeeNames TO joe WITH GRANT OPTION;

Apesar de Joe poder simular o resultado da View DeptInfo (Só precisa saber a
consulta que gera a view) ele não tem acesso autorizado à relação DeptInfo
especificamente.


--10. After returning from your (wonderful) vacation, you see a note from Joe, indicating that he
--    authorized his secretary Mike to read the Employees relation. You want to revoke Mike’s
--    SELECT privilege on Employees, but you do not want to revoke the rights you gave to Joe, even
--    temporarily. Can you do this in SQL?

Mesmo sendo o DBA, revogar os direitos de Mike pelo terminal (REVOKE SELECT ON Employees FROM mike)
não tem o efeito desejado. Mantendo a restrição de que não queremos alterar as
permissões de Joe, apenas ele pode remover as permissões de Mike.


--11. Later you realize that Joe has been quite busy. He has defined a view called AllNames using the
--    view EmployeeNames, defined another relation called StaffNames that he has access to (but you
--    cannot access), and given his secretary Mike the right to read from the AllNames view. Mike has
--    passed this right on to his friend Susan. You decide that, even at the cost of annoying Joe by
--    revoking some of his privileges, you simply have to take away Mike and Susan’s rights to see
--    your data. What REVOKE statement would you execute? What rights does Joe have on
--    Employees after this statement is executed? What views are dropped as a consequence?

REVOKE SELECT ON EmployeeNames FROM joe;
GRANT SELECT ON EmployeeNames TO joe WITH GRANT OPTION; 

Supondo que StaffNames é uma relação e não uma view, a primeira linha é suficiente
para desabilitar e remover a view AllNames sem afetar StaffNames. Como consequência, Mike e Susan perdem
o acesso automaticamente aos dados já que a view AllNames não existe mais.
O acesso à relação Employees não é afetado.

A segunda linha retorna o estado das autorizações de Joe como estava anteriormente.

