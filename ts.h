/*max length of the hash table*/
#define MAX_LENGTH 1000

/* token types */
#define UNDEF 0
#define INT_TYPE 1   
#define REAL_TYPE 2
#define LOGC_TYPE 3
#define CHAR_TYPE 4
#define ARRAY_TYPE 5
#define FUNCTION_TYPE 6
#define KEYWORDS_TABLE 7
#define SEPARATORS_TABLE 8


/* operator types */
#define NONE 0		// to check types only - assignment, parameter
#define ARITHM_OP 1 // ADDOP, MULOP, DIVOP (+, -, *, /)
#define BOOL_OP 2   // OROP, ANDOP (||, &&)
#define REL_OP 3    // RELOP (>, <, >=, <=)
#define EQU_OP 4    // EQUOP (==, !=)


/* parameter struct */
typedef struct Size {
	int x;
	int y;
} Size;

// Structure to represent function parameters
typedef struct Param {
    // parameter type and name
    int par_type;  
    char* par_name;  
	
	int par_nbr;

    // to store the value
	char* par_val;

} Param;

/* a linked list of references (line_nbr's) for each variable */
typedef struct RefList {
    int line_nbr;   
    struct RefList *next;
} RefList;

// struct that represents a list node
typedef struct SymbolInfo {
    // name, size of name, scope and occurrences (lines)
    char *smb_name;  
    int smb_size;
    int scope;
    RefList *lines;

    // to store value and sometimes more information
	char* val;
	

    // type
    int smb_type;
	int smb_dim;

    // for arrays (info type)
    // and for functions (return type)
    int inf_type;

    // array stuff
    int *i_vals;
    float *f_vals;
    char *s_vals;
    Size array_size;
	

    // function parameters
    Param *parameters;
    int num_of_pars;

    // pointer to the next item in the list
    struct SymbolInfo *next;
} SymbolInfo;

typedef struct SymbolInfo_SM {
    char *smb_name;
    struct SymbolInfo_SM *next;
} SymbolInfo_SM;




/* static structures */
static SymbolInfo **idf_table;
static SymbolInfo **keywords_table;
static SymbolInfo **separators_table;

// Symbol Table Functions
void init_symbol_tables(); // initialize all hash table
int djb2_hash(char *key); // hash function 
void insertIdf(char *name, int smb_type, int lineno, int declare); // insert entry IDF
void insertSM(int table, char *name); //inset entry SP, MC
SymbolInfo *lookup(char *name); // search for entry IDF
void dumpIDF(); // dump file IDF
int dumpSM(int table, const char *title); // dump file SM

// Type Functions
int set_type(char *name, int smb_type, int inf_type, int smb_dim, int x, int y); // set the type of an entry (declaration)
void set_val(char *name, char* val, int cur_scope); //set the value
char* get_val(char *name,int scopeid); //get the value
int get_type(char *name, int scopeid); // get the type of an entry
Size get_size(char *name,int scopeid);// get the size of an array

// Scope Management Functions
void hide_scope(); // hide the current scope
void incr_scope(); // go to next scope
int get_scope();

// Function Declaration and Parameters
Param def_param(int par_type, char *par_name); // define parameter
void func_declare(char *name, int ret_type, int num_of_pars, Param *parameters); // declare function
float customAtoF(const char* str);
char* floatToString(float value);
char* extractFullPart(const char* floatString);
void type_error(int type_1, int type_2, int op_type, int Line, int Col); //print type error 
int get_result_type(int type_1, int type_2, int op_type, int Line, int Col); //type check and result type
int func_param_check(char *name, int num_of_pars, Param *parameters, int Line, int Col); // check parameters

/* typedef struct Texpression{
	
};
 */




