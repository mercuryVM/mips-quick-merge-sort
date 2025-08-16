# MIPS Quick Merge Sort

Projeto da disciplina **ACH2034 - Organização e Arquitetura de Computadores I (USP, 2025)**, desenvolvido em Assembly MIPS no contexto do **Segundo Exercício-Programa (EP2)**.  
O trabalho consiste em implementar dois algoritmos de ordenação em Assembly, com foco em manipulação de arquivos, ponteiros e desempenho. 

---

## 📖 Contexto

A motivação do projeto é o desafio contemporâneo de lidar com **grandes volumes de dados**.  
Para permitir **indexação e busca eficiente**, é necessário ordenar as informações em memória e arquivos.  
O EP2 propõe a implementação de dois métodos de ordenação com diferentes complexidades assintóticas: um em **O(n²)** e outro em **O(n log n)**. 

---

## 📝 O que deve ser feito

- Ler os dados de um arquivo de entrada contendo números de ponto flutuante (`float`).  
- Determinar o tamanho `n` do vetor dinamicamente (não conhecido a priori).  
- Implementar dois algoritmos de ordenação:
  - **Insertion Sort** ou **Bubble Sort** (dependendo do valor de N calculado com base no nº USP dos integrantes).  
  - **Quicksort**.  
- Escrever o vetor ordenado **de volta no arquivo**, em ordem crescente. 

---

## 🧩 Requisitos da função principal

O trabalho exige a implementação de uma função assembly com a seguinte assinatura (C-like):

```c
float* ordena(int tam, int tipo, float* vetor);
```

- **retorno:** ponteiro para o vetor ordenado  
- **tam:** tamanho do vetor a ser ordenado  
- **tipo:** define qual método será usado (Insertion/Bubble ou Quicksort)  
- **vetor:** ponteiro para os dados a ordenar 

---

## 📂 Estrutura esperada

```
mips-quick-merge-sort/
├─ src/
│  ├─ ordena.asm      # função principal em Assembly MIPS
│  ├─ insertion.asm   # implementação do Insertion Sort (se aplicável)
│  ├─ bubble.asm      # implementação do Bubble Sort (se aplicável)
│  ├─ quicksort.asm   # implementação do Quicksort
│  └─ io.asm          # rotinas de leitura e escrita em arquivo
├─ input.txt          # arquivo com dados de entrada
├─ output.txt         # arquivo com dados ordenados
└─ README.md
```

---

## ▶️ Como executar

### Usando o simulador MARS
1. Baixe e abra o [MARS MIPS](http://courses.missouristate.edu/kenvollmar/mars/).  
2. Carregue os arquivos `.asm` do projeto.  
3. Rode o programa principal que chama a função `ordena`.  
4. O resultado será gravado no arquivo de saída. 

---

## 📊 Entrega esperada

- Código-fonte em Assembly.  
- Relatório/documentação descrevendo a lógica.  
- Análise comparativa de desempenho entre os algoritmos implementados (O(n²) vs O(n log n)). 

---

## 📚 Referências

- PATTERSON, D. A., HENNESSY, J. L. *Organização e Projeto de Computadores: A Interface Hardware/Software*, 5ª ed., 2014.  
- Documentação do simulador [MARS Syscalls](http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html).

---

## 📄 Licença

Projeto acadêmico para a disciplina ACH2034 - Organização e Arquitetura de Computadores I (USP, 2025).
