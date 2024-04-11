#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/spinlock.h"
#include "user/user.h"
#include "user/thread.h"


int thread_create( void *(*start_routine)(void*), void *arg) 
{
	int stksz = 4096 * sizeof(void);
	void* stk_addr = (void*) malloc(stksz);
	
	int tid  = clone(stk_addr,stksz);
	
	if(tid == 0) {
		(*start_routine) (arg);
		exit(0);
	}
	return 0;
}

void lock_init(lock_t *lock)
{
	*lock = 0;
}
void lock_acquire(lock_t *lock)
{
	while(__sync_lock_test_and_set(lock, 1) != 0);
	__sync_synchronize();
}
void lock_release(lock_t *lock)
{
	__sync_synchronize();
	__sync_lock_release(lock,0);
}
