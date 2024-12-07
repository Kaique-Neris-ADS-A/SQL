
CREATE OR REPLACE PACKAGE PKG_ALUNO AS
    -- Procedure para exclusão de aluno
    PROCEDURE EXCLUIR_ALUNO (p_id_aluno IN NUMBER);

    -- Cursor para listar alunos maiores de 18 anos
    PROCEDURE LISTAR_ALUNOS_MAIORES_18 (cur_alunos OUT SYS_REFCURSOR);

    -- Cursor parametrizado para alunos de um curso específico
    PROCEDURE LISTAR_ALUNOS_POR_CURSO (p_id_curso IN NUMBER, cur_curso OUT SYS_REFCURSOR);
END PKG_ALUNO;
/





CREATE OR REPLACE PACKAGE BODY PKG_ALUNO AS
    -- Procedure para exclusão de aluno
    PROCEDURE EXCLUIR_ALUNO (p_id_aluno IN NUMBER) IS
    BEGIN
        -- Excluir matrículas associadas ao aluno
        DELETE FROM matricula
        WHERE id_aluno = p_id_aluno;

        -- Excluir o aluno
        DELETE FROM aluno
        WHERE id_aluno = p_id_aluno;

        COMMIT; -- Confirma as alterações
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; -- Desfaz alterações em caso de erro
            RAISE; -- Relança o erro para análise
    END EXCLUIR_ALUNO;

    -- Cursor para listar alunos maiores de 18 anos
    PROCEDURE LISTAR_ALUNOS_MAIORES_18 (cur_alunos OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN cur_alunos FOR
        SELECT nome, data_nascimento
        FROM aluno
        WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, data_nascimento) / 12) > 18;
    END LISTAR_ALUNOS_MAIORES_18;

    -- Cursor parametrizado para alunos de um curso específico
    PROCEDURE LISTAR_ALUNOS_POR_CURSO (p_id_curso IN NUMBER, cur_curso OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN cur_curso FOR
        SELECT DISTINCT a.nome
        FROM aluno a
        INNER JOIN matricula m ON a.id_aluno = m.id_aluno
        INNER JOIN disciplina d ON m.id_disciplina = d.id_disciplina
        WHERE d.id_curso = p_id_curso;
    END LISTAR_ALUNOS_POR_CURSO;
END PKG_ALUNO;
/





CREATE OR REPLACE PACKAGE PKG_DISCIPLINA AS
    -- Procedure para cadastrar uma nova disciplina
    PROCEDURE CADASTRAR_DISCIPLINA(p_nome IN VARCHAR2, p_descricao IN CLOB, p_carga_horaria IN NUMBER);

    -- Cursor para total de alunos por disciplina
    PROCEDURE TOTAL_ALUNOS_POR_DISCIPLINA(cur_disciplinas OUT SYS_REFCURSOR);

    -- Cursor para média de idade por disciplina
    PROCEDURE MEDIA_IDADE_DISCIPLINA(p_id_disciplina IN NUMBER, cur_media OUT SYS_REFCURSOR);

    -- Procedure para listar alunos de uma disciplina
    PROCEDURE LISTAR_ALUNOS_DISCIPLINA(p_id_disciplina IN NUMBER, cur_alunos OUT SYS_REFCURSOR);
END PKG_DISCIPLINA;
/


CREATE OR REPLACE PACKAGE BODY PKG_DISCIPLINA AS
    -- Procedure para cadastrar uma nova disciplina
    PROCEDURE CADASTRAR_DISCIPLINA(p_nome IN VARCHAR2, p_descricao IN CLOB, p_carga_horaria IN NUMBER) IS
        v_exists NUMBER;
    BEGIN
        -- Verifica se a disciplina já existe (comparação limitada a 4000 caracteres)
        SELECT COUNT(1)
        INTO v_exists
        FROM disciplina
        WHERE nome = p_nome 
          AND DBMS_LOB.SUBSTR(descricao, 4000) = DBMS_LOB.SUBSTR(p_descricao, 4000)
          AND carga_horaria = p_carga_horaria;

        -- Insere apenas se não existir
        IF v_exists = 0 THEN
            INSERT INTO disciplina (nome, descricao, carga_horaria)
            VALUES (p_nome, p_descricao, p_carga_horaria);
            COMMIT;
        END IF;
    END CADASTRAR_DISCIPLINA;

    -- Cursor para total de alunos por disciplina
    PROCEDURE TOTAL_ALUNOS_POR_DISCIPLINA(cur_disciplinas OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN cur_disciplinas FOR
        SELECT d.nome AS disciplina, COUNT(m.id_aluno) AS total_alunos
        FROM disciplina d
        LEFT JOIN matricula m ON d.id_disciplina = m.id_disciplina
        GROUP BY d.nome
        HAVING COUNT(m.id_aluno) > 10;
    END TOTAL_ALUNOS_POR_DISCIPLINA;

    -- Cursor para média de idade por disciplina
    PROCEDURE MEDIA_IDADE_DISCIPLINA(p_id_disciplina IN NUMBER, cur_media OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN cur_media FOR
        SELECT AVG(TRUNC(MONTHS_BETWEEN(SYSDATE, a.data_nascimento) / 12)) AS media_idade
        FROM aluno a
        INNER JOIN matricula m ON a.id_aluno = m.id_aluno
        WHERE m.id_disciplina = p_id_disciplina;
    END MEDIA_IDADE_DISCIPLINA;

    -- Procedure para listar alunos de uma disciplina
    PROCEDURE LISTAR_ALUNOS_DISCIPLINA(p_id_disciplina IN NUMBER, cur_alunos OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN cur_alunos FOR
        SELECT a.nome AS aluno
        FROM aluno a
        INNER JOIN matricula m ON a.id_aluno = m.id_aluno
        WHERE m.id_disciplina = p_id_disciplina;
    END LISTAR_ALUNOS_DISCIPLINA;
END PKG_DISCIPLINA;
/








CREATE OR REPLACE PACKAGE PKG_PROFESSOR AS
    -- Cursor para listar o total de turmas por professor
    PROCEDURE TOTAL_TURMAS_POR_PROFESSOR(cur_professores OUT SYS_REFCURSOR);

    -- Function para total de turmas de um professor
    FUNCTION TOTAL_TURMAS_PROFESSOR(p_id_professor IN NUMBER) RETURN NUMBER;

    -- Function para obter o professor de uma disciplina
    FUNCTION PROFESSOR_DISCIPLINA(p_id_disciplina IN NUMBER) RETURN VARCHAR2;
END PKG_PROFESSOR;
/


CREATE OR REPLACE PACKAGE BODY PKG_PROFESSOR AS
    -- Cursor para listar o total de turmas por professor
    PROCEDURE TOTAL_TURMAS_POR_PROFESSOR(cur_professores OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN cur_professores FOR
        SELECT p.nome AS professor, COUNT(t.id_turma) AS total_turmas
        FROM professor p
        LEFT JOIN turma t ON p.id_professor = t.id_professor
        GROUP BY p.nome
        HAVING COUNT(t.id_turma) > 1;
    END TOTAL_TURMAS_POR_PROFESSOR;

    -- Function para total de turmas de um professor
    FUNCTION TOTAL_TURMAS_PROFESSOR(p_id_professor IN NUMBER) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_total
        FROM turma
        WHERE id_professor = p_id_professor;

        RETURN v_total;
    END TOTAL_TURMAS_PROFESSOR;

    -- Function para obter o professor de uma disciplina
    FUNCTION PROFESSOR_DISCIPLINA(p_id_disciplina IN NUMBER) RETURN VARCHAR2 IS
        v_professor_nome VARCHAR2(100);
    BEGIN
        SELECT p.nome
        INTO v_professor_nome
        FROM professor p
        INNER JOIN turma t ON p.id_professor = t.id_professor
        WHERE t.id_disciplina = p_id_disciplina;

        RETURN v_professor_nome;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Nenhum professor encontrado para esta disciplina.';
        WHEN TOO_MANY_ROWS THEN
            RETURN 'Mais de um professor encontrado para esta disciplina.';
    END PROFESSOR_DISCIPLINA;
END PKG_PROFESSOR;
/
