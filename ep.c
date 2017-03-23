#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int * concatena(int tam1, int *vetor1, int tam2, int *vetor2);
void * elimina_repetidos(int size, int * result, int * newSize);
int * fillVector(char * arg, int * size);
void insertion_sort(int size, int* list);

int main(int argc, char* argv[])
{
	int size1, size2;
	
	int * vector1 = fillVector(argv[1], &size1);
	int * vector2 = fillVector(argv[2], &size2);
	
	int * result = concatena(size1, vector1, size2, vector2);
	
	quick_sort(0, (size1 + size2) - 1, result);
	
	int newSize;
	elimina_repetidos(size1 + size2, result, &newSize);	
	
	
	FILE * file = fopen(argv[3], "a+");
	
	if(!file)
		exit(EXIT_FAILURE);
	
	int i;
	for(i = 0; i < newSize; i++)
		fprintf(file, "%d ", result[i]);	
	
	return 0;
}
int * concatena(int tam1, int *vetor1, int tam2, int *vetor2)
{
	int size = tam1 + tam2;
	
	int * result = (int*)calloc(size, sizeof(int));
	
	int i, j;
	for(i = 0; i < tam1; i++)
		result[i] = vetor1[i];
		
	for(j = 0; j < tam2; j++)
		result[i + j] = vetor2[j];
	
	return result;
}
void * elimina_repetidos(int size, int * result, int * newSize)
{
	int n = size;

	int i, j, k;
	for(i = 0; i < n; i++)
	{
		for(j = i + 1; j < n; j++)
		{
			if(result[i] == result[j])
			{
				for(k = j + 1; k < n; k++)
					result[k-1] = result[k];

				n--;
				j--;
			}
		}
	}	
	*newSize = n;
}
int * fillVector(char * arg, int * size)
{
	//Open file
	FILE * file = fopen(arg, "r");
	
	if(!file)
		exit(EXIT_FAILURE);
	
	//Count number of integers
	int n, i;
	i = 0;
	
	while(fscanf(file, "%d", &n) != EOF)
		i++;
	
	int * numbers = (int*)calloc(i, sizeof(int));
	*size = i;
	i = 0;
	
	fseek(file, 0, SEEK_SET);
	
	//Read integers
	while(fscanf(file, "%d", &n) != EOF)
	{
		numbers[i] = n;
		i++;
	}
	
	fclose(file);
	
	return numbers;
}

void quick_sort(int l, int r, int* list)
{
    if (l < r) // $a0 < $a1
    {
        int p = (l + r) / 2; // $s0 = ($a0 + $a1) / 2
        int pos = partition(l, r, p, list);
        
        quick_sort(l, pos-1, list);
        quick_sort(pos+1, r, list);
    }
}

int partition(int l, int r, int p, int* list)
{
    int pos, i; // $s0, $s1
    
    swap(p, r, list);
    
    i = l; // $s1 = $a0
    pos = l; // $s0 = $a0
    
    while (i < r) // $s1 < $a1
    {
        if (list[i] < list[r])
        {
            swap(i, pos, list);
            pos++; // $s0 = $s0 + 1
        }
        
        i++; // $s1 = $s1 + 1
    }
    
    swap(r, pos, list);
    
    return pos;
}

void swap(int a, int b, int* list)
{
    int tmp = list[a]; // $t0 = $a2 ( + $a0)
    list[a] = list[b]; // $a2 ( + $a0) = $a2 ( + $a1)
    list[b] = tmp; // $a2 ( + $a1) = $t0
}







