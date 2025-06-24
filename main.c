#include <stdio.h>
#include <stdlib.h>

void printarVetor(float *vetor, int tamanho) {
    // Imprime o vetor na tela
    for (int i = 0; i < tamanho; i++) {
        printf("%f.10\n", vetor[i]);
    }
}

float* lerVetorDeArquivo(FILE* arquivo, int *tamanho) {
    // Tamanho é o número de \n no arquivo, temos que  contar quantos números existem
    int tam = 1;
    float numero = 0;

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
    int nInd = 0;
    while ((c = fgetc(arquivo)) != EOF) {
        if (c == '\n') {
            // Quando encontramos um \n, significa que lemos um número completo
            // Convertendo o número lido para float e armazenando no vetor
            vetor[i] = numero;
            i++;
            nInd = 0;
            numero = 0; // Reseta o número para o próximo
        } else if (c >= '0' && c <= '9') {
            // Se o caracter é um dígito, adicionamos ao número
            numero = numero * 10 + (c - '0');
            nInd++;
        } else if (c == '-' && nInd == 0) {
            // Se encontramos um '-', significa que o número é negativo
            numero = -numero; // Inverte o sinal do número
            nInd++;
        }  else if (c == '.') {
            // Se encontramos um '.', significa que o número é decimal
            // Precisamos ler os dígitos após o ponto para formar o número decimal
            float decimalPlace = 0.1; // Começa na casa decimal
            char d;
            while ((d = fgetc(arquivo)) != EOF && d != '\n') {
                if (d >= '0' && d <= '9') {
                    numero += (d - '0') * decimalPlace;
                    decimalPlace *= 0.1; // Move para a próxima casa decimal
                    nInd++;
                }
            }
            // Se encontramos um \n, significa que terminamos de ler o número
            vetor[i] = numero;
            i++;
            numero = 0; // Reseta o número para o próximo
            nInd = 0;
        }
    }

    // Se deu End of File, jogar o último número para a última posição já que não há nada a ser feito
    vetor[i] = numero;
    numero = 0;

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

    for (int i = 1; i < tam; ++i) {
        float key = vetor[i];
        int j = i - 1;

        /* Move elements of arr[0..i-1], that are
           greater than key, to one position ahead
           of their current position */
        while (j >= 0 && vetor[j] > key) {
            vetor[j + 1] = vetor[j];
            j = j - 1;
        }
        vetor[j + 1] = key;
    }

    return vetor;
}

void swap(float* a, float* b) {
    float temp = *a;
    *a = *b;
    *b = temp;
}

float partition(float arr[], int low, int high) {
    // Initialize pivot to be the first element
    float p = arr[low];
    int i = low;
    int j = high;

    while (i < j) {

        // Find the first element greater than
        // the pivot (from starting)
        while (arr[i] <= p && i <= high - 1) {
            i++;
        }

        // Find the first element smaller than
        // the pivot (from last)
        while (arr[j] > p && j >= low + 1) {
            j--;
        }
        if (i < j) {
            swap(&arr[i], &arr[j]);
        }
    }
    swap(&arr[low], &arr[j]);
    return j;
}

float* quickSort(float *vetor, int low, int high) {
    // Se o tamanho do vetor for menor que 2, não há nada a ordenar
    if(low >= high) {
        return vetor;
    }

    // Quicksort: escolhe um pivô e particiona o vetor em dois sub-vetores,
    // um com elementos menores que o pivô e outro com elementos maiores,
    // e então ordena recursivamente os sub-vetores

    int pi = partition(vetor, low, high);

    quickSort(vetor, low, pi - 1);
    quickSort(vetor, pi + 1, high);

    return vetor;
}

float* ordena(int tam, int tipo, float *vetor) {
    float* ordenado = (float*)malloc(tam * sizeof(float));
    if (ordenado == NULL) {
        printf("Erro");
        return NULL; // Erro ao alocar memória
    }

    for (int i = 0; i < tam; i++) {
        ordenado[i] = vetor[i];
    }

    if (tipo == 1) {
        insertionSort(tam, ordenado);
    } else if(tipo == 2) {
        quickSort(ordenado, 0, tam);
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

    float* ordenado = ordena(tamanho, 1, vetor);

    printarVetor(ordenado, tamanho); // Passa o tamanho do vetor

    return 0;
}
