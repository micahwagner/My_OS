#ifndef VMM_H
#define VMM_H
#include "type.h"


//-------------------------
// init_paging.c
//-------------------------

void init_paging();

typedef struct page_dir_entry {
	uint32_t present	: 1;
	uint32_t rw			: 1;
	uint32_t us 		: 1;
	uint32_t pwt		: 1;
	uint32_t pcd		: 1;
	uint32_t access 	: 1;
	uint32_t dirty 		: 1;
	uint32_t page_size 	: 1;
	uint32_t global_page: 1;
	uint32_t available 	: 3;
	uint32_t frame_addr : 20;
} page_dir_entry_t;

typedef struct page_table_entry {
	uint32_t present	: 1;
	uint32_t rw			: 1;
	uint32_t us 		: 1;
	uint32_t reserved	: 2;
	uint32_t access 	: 1;
	uint32_t dirty 		: 1;
	uint32_t reserved 	: 2;
	uint32_t available 	: 3;
	uint32_t frame_addr : 20;
	
} page_table_entry_t;

typedef 


//-------------------------
// paging typedefs
//-------------------------
typedef struct page_table {

	page_table_entry_t entrys[1024];

} page_table_t;

typedef struct page_dir {

	page_dir_entry_t entrys[1024];

} page_dir_t;



//-------------------------
// paging_utils.c
//-------------------------

void enable_paging(char bool);

void load_page_dir(uint32_t addr);

uint32_t get_page_dir();

//sets attribute in page dir entry specified by attribute (ex, attribute = 1, present set to 1)
void page_dir_entry_set(page_dir_entry_t *entry, uint32_t attribute);

//unsets attribute in page dir entry specified by attribute (ex, attribute = 1, present set to 0)
void page_dir_entry_unset(page_dir_entry_t *entry, uint32_t attribute);

//sets frame attribute in page dir entry specified by frame
void page_dir_entry_set_fr(page_dir_entry_t *entry, uint32_t frame);

uint32_t page_dir_entry_get_fr(page_dir_entry_t *entry);



//tests attribute in page table entry specified by attribute
uint8_t page_table_entry_test(page_table_entry_t *entry, uint32_t attribute);

//sets attribute in page table entry specified by attribute (ex, attribute = 1, present set to 1)
void page_table_entry_set(page_table_entry_t *entry, uint32_t attribute);

//unsets attribute in page table entry specified by attribute (ex, attribute = 1, present set to 0)
void page_table_entry_unset(page_table_entry_t *entry, uint32_t attribute);

//sets frame attribute in page table entry specified by frame
void page_table_entry_set_fr(page_table_entry_t *entry, uint32_t frame);

uint32_t page_table_entry_get_fr(page_table_entry_t *entry);

//tests attribute in page table entry specified by attribute
uint8_t page_table_entry_test(page_table_entry_t *entry, uint32_t attribute);




#endif