#include <stdio.h>
#include <stdlib.h>

void printarVetor(float *vetor, int tamanho) {
    // Imprime o vetor na tela
    for (int i = 0; i < tamanho; i++) {
        printf("%f\n", vetor[i]);
    }
}

float* lerVetorDeArquivo(FILE* arquivo, int *tamanho) {
    // Tamanho é o número de \n no arquivo, temos que  contar quantos números existem
    int tam = 0;
    float numero;
    // Primeiro, contamos quantos números existem no arquivo, percorrendo caracter por caractere e usando fgetc
    char c;
    while((c = fgetc(arquivo)) != EOF) {
        if(c == '\n') {
            tam++;
        }
    }
    
    // Voltamos o ponteiro do arquivo para o início
    rewind(arquivo);

    // Alocamos memória para o vetor de floats
    float* vetor = (float*)malloc(tam * sizeof(float));
    if (vetor == NULL) {
        return NULL; // Erro ao alocar memória
    }

    // Lemos os números do arquivo e os armazenamos no vetor manualmente caracter por caracter para aprendermos
    int i = 0;
    while ((c = fgetc(arquivo)) != EOF) {
        if (c == '\n') {
            // Quando encontramos um \n, significa que lemos um número completo
            // Convertendo o número lido para float e armazenando no vetor
            vetor[i] = numero;
            i++;
            numero = 0; // Reseta o número para o próximo
        } else if (c >= '0' && c <= '9') {
            // Se o caracter é um dígito, adicionamos ao número
            numero = numero * 10 + (c - '0');
        } else if (c == '-' && i == 0) {
            // Se encontramos um '-', significa que o número é negativo
            numero = -numero; // Inverte o sinal do número
        }  else if (c == '.') {
            // Se encontramos um '.', significa que o número é decimal
            // Precisamos ler os dígitos após o ponto para formar o número decimal
            float decimalPlace = 0.1; // Começa na casa decimal
            char d;
            while ((d = fgetc(arquivo)) != EOF && d != '\n') {
                if (d >= '0' && d <= '9') {
                    numero += (d - '0') * decimalPlace;
                    decimalPlace *= 0.1; // Move para a próxima casa decimal
                }
            }
            // Se encontramos um \n, significa que terminamos de ler o número
            vetor[i] = numero;
            i++;
            numero = 0; // Reseta o número para o próximo
        }
    }

    *tamanho = tam; // Armazena o tamanho do vetor

    return vetor;
}

float* insertionSort(int tam, float *vetor) {
    // Se o tamanho do vetor for menor que 2, não há nada a ordenar
    if(tam < 2) {
        return vetor;
    }

    // Insertion Sort: percorre o vetor e insere cada elemento na posição correta
    // em relação aos elementos já ordenados à esquerda

    return vetor;
}

float* quickSort(int tam, float *vetor) {
    // Se o tamanho do vetor for menor que 2, não há nada a ordenar
    if(tam < 2) {
        return vetor;
    }

    // Quicksort: escolhe um pivô e particiona o vetor em dois sub-vetores,
    // um com elementos menores que o pivô e outro com elementos maiores,
    // e então ordena recursivamente os sub-vetores

    return vetor;
}

float* ordena(int tam, int tipo, float *vetor) {
    float* ordenado = (float*)malloc(tam * sizeof(float));
    if (ordenado == NULL) {
        return NULL; // Erro ao alocar memória
    }

    for (int i = 0; i < tam; i++) {
        ordenado[i] = vetor[i];
    }

    if (tipo == 1) {
        insertionSort(tam, ordenado);
    } else if(tipo == 2) {
        quickSort(tam, ordenado);
    }

    return ordenado;
}

int main() {
    // Abre o arquivo para leitura
    FILE* arquivo = fopen("numeros.txt", "r");
    if (arquivo == NULL) {
        printf("Erro ao abrir o arquivo.\n");
        return 1;
    }
    // Lê os números do arquivo e armazena em um vetor
    int tamanho = 0; // Variável para armazenar o tamanho do vetor
    float* vetor = lerVetorDeArquivo(arquivo, &tamanho);
    fclose(arquivo); // Fecha o arquivo após a leitura

    if (vetor == NULL) {
        printf("Erro ao alocar memória para o vetor.\n");
        return 1;
    }

    // Imprime o vetor lido do arquivo
    printf("Vetor lido do arquivo:\n");
    printarVetor(vetor, tamanho); // Passa o tamanho do vetor

    return 0;
}
