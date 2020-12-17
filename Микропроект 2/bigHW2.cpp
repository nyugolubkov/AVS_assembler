// БПИ-195 Голубков Никита
// Микропроект 2 Вариант 3
//
// Задача о читателях и писателях. Базу данных разделяют два типа
// процессов – читатели и писатели. Читатели выполняют транзакции, которые
// просматривают записи базы данных, транзакции писателей и просматривают
// и изменяют записи. Предполагается, что в начале БД находится в
// непротиворечивом состоянии(т.е.отношения между данными имеют смысл).
// Каждая отдельная транзакция переводит БД из одного непротиворечивого
// состояния в другое. Для предотвращения взаимного влияния транзакций
// процесс - писатель должен иметь исключительный доступ к БД. Если к БД не
// обращается ни один из процессов - писателей, то выполнять транзакции могут
// одновременно сколько угодно читателей.Создать многопоточное
// приложение с потоками - писателями и потоками - читателями. Реализовать
// решение, используя семафоры.

#include <iostream>
#include <pthread.h>
#include <semaphore.h>
#include <vector>
#include <cstdlib>
#include <Windows.h> // для windows
#include <ctime>
//#include <unistd.h> // для linux

using namespace std;

// Инициализация глобальных переменных
sem_t ac, r, locker; // семафоры
int read_count = 0; // счетчик количества потоков ридеров
vector<int> database; // имитация некоторого БД
clock_t start_time = clock(); // Переменная фиксации начала работы программы
bool active = true; // флаг активности программы

// объявление функций программы
void rand_init(vector<int>&);
void* run_reader(void*);
void* run_writer(void*);

int main(int argc, char* argv[]) {
	// Инициализация аналога БД
	rand_init(database);

	// Проверка программы на достаточное количество
	// аргументов командной строки
	if (argc < 4) {
		cout << "Wrong amount of arguments: " << argc;
		return 1;
	}

	// Инициализация семафоров
	sem_init(&ac, 0, 1);
	sem_init(&r, 0, 1);
	sem_init(&locker, 0, 1);

	// Инициализация количества читателей, потоков и секунд работы
	const int n = strtol(argv[1], nullptr, 10); // Количество читателей
	const int m = strtol(argv[2], nullptr, 10); // Количество писателей
	const int k = strtol(argv[3], nullptr, 10); // Время работы в секундах

	// Проверка корректности n, m и k
	if (n < 2 || n > 10) {
		cout << "Wrong number of readers: " << n;
		return 1;
	}
	if (m < 2 || m > 10) {
		cout << "Wrong number of writers: " << m;
		return 1;
	}
	if (k < 2 || k > 50) {
		cout << "Wrong number of seconds: " << k;
		return 1;
	}

	// Вывод БД
	for (int i = 0; i < 10; i++) {
		cout << "DB[" << i << "] = " << database[i] << endl;
	}

	// Объявление векторов писателей и читателей
	vector<pthread_t> readers(n);
	vector<pthread_t> writers(m);

	start_time = clock(); // Инициализация отсчета начала работы программы

	// Создание потоков
	cout << "Start time: 0" << endl;
	for (int i = 0; i < n; i++) {
		pthread_create(&readers[i], nullptr, run_reader, reinterpret_cast<void*>(i));
	}
	for (int i = 0; i < m; i++) {
		pthread_create(&writers[i], nullptr, run_writer, reinterpret_cast<void*>(i));
	}

	// Ожидание k секунд
	Sleep(k * 1000); // for windows
	//sleep(k); // for linux

	active = false; // Изменение флага как неактивного

	// Ожидание завершения потоков читателей и писателей
	for (int i = 0; i < n; i++) {
		pthread_join(readers[i], nullptr);
	}
	for (int i = 0; i < m; i++) {
		pthread_join(writers[i], nullptr);
	}

	cout << "End time: " << clock() - start_time; // Итоговое время работы

	return 0;
}

// Генератор БД
void rand_init(vector<int>& db) {
	for (int i = 0; i < 10; i++) {
		db.push_back(rand() % 101);
	}
}

// Поток читателей
void* run_reader(void* param) {
	// Инициализация индекса потока из параметра
	const int thread_index = static_cast<int>(reinterpret_cast<size_t>(param));

	// Цикл работы пока программа не перестанет быть активной
	while (active) {
		// Увеличение счетчика количества потоков читателей
		// c проверкой, чтобы не работал писатель во время чтения
		sem_wait(&r); // Ожидание при работающем уже фрагменте изменения счетчика читателя
		read_count++;
		if (read_count == 1)
			sem_wait(&ac);
		sem_post(&r); // Освобождение лока для фрагмента изменения счетчика писателя

		// Имитация деятульности
		Sleep(1000); // для windows
		//usleep(1000000); // для linux
		const int db_index = rand() % database.size(); // выбор элемента БД

		// Вывод с локом для некривого вывода
		sem_wait(&locker);
		cout << "Time " << clock() - start_time << " - reader " << thread_index <<
			" read " << db_index << " element: " << database[db_index] << endl;
		sem_post(&locker);

		// Уменьшение счетчика количества потоков читателей
		// c проверкой, чтобы позволить работу писателю
		// при отсутствии читателей
		sem_wait(&r); // Ожидание при работающем уже фрагменте изменения счетчика читателя
		read_count--;
		if (read_count == 0)
			sem_post(&ac);
		sem_post(&r); // Освобождение лока для фрагмента изменения счетчика писателя

		// Сон для перерыва между чтениями
		Sleep(1000); // для windows
		//usleep(1000000); // для linux
	}
	return nullptr;
}

// Поток читателей
void* run_writer(void* param) {
	// Инициализация индекса потока из параметра
	const int thread_index = static_cast<int>(reinterpret_cast<size_t>(param));

	// Цикл работы пока программа не перестанет быть активной
	while (active) {
		sem_wait(&ac); // Ожидание при работающем уже фрагменте писателя

		const int db_index = rand() % database.size(); // выбор элемента БД
		const int value = rand() % 101; // Генерация нового элемента
		
		// Вывод отметки времени и запись нового элемента
		cout << "Time " << clock() - start_time << " - writer " << thread_index <<
			" started to write in " << db_index << " element: " << value << endl;
		database[db_index] = value;
		cout << "Time " << clock() - start_time << " - writer " << thread_index <<
			" wrote in " << db_index << " element: " << value << endl;

		sem_post(&ac); // Освобождение лока для фрагмента писателя

		// Сон для перерыва между чтениями
		Sleep(1000); // for windows
		//usleep(1000000); // for linux
	}
	return nullptr;
}