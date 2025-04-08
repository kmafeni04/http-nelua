#ifndef THREADPOOL_H
#define THREADPOOL_H

#include <pthread.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  void (*func)(void *arg);
  void *arg;
} Task;

typedef struct {
  Task *tasks;
  int queue_size;
  int front, rear, count;

  pthread_mutex_t lock;
  pthread_cond_t not_empty;
  pthread_cond_t not_full;

  pthread_t *threads;
  int num_threads;
  int running;
} ThreadPool;

int threadpool_init(ThreadPool *pool, int num_threads, int queue_size);
void threadpool_enqueue(ThreadPool *pool, void (*func)(void *), void *arg);
void threadpool_shutdown(ThreadPool *pool);

#ifdef __cplusplus
}
#endif

#endif // THREADPOOL_H

#ifdef THREADPOOL_IMPLEMENTATION

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

static void *threadpool_worker(void *arg) {
  ThreadPool *pool = (ThreadPool *)arg;

  while (1) {
    pthread_mutex_lock(&pool->lock);

    while (pool->count == 0 && pool->running) {
      pthread_cond_wait(&pool->not_empty, &pool->lock);
    }

    if (!pool->running && pool->count == 0) {
      pthread_mutex_unlock(&pool->lock);
      break;
    }

    Task task = pool->tasks[pool->front];
    pool->front = (pool->front + 1) % pool->queue_size;
    pool->count--;

    pthread_cond_signal(&pool->not_full);
    pthread_mutex_unlock(&pool->lock);

    task.func(task.arg);
  }

  return NULL;
}

int threadpool_init(ThreadPool *pool, int num_threads, int queue_size) {
  pool->queue_size = queue_size;
  pool->tasks = malloc(sizeof(Task) * queue_size);
  if (!pool->tasks)
    return 0;

  pool->front = pool->rear = pool->count = 0;
  pool->num_threads = num_threads;
  pool->running = 1;

  pthread_mutex_init(&pool->lock, NULL);
  pthread_cond_init(&pool->not_empty, NULL);
  pthread_cond_init(&pool->not_full, NULL);

  pool->threads = malloc(sizeof(pthread_t) * num_threads);
  if (!pool->threads) {
    free(pool->tasks);
    return 0;
  }

  for (int i = 0; i < num_threads; i++) {
    pthread_create(&pool->threads[i], NULL, threadpool_worker, pool);
  }

  return 1;
}

void threadpool_enqueue(ThreadPool *pool, void (*func)(void *), void *arg) {
  pthread_mutex_lock(&pool->lock);

  while (pool->count == pool->queue_size) {
    pthread_cond_wait(&pool->not_full, &pool->lock);
  }

  pool->tasks[pool->rear].func = func;
  pool->tasks[pool->rear].arg = arg;
  pool->rear = (pool->rear + 1) % pool->queue_size;
  pool->count++;

  pthread_cond_signal(&pool->not_empty);
  pthread_mutex_unlock(&pool->lock);
}

void threadpool_shutdown(ThreadPool *pool) {
  pthread_mutex_lock(&pool->lock);
  pool->running = 0;
  pthread_cond_broadcast(&pool->not_empty);
  pthread_mutex_unlock(&pool->lock);

  for (int i = 0; i < pool->num_threads; i++) {
    pthread_join(pool->threads[i], NULL);
  }

  free(pool->threads);
  free(pool->tasks);

  pthread_mutex_destroy(&pool->lock);
  pthread_cond_destroy(&pool->not_empty);
  pthread_cond_destroy(&pool->not_full);
}

#endif // THREADPOOL_IMPLEMENTATION
