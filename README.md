## Overview

Este projeto contém pacotes PL/SQL para gerenciar informações relacionadas a alunos, disciplinas e professores em um ambiente acadêmico. Os pacotes foram criados para oferecer funcionalidades como:

- Gerenciamento de alunos: exclusão, listagem por curso ou idade.
- Gerenciamento de disciplinas: cadastro, listagem de alunos e estatísticas.
- Gerenciamento de professores: listagem e estatísticas sobre turmas.

### Estrutura dos Pacotes

1. **`PKG_ALUNO`**
   - **EXCLUIR_ALUNO**: Exclui um aluno e suas matrículas associadas.
   - **LISTAR_ALUNOS_MAIORES_18**: Retorna alunos com mais de 18 anos.
   - **LISTAR_ALUNOS_POR_CURSO**: Lista alunos de um curso específico.

2. **`PKG_DISCIPLINA`**
   - **CADASTRAR_DISCIPLINA**: Insere uma nova disciplina, verificando duplicidades.
   - **TOTAL_ALUNOS_POR_DISCIPLINA**: Retorna o total de alunos matriculados por disciplina.
   - **MEDIA_IDADE_DISCIPLINA**: Calcula a média de idade dos alunos de uma disciplina.
   - **LISTAR_ALUNOS_DISCIPLINA**: Lista os alunos de uma disciplina específica.

3. **`PKG_PROFESSOR`**
   - **TOTAL_TURMAS_POR_PROFESSOR**: Lista o total de turmas para cada professor.
   - **TOTAL_TURMAS_PROFESSOR**: Retorna o número de turmas de um professor específico.
   - **PROFESSOR_DISCIPLINA**: Retorna o professor responsável por uma disciplina.

---

## Pré-requisitos

- Banco de Dados Oracle.
- Usuário com permissões para criar pacotes e manipular tabelas no esquema.

### Tabelas utilizadas

As tabelas esperadas incluem, mas não se limitam a:
- `aluno`
- `matricula`
- `disciplina`
- `professor`
- `turma`

Certifique-se de que as tabelas necessárias estejam criadas e devidamente populadas antes de usar os pacotes.

---

## Como Executar

1. **Carregue os pacotes no banco de dados**
   - Execute cada bloco de código PL/SQL fornecido na ordem em um ambiente como SQL*Plus ou SQL Developer:
     ```sql
     @seu_arquivo.sql
     ```

2. **Use as funcionalidades**
   - **Exemplo: Exclusão de um aluno**
     ```sql
     BEGIN
         PKG_ALUNO.EXCLUIR_ALUNO(p_id_aluno => 1);
     END;
     ```
   - **Exemplo: Listar alunos maiores de 18 anos**
     ```sql
     DECLARE
         cur SYS_REFCURSOR;
         v_nome aluno.nome%TYPE;
         v_data_nascimento aluno.data_nascimento%TYPE;
     BEGIN
         PKG_ALUNO.LISTAR_ALUNOS_MAIORES_18(cur);
         LOOP
             FETCH cur INTO v_nome, v_data_nascimento;
             EXIT WHEN cur%NOTFOUND;
             DBMS_OUTPUT.PUT_LINE(v_nome || ' - ' || v_data_nascimento);
         END LOOP;
         CLOSE cur;
     END;
     ```

3. **Habilite o DBMS_OUTPUT (Opcional)**
   Se desejar ver resultados de saída, ative o `DBMS_OUTPUT`:
   ```sql
   SET SERVEROUTPUT ON;
DECLARE
    v_total NUMBER;
BEGIN
    v_total := PKG_PROFESSOR.TOTAL_TURMAS_PROFESSOR(1);
    DBMS_OUTPUT.PUT_LINE('Total de turmas: ' || v_total);
END;
