#ifndef PMM_H
#define PMM_H



// initializes bitmap and frame allocator data
void init_PMM(uint32_t mem_sz, uint32_t bitmap_loc);

//-------------------------
// bump allocator functions
//-------------------------

//simple bump allocator to set up bitmap
uint32_t bump_alloc(uint32_t sz);



//------------------
// bitmap functions
//------------------

//set bit in bitmap specified by bit_index
void bitmap_set(uint32_t bit_index);

//unset bit in bitmap specified by bit_index
void bitmap_unset(uint32_t bit_index);

//if bit is set in bitmap specified by bit_index, return 1, else 0
char bitmap_test(uint32_t bit_index);

//returns index into bitmap of first free index in bitmap
uint32_t bitmap_first_free_index();

//returns index into bitmap of first free indicies specified by size of sz
uint32_t bitmap_first_free_indices(uint32_t sz);

//initialize bitmap using bump allocator and size. bump allocator returns start address of bitmap
//uint32_t init_bitmap(uint32_t sz)


//--------------------------
// frame allocator functions
//--------------------------

// initialize frame allocator using the memory size and the bitmap location
//void init_frame_allocator(uint32_t mem_sz, uint32_t bitmap_loc)

// sets a region of memory specified by location and size
void set_mem_region(uint32_t location, uint32_t sz);

// unsets a region of memory specified by location and size
void unset_mem_region(uint32_t location, uint32_t sz);

//allocates frame and returns frame address
uint32_t alloc_frame();

//deallocates frame and using frame address
void dealloc_frame(uint32_t frame);

//allocates frames and returns frame address
uint32_t alloc_frames(uint32_t sz);

//deallocates frames and using frame address
void dealloc_frames(uint32_t frame, uint32_t sz);

#endif