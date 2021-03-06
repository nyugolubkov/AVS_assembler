﻿// БПИ-195 Голубков Никита
// Задание 4 Вариант 3
//
// Найти алгебраическое дополнение для каждого элемента матрицы.
// целое положительное число n, произвольная матрица А размерности n х n.
// Количество потоков является входным параметром, при этом размерность
// матриц может быть не кратна количеству потоков.
//
// Использовать интсрументы OpenMP

#include <iostream>
#include <vector>
#include <cmath>
#include <ctime>

using namespace std;

// Функция, генерирующая матрицу размера n x n
// Заполняет матрицу случайными элементами от 0 до 100
int** generate_matrix(int n) {
	int** matrix = new int* [n];

	for (int i = 0; i < n; i++) {
		matrix[i] = new int[n];
		for (int j = 0; j < n; j++) {
			matrix[i][j] = rand() % 101;
		}
	}

	return matrix;
}

// функция освобождает память от матрицы matrix, n - размер матрицы
void clear_memory(int**& matrix, const int n) {
	for (int i = 0; i < n; i++) {
		delete[] matrix[i];
	}
	delete[] matrix;
}

// Находит минор index1, index2 матрицы matrix; n - размер матрицы
int** matrix_minor(int**& matrix, const int index1, const int index2, const int n) {
	int** new_matrix = new int* [n - 1]; // Создание массива массивов длиной n-1

	for (int i = 0; i < n; i++) {
		// Игнорирование строки index1
		if (i == index1)
			continue;

		// Вычисление текущей строки минора
		int i_new = i;
		if (i > index1)
			i_new--;

		// Создание очередной строки в матрице
		new_matrix[i_new] = new int[n - 1];
		for (int j = 0; j < n; j++) {
			// Игнорирование столбца index2
			if (index2 == j)
				continue;

			// Вычисление текущего столбца минора
			int j_new = j;
			if (j > index2)
				j_new--;

			// Присваивание элемента матрицы в элемент минора
			new_matrix[i_new][j_new] = matrix[i][j];
		}
	}

	return new_matrix;
}

// Считает определитель матрицы matrix размера n x n
int calculate_result(int**& matrix, const int n) {
	// Проверка на легких элементах для выхода из рекурсии
	if (n < 1)
		return 0;
	if (n == 1)
		return matrix[0][0];
	if (n == 2)
		return matrix[0][0] * matrix[1][1] - matrix[1][0] * matrix[0][1];

	int res = 0; // Результат вычисления определителя
	// Вычисление определителя матрицы при помощи разложения по столбцу
	for (int i = 0; i < n; i++) {
		int** minor = matrix_minor(matrix, i, 0, n); // Вычисление минора
		// Рекурсивный вызов функции для вычисления определителя при разложении по столбцу
		res += static_cast<int>(pow(-1, i)) * matrix[i][0]
			* calculate_result(minor, n - 1);
		clear_memory(minor, n - 1); // Освобождение памяти
	}

	return res; // Возврат результата
}

// Функция, выводящая в консоль матрицу matrix размера size x size,
// выводя перед этим строку line
void print_matrix(int**& matrix, const int size, const string& line) {
	cout << line << endl;
	for (int i = 0; i < size; i++) {
		cout << matrix[i][0];
		for (int j = 1; j < size; j++) {
			cout << '\t' << matrix[i][j];
		}
		cout << endl;
	}
}

int main(int argc, char** argv) {
	// Проверка на количество аргументов в командной строке
	if (argc < 3) {
		cout << "There are no enough arguments!";
		return 1;
	}

	const int n = strtol(argv[1], nullptr, 10); // Размер матрицы
	const int thread_num = strtol(argv[2], nullptr, 10); // Количество используемых потоков

	// Проверка на валидность входных данных
	if (n < 2 || n > 10) {
		cout << "Wrong matrix size: " << n;
		return 1;
	}
	if (thread_num < 1 || thread_num > 100) {
		cout << "Wrong number of threads: " << thread_num;
		return 1;
	}

	// Инициализация и генерация матрицы
	int** matrix = generate_matrix(n);

	// Создание матрицы дополнений
	int** matrix_dop = new int* [n];
	for (int i = 0; i < n; i++) {
		matrix_dop[i] = new int[n] {0};
	}

	// Вывод сгенерированной матрицы
	print_matrix(matrix, n, "Generated matrix:");

	// Начало замера времени создания потоков и расчетов
	clock_t start_time = clock();

	// Запуск потоков
	#pragma omp parallel for num_threads(thread_num)
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < n; j++) {
			int** minor = matrix_minor(matrix, i, j, n); // Вычисление минора для вычисления дополнения
			matrix_dop[i][j] = static_cast<int>(pow(-1, i + j)) *
				matrix[i][j] * calculate_result(minor, n - 1); // Вычисление дополнения
			clear_memory(minor, n - 1); // Освобождение памяти
		}
	}

	// Замер времени работы всей программы
	clock_t end_time = clock();

	// Вывод матрицы дополнений элементов
	print_matrix(matrix_dop, n, "Result called \'dopolneniya\':");

	// Вывод результата замеров
	std::cout << "The whole work time = " << end_time - start_time << "\n";

	return 0;
}