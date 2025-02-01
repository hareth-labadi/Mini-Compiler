%{
	
	#include "ts.h"
	#include "codeInter.h"
	
	typedef struct Variable{
		char* name;
		char* val;
		int type;
		int x;
		int y;
		int dim;
	}Variable;
	
	typedef struct Var_list_type{
        Variable* idf_array;  // Array of identifiers
        int count;         // Number of identifiers in the array
	} Var_list_type;
	
	typedef struct Param_list_type{
        Param* param_array;  // Array of identifiers
        int num_of_pars;         // Number of identifiers in the array
	} Param_list_type;
	
	typedef struct Fnct_info{
		char* function_name;
		int etiq;
		int fin_fnct;
	}Fnct_info;
		
    int Line = 1, Col = 1;
	
	int last_expr_type, last_term_type, last_factor_type, last_inter_expression_type;
	int last_condition_type, last_logical_term_type, last_logical_factor_type, last_comparison_expression_type;
	Fnct_info fnct_info[50];
	static int fnct_nbr = 0;
	char* cur_function;
	
	

	Var_list_type var_list;
	Param_list_type  param_list;
	Param typed_param;
	Variable array_variable;
	
	/**********************************declaration du code intermediare***********************************/
	// Function to get the string representation of an array
	// Function to convert an array variable to a string
	char* arrayToString(Variable arrayVar) {
		// Calculate the length of the resulting string
		int length = 0;

		if (arrayVar.dim == 1) {
			// 1D array
			// Format: name(x)
			length = strlen(arrayVar.name) + 5; // 5 = 2 brackets + 1 comma + 2 digits for x
		} else if (arrayVar.dim == 2) {
			// 2D array
			// Format: name(x,y)
			length = strlen(arrayVar.name) + 8; // 8 = 3 brackets + 2 commas + 2 digits for x + 2 digits for y
		} else {
			// Unsupported dimensions
			printf("Unsupported array dimensions\n");
			return NULL;
		}

		// Allocate memory for the resulting string
		char* result = (char*)malloc(length + 1); // +1 for the null terminator

		// Build the string manually
		int position = 0;

		// Copy the name
		strcpy(&result[position], arrayVar.name);
		position += strlen(arrayVar.name);

		// Add brackets and dimensions
		if (arrayVar.dim == 1) {
			// 1D array
			result[position++] = '(';
			position += sprintf(&result[position], "%d", arrayVar.x);
			result[position++] = ')';
		} else if (arrayVar.dim == 2) {
			// 2D array
			result[position++] = '(';
			position += sprintf(&result[position], "%d,%d", arrayVar.x, arrayVar.y);
			result[position++] = ')';
		}

		// Null-terminate the string
		result[position] = '\0';

		return result;
	}
	
	// Function to generate a new temporary variable
	char* new_temp() {
		char* temp = (char*)malloc(10); // Adjust the size as needed
		sprintf(temp, "Temp%d", temp_count++);
		return temp;
	}
	
	int findFunction(const char* targetFunctionName) {
		int i;
		for (i = 0; i < 50; ++i) {
			if (fnct_info[i].function_name != NULL && strcmp(fnct_info[i].function_name, targetFunctionName) == 0) {
				return i;
			}
		}
		// Return a special value (e.g., -1) to indicate that the function was not found
		return -1;
	}
	
	
	int bool_or_and = 0;
	int qc=0;
	char temp_result[20];
	char op[20];       // Assuming binary operators
	char arg1[20];
	char arg2[20];
	char rslt[20];
	char tmp[20];
	char factor_val[20], term_val[20], expr_val[20], inter_expr_val[20], assgn_val[20], return_val[20];
	char comp_expr_val[20], logc_factor_val[20], logc_term_val[20], cond_val[20];
	char comp_expr_op[20], logc_term_op[20], logc_factor_op[20], cond_op[20];
	int bool_or = 0, bool_and = 0;
	
	#define MAX_STACK_SIZE 50

	int fin_if[MAX_STACK_SIZE];
	int deb_else[MAX_STACK_SIZE];
	int fin_fnct[MAX_STACK_SIZE];
	int fin_while[MAX_STACK_SIZE];
	int deb_while[MAX_STACK_SIZE];
	static int stackTop = -1;  // Initialize the stack top to -1
	
	// Function to push an element onto the stack
	void push(int stack[], int value) {
		if (stackTop < MAX_STACK_SIZE - 1) {
			stack[++stackTop] = value;
		} else {
			printf("Stack overflow!\n");
		}
	}
	
	// Function to pop an element from the stack
	int pop(int stack[]) {
		if (stackTop >= 0) {
			return stack[stackTop--];
		} else {
			printf("Stack underflow!\n");
			return -1; // Return a default value indicating an error
		}
	}
	
	
	
	
	









	
	
	

	
	
    
%}

%union {
	//list_type  dec_variable_type;
    int entier;
    char* str;
    float reel;
	
}

//%type <list_type> dec_variable_list


%token END_OF_FILE_TOKEN
%token <str> IDF
%token <str> INT
%token <str> NBR
%token <str> STRING_LITERAL
%token <str> mc_FALSE <str> mc_TRUE <str> mc_EQ <str> mc_NE <str> mc_LE <str> mc_LT <str> mc_GE <str> mc_GT <str> mc_AND <str> mc_OR mc_CHARACTER mc_INTEGER mc_LOGICAL mc_REAL mc_DIMENSION mc_DOWHILE mc_ENDDO mc_IF mc_THEN mc_ELSE mc_ENDIF mc_ROUTINE mc_CALL mc_ENDR mc_PROGRAM mc_END mc_READ mc_WRITE mc_EQUIVALENCE
%token ';' '=' '(' ')' '*' '+' '-' '/' ','  
%token err
%type <reel> expression term factor inter_expression
%type <entier> condition logical_term logical_factor comparison_expression condition_statement 
%type <str> logical_opd logical_cmprt equality_cmprt


%start program

%%

program:
    function_declaration_list
    program_principal
{	
	setColor(0, 255, 0);
	printf("\nSyntaxe Correcte\n"); 
	setColor(255, 255, 255);
	YYACCEPT;
}
;

function_declaration_list:
    function_declaration_list function_declaration
	|
;

function_declaration:
	{incr_scope();}
    function_prototype
    declaration_list
    instruction_list
    return_statement
    mc_ENDR
	{
		// Ajout des quadruplets
		strcpy(op, "BR");
		strcpy(arg1, "");
		fnct_info[findFunction(cur_function)].fin_fnct = qc;
		strcpy(arg2, "vide");
		strcpy(rslt, "vide");
		quadr(op, arg1, arg2, rslt);
		strcpy(factor_val, rslt);
		hide_scope();
		
	}
;

function_prototype:
	mc_INTEGER mc_ROUTINE IDF '(' parameter_list ')' 
	{
			fnct_info[fnct_nbr].function_name = $3;
			cur_function = $3;
			fnct_info[fnct_nbr].etiq = qc;
			insertIdf($3, UNDEF, Line, 1);
			set_type($3, UNDEF, UNDEF, 0, 0, 0);
			func_declare($3, INT_TYPE, param_list.num_of_pars, param_list.param_array);
	}
	| mc_REAL mc_ROUTINE IDF '(' parameter_list ')'
	{
			fnct_info[fnct_nbr].function_name = $3;
			cur_function = $3;
			fnct_info[fnct_nbr].etiq = qc;
			insertIdf($3, UNDEF, Line, 1);
			set_type($3, UNDEF, UNDEF, 0, 0, 0);
			func_declare($3, REAL_TYPE, param_list.num_of_pars, param_list.param_array);
	}
	| mc_LOGICAL mc_ROUTINE IDF '(' parameter_list ')'
	{
			fnct_info[fnct_nbr].function_name = $3;
			cur_function = $3;
			fnct_info[fnct_nbr].etiq = qc;
			insertIdf($3, UNDEF, Line, 1);
			set_type($3, UNDEF, UNDEF, 0, 0, 0);
			func_declare($3, LOGC_TYPE, param_list.num_of_pars, param_list.param_array);
	}
	| mc_CHARACTER mc_ROUTINE IDF '(' parameter_list ')'
	{
			fnct_info[fnct_nbr].function_name = $3;
			cur_function = $3;
			fnct_info[fnct_nbr].etiq = qc;
			insertIdf($3, UNDEF, Line, 1);
			set_type($3, UNDEF, UNDEF, 0, 0, 0);
			func_declare($3, CHAR_TYPE, param_list.num_of_pars, param_list.param_array);
	}
;

parameter_list:
	nontyped_parameter_list
	| typed_parameter_list
;
nontyped_parameter_list:
	IDF
	{
		 // Insert the parameters into the array
        param_list.param_array = (Param*)malloc(sizeof(Param));
        param_list.param_array[0].par_name = $1;
		param_list.param_array[0].par_type = UNDEF;
		param_list.param_array[0].par_val = "NoV";
        param_list.num_of_pars = 1; 
	}
	| nontyped_parameter_list ',' IDF    
	{
		param_list.param_array = (Param*)realloc(param_list.param_array, (param_list.num_of_pars + 1) * sizeof(Param));
        param_list.param_array[param_list.num_of_pars].par_name = $3;             
		param_list.param_array[param_list.num_of_pars].par_type = UNDEF;
		param_list.param_array[param_list.num_of_pars].par_val = "NoV";
        param_list.num_of_pars = param_list.num_of_pars + 1; 	
	}
;

typed_parameter_list:
	typed_parameter
	{
		 // Insert the parameters into the array
        param_list.param_array = (Param*)malloc(sizeof(Param));
        param_list.param_array[0].par_name = typed_param.par_name;
		param_list.param_array[0].par_type = typed_param.par_type;
		param_list.param_array[0].par_val = "NoV";
        param_list.num_of_pars = 1; 
		
	}
	| typed_parameter_list ',' typed_parameter
	{
		param_list.param_array = (Param*)realloc(param_list.param_array, (param_list.num_of_pars + 1) * sizeof(Param));
        param_list.param_array[param_list.num_of_pars].par_name = typed_param.par_name;             
		param_list.param_array[param_list.num_of_pars].par_type = typed_param.par_type;
		param_list.param_array[param_list.num_of_pars].par_val = "NoV";
        param_list.num_of_pars = param_list.num_of_pars + 1; 	
		
	}
;

typed_parameter: 
	mc_INTEGER IDF  
	{
		typed_param.par_name = $2;
		typed_param.par_type = INT_TYPE;
	}
    | mc_REAL IDF
	{
		typed_param.par_name = $2;
		typed_param.par_type = REAL_TYPE;
	}
    | mc_LOGICAL IDF
	{
		typed_param.par_name = $2;
		typed_param.par_type = LOGC_TYPE;
	}
    | mc_CHARACTER IDF
	{
		typed_param.par_name = $2;
		typed_param.par_type = CHAR_TYPE;
	}
;

declaration_list:
    declaration_list declaration
	| 
;

declaration:  
	simple_declaration ';'
	| array_declaration ';'
	| string_declaration ';'
;


simple_declaration:
    mc_INTEGER dec_variable_list  
    {
        // Perform type assignment for mc_INTEGER
		int i;
        for (i = 0; i < var_list.count; i++) {
            insertIdf(var_list.idf_array[i].name, INT_TYPE, Line, 1);
			set_val(var_list.idf_array[i].name, extractFullPart(var_list.idf_array[i].val), get_scope());
			if(strcmp(var_list.idf_array[i].val, "NoV") != 0)
			{
				//Checking the type compatibility
				int t = get_result_type(INT_TYPE, var_list.idf_array[i].type, NONE, Line, Col);
			}
        }
    }
    | mc_REAL dec_variable_list
    {
        // Perform type assignment for mc_REAL
		int i;
        for (i = 0; i < var_list.count; i++) {
            insertIdf(var_list.idf_array[i].name, REAL_TYPE, Line, 1);
			set_val(var_list.idf_array[i].name, var_list.idf_array[i].val, get_scope());
			if(strcmp(var_list.idf_array[i].val, "NoV") != 0)
			{
				//Checking the type compatibility
				int t = get_result_type(REAL_TYPE, var_list.idf_array[i].type, NONE, Line, Col);
			}
        }
    }
    | mc_LOGICAL dec_variable_list
    {
        // Perform type assignment for mc_LOGICAL
		int i;
        for (i = 0; i < var_list.count; i++) {
            insertIdf(var_list.idf_array[i].name, LOGC_TYPE, Line, 1);
			set_val(var_list.idf_array[i].name, var_list.idf_array[i].val, get_scope());
			if(strcmp(var_list.idf_array[i].val, "NoV") != 0)
			{
				//Checking the type compatibility
				int t = get_result_type(LOGC_TYPE, var_list.idf_array[i].type, NONE, Line, Col);
			}
        }
    }
    | mc_CHARACTER dec_variable_list
    {
        // Perform type assignment for mc_CHARACTER
		int i;
        for (i = 0; i < var_list.count; i++) {
            insertIdf(var_list.idf_array[i].name, CHAR_TYPE, Line, 1);
			set_val(var_list.idf_array[i].name, var_list.idf_array[i].val, get_scope());
			if(strcmp(var_list.idf_array[i].val, "NoV") != 0)
			{
				//Checking the type compatibility
				int t = get_result_type(CHAR_TYPE, var_list.idf_array[i].type, NONE, Line, Col);
			}
        }
    }
;

array_declaration:
	mc_INTEGER IDF mc_DIMENSION  '(' INT ')' 
	{
			if(atoi($5) <= 0)
			{
				setColor(255, 0, 0);
                printf("\n\nSementical Error: None valid array size! at Line %d and Column %d\n", Line, Col);
                setColor(255, 255, 0);
				printf("<!> Array size must be greater than 0 \n\n");
				setColor(255, 255, 255);
			}
				
			insertIdf($2, UNDEF, Line, 1);
			set_type($2, ARRAY_TYPE, INT_TYPE, 1, atoi($5), 0);
			
			//quad for les boundries
			strcpy(op, "BOUNDS");
			strcpy(arg1, "1");
			strcpy(arg2, $5); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
			
			//quad for array declaration
			strcpy(op, "ADEC");
			strcpy(arg1, $2);
			strcpy(arg2, "vide"); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
			
			
	}
    | mc_REAL IDF mc_DIMENSION  '(' INT ')' 
	{
			if(atoi($5) <= 0)
			{
				setColor(255, 0, 0);
                printf("\n\nSementical Error: None valid array size! at Line %d and Column %d\n", Line, Col);
                setColor(255, 255, 0);
				printf("<!> Array size must be greater than 0 \n\n");
				setColor(255, 255, 255);
			}
			insertIdf($2, UNDEF, Line, 1);
			set_type($2, ARRAY_TYPE, REAL_TYPE, 1, atoi($5), 0);
			
			//quad for les boundries
			strcpy(op, "BOUNDS");
			strcpy(arg1, "1");
			strcpy(arg2, $5); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
			
			//quad for array declaration
			strcpy(op, "ADEC");
			strcpy(arg1, $2);
			strcpy(arg2, "vide"); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
	}
    | mc_LOGICAL IDF mc_DIMENSION  '(' INT ')' 
	{
			if(atoi($5) <= 0)
			{
				setColor(255, 0, 0);
                printf("\n\nSementical Error: None valid array size! at Line %d and Column %d\n", Line, Col);
                setColor(255, 255, 0);
				printf("<!> Array size must be greater than 0 \n\n");
				setColor(255, 255, 255);
			}
			insertIdf($2, UNDEF, Line, 1);
			set_type($2, ARRAY_TYPE, LOGC_TYPE, 1, atoi($5), 0);
			
			//quad for les boundries
			strcpy(op, "BOUNDS");
			strcpy(arg1, "1");
			strcpy(arg2, $5); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
			
			//quad for array declaration
			strcpy(op, "ADEC");
			strcpy(arg1, $2);
			strcpy(arg2, "vide"); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
	}
    | mc_CHARACTER IDF mc_DIMENSION  '(' INT ')'
	{
			if(atoi($5) <= 0)
			{
				setColor(255, 0, 0);
                printf("\n\nSementical Error: None valid array size! at Line %d and Column %d\n", Line, Col);
                setColor(255, 255, 0);
				printf("<!> Array size must be greater than 0 \n\n");
  			    setColor(255, 255, 255);
			}
			insertIdf($2, UNDEF, Line, 1);
			set_type($2, ARRAY_TYPE, CHAR_TYPE, 1, atoi($5), 0);
			
			//quad for les boundries
			strcpy(op, "BOUNDS");
			strcpy(arg1, "1");
			strcpy(arg2, $5); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
			
			//quad for array declaration
			strcpy(op, "ADEC");
			strcpy(arg1, $2);
			strcpy(arg2, "vide"); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
	}	
	| mc_INTEGER IDF mc_DIMENSION  '(' INT ',' INT ')' 
	{
			if(atoi($5) <= 0 || atoi($7) <= 0)
			{
				setColor(255, 0, 0);
                printf("\n\nSementical Error: None valid array size! at Line %d and Column %d\n", Line, Col);
                setColor(255, 255, 0);
				printf("<!> Array size must be greater than 0 \n\n");
				setColor(255, 255, 255);
			}
			insertIdf($2, UNDEF, Line, 1);
			set_type($2, ARRAY_TYPE, INT_TYPE, 2, atoi($5), atoi($7));
			
			//quad for boundries
			strcpy(op, "BOUNDS");
			strcpy(arg1, "1");
			strcpy(arg2, $5); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
			
			strcpy(op, "BOUNDS");
			strcpy(arg1, "2");
			strcpy(arg2, $7); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
			
			//quad for array declaration
			strcpy(op, "ADEC");
			strcpy(arg1, $2);
			strcpy(arg2, "vide"); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
	}
    | mc_REAL IDF mc_DIMENSION  '(' INT ',' INT ')' 
	{
			if(atoi($5) <= 0 || atoi($7) <= 0)
			{
				setColor(255, 0, 0);
                printf("\n\nSementical Error: None valid array size! at Line %d and Column %d\n", Line, Col);
                setColor(255, 255, 0);
				printf("<!> Array size must be greater than 0 \n\n");
				setColor(255, 255, 255);
			}
			insertIdf($2, UNDEF, Line, 1);
			set_type($2, ARRAY_TYPE, REAL_TYPE, 2, atoi($5), atoi($7));
			
			//quad for boundries
			strcpy(op, "BOUNDS");
			strcpy(arg1, "1");
			strcpy(arg2, $5); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
			
			strcpy(op, "BOUNDS");
			strcpy(arg1, "2");
			strcpy(arg2, $7); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
			
			//quad for array declaration
			strcpy(op, "ADEC");
			strcpy(arg1, $2);
			strcpy(arg2, "vide"); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
	}
    | mc_LOGICAL IDF mc_DIMENSION  '(' INT ',' INT ')' 
	{
			if(atoi($5) <= 0 || atoi($7) <= 0)
			{
				setColor(255, 0, 0);
                printf("\n\nSementical Error: None valid array size! at Line %d and Column %d\n", Line, Col);
                setColor(255, 255, 0);
				printf("<!> Array size must be greater than 0 \n\n");
				setColor(255, 255, 255);
			}
			insertIdf($2, UNDEF, Line, 1);
			set_type($2, ARRAY_TYPE, LOGC_TYPE, 2, atoi($5), atoi($7));
			
			//quad for boundries
			strcpy(op, "BOUNDS");
			strcpy(arg1, "1");
			strcpy(arg2, $5); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
			
			strcpy(op, "BOUNDS");
			strcpy(arg1, "2");
			strcpy(arg2, $7); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
			
			//quad for array declaration
			strcpy(op, "ADEC");
			strcpy(arg1, $2);
			strcpy(arg2, "vide"); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
	}
    | mc_CHARACTER IDF mc_DIMENSION  '(' INT ',' INT ')' 
	{
			if(atoi($5) <= 0 || atoi($7) <= 0)
			{
				setColor(255, 0, 0);
                printf("\n\nSementical Error: None valid array size! at Line %d and Column %d\n", Line, Col);
                setColor(255, 255, 0);
				printf("<!> Array size must be greater than 0 \n\n");
				setColor(255, 255, 255);
			}
			insertIdf($2, UNDEF, Line, 1);
			set_type($2, ARRAY_TYPE, CHAR_TYPE, 2, atoi($5), atoi($7));
			
			//quad for boundries
			strcpy(op, "BOUNDS");
			strcpy(arg1, "1");
			strcpy(arg2, $5); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
			
			strcpy(op, "BOUNDS");
			strcpy(arg1, "2");
			strcpy(arg2, $7); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
			
			//quad for array declaration
			strcpy(op, "ADEC");
			strcpy(arg1, $2);
			strcpy(arg2, "vide"); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
	}
;
	
string_declaration:
	mc_CHARACTER IDF '*' INT 
	{
		if(atoi($4) <= 0)
		{
			setColor(255, 0, 0);
            printf("\n\nSementical Error: None valid string size! at Line %d and Column %d\n", Line, Col);
            setColor(255, 255, 0);
		    printf("<!> String size must be greater than 0 \n\n");
		    setColor(255, 255, 255);
		}
		insertIdf($2, UNDEF, Line, 1);
		set_type($2, CHAR_TYPE, CHAR_TYPE, 1, atoi($4), 0);
		set_val($2, "Hello world", get_scope());
		
		//quad for les boundries
		strcpy(op, "BOUNDS");
		strcpy(arg1, "1");
		strcpy(arg2, $4); 
		strcpy(rslt, "vide"); 
		quadr(op, arg1, arg2, rslt );
			
		//quad for array declaration
		strcpy(op, "ADEC");
		strcpy(arg1, $2);
		strcpy(arg2, "vide"); 
		strcpy(rslt, "vide"); 
		quadr(op, arg1, arg2, rslt );
	}
	
;

dec_variable_list:
    IDF
    {
         // Insert the identifier into the array
        var_list.idf_array = (Variable*)malloc(sizeof(Variable));
        var_list.idf_array[0].name = $1;
		var_list.idf_array[0].val = "NoV";
        var_list.count = 1; 
    }
    | IDF '=' NBR
    {
        // Insert the identifier into the array
        var_list.idf_array = (Variable*)malloc(sizeof(Variable));
        var_list.idf_array[0].name = $1;
		var_list.idf_array[0].val = $3;
		var_list.idf_array[0].type = REAL_TYPE;
		
        var_list.count = 1;
        
    }
	| IDF '=' INT
    {
        // Insert the identifier into the array
        var_list.idf_array = (Variable*)malloc(sizeof(Variable));
        var_list.idf_array[0].name = $1;
		var_list.idf_array[0].val = $3;
		var_list.idf_array[0].type = INT_TYPE;
        var_list.count = 1;
        
    }
    | dec_variable_list ',' IDF
    {
        // Expand the array and insert the new identifier
		var_list.idf_array = (Variable*)realloc(var_list.idf_array, (var_list.count + 1) * sizeof(Variable));
        var_list.idf_array[var_list.count].name = $3;             
		var_list.idf_array[var_list.count].val = "NoV";
        var_list.count = var_list.count + 1; 
    }
    | dec_variable_list ',' IDF '=' NBR
    {
        // Expand the array and insert the new identifier
        var_list.idf_array = (Variable*)realloc(var_list.idf_array, (var_list.count + 1) * sizeof(Variable));
        var_list.idf_array[var_list.count].name = $3;
		var_list.idf_array[var_list.count].val = $5;
		var_list.idf_array[var_list.count].type = REAL_TYPE;
        var_list.count = var_list.count + 1; 
    }
	| dec_variable_list ',' IDF '=' INT
    {
        // Expand the array and insert the new identifier
        var_list.idf_array = (Variable*)realloc(var_list.idf_array, (var_list.count + 1) * sizeof(Variable));
        var_list.idf_array[var_list.count].name = $3;
		var_list.idf_array[var_list.count].val = $5;
		var_list.idf_array[var_list.count].type = INT_TYPE;
        var_list.count = var_list.count + 1; 
    }
    ;

inst_variable_list:
    IDF
	| array_var
    | inst_variable_list ',' IDF
	| inst_variable_list ',' array_var
;

array_var:
    IDF '(' expression ')'
    {
		int index = $3;
		array_variable.name = $1;
		array_variable.type = get_type($1, get_scope());
		array_variable.dim = 1;
		//array_variable.val = ........;
		array_variable.x = index;
		array_variable.y = 0;
		
        if (index <= 0)
        {
            setColor(255, 0, 0);
            printf("\n\nSemantic Error: Invalid array INDEX! at Line %d and Column %d\n", Line, Col);
            setColor(255, 255, 0);
            printf("<!> Array index must not be negative or 0 \n\n");
            setColor(255, 255, 255);
        }

        struct Size arraySize = get_size($1, get_scope());
        if (index > arraySize.x)
        {
            setColor(255, 0, 0);
            printf("\n\nSemantic Error: Array INDEX out of the range! at Line %d and Column %d\n", Line, Col);
            setColor(255, 255, 0);
            printf("<!> Array index must be lower than the array size \n\n");
            setColor(255, 255, 255);
        }

        insertIdf($1, UNDEF, Line, 0);
        // Set value if needed
    }
    | IDF '(' expression ',' expression ')'
    {
		
        int index1 = $3;
        int index2 = $5;
		array_variable.name = $1;
		array_variable.type = get_type($1, get_scope());
		array_variable.dim = 2;
		array_variable.val = "15.5";  //get the value from the info of array_variable
		array_variable.x = index1;
		array_variable.y = index2;
		

        if (index1 <= 0 || index2 <= 0)
        {
			 setColor(255, 0, 0);
            printf("\n\nSemantic Error: Invalid array INDEX! at Line %d and Column %d\n", Line, Col);
            setColor(255, 255, 0);
            printf("<!> Array indices must not be negative or 0 \n\n");
            setColor(255, 255, 255);
		}

        struct Size arraySize = get_size($1, get_scope());
        if (index1 > arraySize.x || index2 > arraySize.y)
        {
			setColor(255, 0, 0);
            printf("\n\nSemantic Error: Array INDEX out of the range! at Line %d and Column %d\n", Line, Col);
            setColor(255, 255, 0);
            printf("<!> Array indices must be lower than the array size \n\n");
            setColor(255, 255, 255);
		}

        insertIdf($1, UNDEF, Line, 0);
        // Set value if needed
    } 
;
	
expression: term                        { 
											$$ = $1;
											last_expr_type = last_term_type;
											strcpy(expr_val, term_val); 
											
											
											
											
										}
          | expression '+' term         { 
                                            last_expr_type = get_result_type(last_expr_type, last_term_type, ARITHM_OP, Line, Col);
                                            $$ = $1 + $3;
											
											
											// Ajout des quadruplets
											strcpy(op, "+");
											strcpy(arg1, expr_val);
											strcpy(arg2, term_val);
											strcpy(rslt, new_temp());
											quadr(op, arg1, arg2, rslt);
											strcpy(expr_val, rslt); 
                                           
                                        }
          | expression '-' term         { 
                                            last_expr_type = get_result_type(last_expr_type, last_term_type, ARITHM_OP, Line, Col);
                                            $$ = $1 - $3; 
											
											// Ajout des quadruplets
											strcpy(op, "-");
											strcpy(arg1, expr_val);
											strcpy(arg2, term_val);
											strcpy(rslt, new_temp());
											quadr(op, arg1, arg2, rslt);
											strcpy(expr_val, rslt); 
                                            
                                        }
          ;

term: factor                            { 
											 $$ = $1;
											 
											last_term_type = last_factor_type;
											strcpy(term_val, factor_val);
											
											
										}
    | term '*' factor                   { 
                                            last_term_type = get_result_type(last_term_type, last_factor_type, ARITHM_OP, Line, Col);
                                            $$ = $1 * $3; 
											
											strcpy(op, "*");
											strcpy(arg1, term_val);
											strcpy(arg2, factor_val);
											strcpy(rslt, new_temp());
											quadr(op, arg1, arg2, rslt);

											// Update term_val
											strcpy(term_val, rslt);
											
											
                                        }
    | term '/' factor                   {   
                                            last_term_type = get_result_type(last_term_type, last_factor_type, ARITHM_OP, Line, Col);
                                            if ($3 == 0) {
                                                setColor(255, 0, 0);
                                                printf("\n\n<!>Semantical Error: Division by zero! Line %d and Column %d\n", Line, Col);
                                                setColor(255, 255, 255);
                                                exit(1);
                                            } else {
                                                $$ = $1 / $3;
												
												// Ajout des quadruplets
												strcpy(op, "/");
												strcpy(arg1, term_val);
												strcpy(arg2, factor_val);
												strcpy(rslt, new_temp());

												quadr(op, arg1, arg2, rslt);

												// Update term_val
												strcpy(term_val, rslt); 
                                            }
                                        }
;

factor: '(' expression ')'              { 
											$$ = $2;
											last_factor_type = last_expr_type;
											strcpy(factor_val, expr_val);
											

										}
      | '-' factor                      { 
											$$ = - $2;
											
											// Ajout des quadruplets
											strcpy(op, "-");
											strcpy(arg1, "0");
											strcpy(arg2, factor_val);
											strcpy(rslt, new_temp());
											quadr(op, arg1, arg2, rslt);
											strcpy(factor_val, rslt);
											
										
										}
      | IDF                             { 
											$$ = customAtoF(get_val($1, get_scope()));
											last_factor_type = get_type($1, get_scope());
											
											// Ajout des quadruplets
											strcpy(factor_val, $1); 
										}
      | NBR                             { 
											$$ = customAtoF($1);
											last_factor_type = REAL_TYPE;
											
											 // Ajout des quadruplets
											strcpy(factor_val, $1);
											 
										}
      | INT                             { 
											$$ = customAtoF($1); 
											last_factor_type = INT_TYPE;
											
											 // Ajout des quadruplets
											strcpy(factor_val, $1);
											
										} 
	  | array_var                       {
											$$ = customAtoF(array_variable.val);
											last_factor_type = array_variable.type;
											
											
											char* g = "";
											 // Ajout des quadruplets
											
											strcpy(factor_val, arrayToString(array_variable));
											
		  
	                                    }
;	
  

condition:
    condition mc_OR logical_term 
    { 
		bool_or_and = 1;
		bool_or = 1;
		
		last_condition_type = get_result_type(last_condition_type, last_logical_term_type, BOOL_OP, Line, Col);
        $$ = ($1 || $3);
		
		// Ajout des quadruplets
		strcpy(op, cond_op);
		strcpy(arg1, "deb_than");
		strcpy(arg2, cond_val);
		strcpy(rslt, "vide");
		quadr(op, arg1, arg2, rslt);
		
		
		strcpy(op, logc_term_op);
		strcpy(arg1, "deb_than");
		strcpy(arg2, logc_term_val);
		strcpy(rslt, "vide");
		quadr(op, arg1, arg2, rslt);
		
		strcpy(op, "BR");
		strcpy(arg1, "deb_else");
		strcpy(arg2, "vide");
		strcpy(rslt, "vide");
		quadr(op, arg1, arg2, rslt);
		
    }
    | logical_term
    {
		
        $$ = $1;
        last_condition_type = last_logical_term_type;
		strcpy(cond_op, logc_term_op );
		strcpy(cond_val, logc_term_val );
    }
;

logical_term:
    logical_term mc_AND logical_factor
    { 
		bool_or_and = 1;
		bool_and = 1;
		last_logical_term_type = get_result_type(last_logical_term_type, last_logical_factor_type, BOOL_OP, Line, Col);
        $$ = ($1 && $3);
		
		// Ajout des quadruplets
		if (strcmp(logc_term_op, "BZ") == 0) strcpy(logc_term_op, "BNZ");
		if (strcmp(logc_term_op, "BNZ") == 0) strcpy(logc_term_op, "BZ");
		if (strcmp(logc_term_op, "BP") == 0) strcpy(logc_term_op, "BMZ");
		if (strcmp(logc_term_op, "BMZ") == 0) strcpy(logc_term_op, "BP");
		if (strcmp(logc_term_op, "BM") == 0) strcpy(logc_term_op, "BPZ");
		if (strcmp(logc_term_op, "BPZ") == 0) strcpy(logc_term_op, "BM");
		
		strcpy(op, logc_term_op);
		strcpy(arg1, "deb_else");
		strcpy(arg2, logc_term_val);
		strcpy(rslt, "vide");
		quadr(op, arg1, arg2, rslt);
		
		
		strcpy(op, logc_factor_op);
		strcpy(arg1, "deb_else");
		strcpy(arg2, logc_factor_val);
		strcpy(rslt, "vide");
		quadr(op, arg1, arg2, rslt);
		
		
		
		
		
		
        
    }
    | logical_factor
    {
		
        $$ = $1;
        last_logical_term_type = last_logical_factor_type;
		strcpy(logc_term_op, logc_factor_op );
		strcpy(logc_term_val, logc_factor_val );
		
    }
;

logical_factor:
    '(' condition ')'
    {
		
        $$ = $2;
        last_logical_factor_type = last_condition_type;
		strcpy(logc_factor_op, cond_op );
		strcpy(logc_factor_val, cond_val );

    }
    | logical_opd
    {
		
        $$ = atoi($1);
        last_logical_factor_type = LOGC_TYPE;
		strcpy(logc_factor_val, $1 );
		//cas special TRUE && FLASE 
    }
	| '(' comparison_expression ')'
	{
		
		$$ = $2;
		last_logical_factor_type = last_comparison_expression_type;
		strcpy(logc_factor_op, comp_expr_op );
		strcpy(logc_factor_val, comp_expr_val );
		
	}
;


comparison_expression:
    expression logical_cmprt inter_expression
    {
        last_comparison_expression_type = get_result_type(last_expr_type, last_inter_expression_type, REL_OP, Line, Col); 
		//$$ = compare_expression($1, $2, $3);
		
		// Ajout des quadruplets
		strcpy(op, "-");
		strcpy(arg1, expr_val);
		strcpy(arg2, inter_expr_val);
		strcpy(rslt, new_temp());
		quadr(op, arg1, arg2, rslt);
		strcpy(comp_expr_val, rslt);
		
		if( strcmp($2, ">" ) ==  0 )
			strcpy(comp_expr_op, "BP" );
		
		else if( strcmp($2, ">=" ) == 0 )
			strcpy(comp_expr_op, "BPZ" );
		
		else  if( strcmp($2, "<" ) == 0 )
			strcpy(comp_expr_op, "BM" );
		
		else //if($2 == "<=")	
			strcpy(comp_expr_op, "BMZ" );
		
    }
	
	
    | expression equality_cmprt inter_expression
    {
        last_comparison_expression_type = get_result_type(last_expr_type, last_inter_expression_type, EQU_OP, Line, Col);; 
		//$$ = compare_expression($1, $2, $3);
		
		// Ajout des quadruplets
		strcpy(op, "-");
		strcpy(arg1, expr_val);
		strcpy(arg2, inter_expr_val);
		strcpy(rslt, new_temp());
		quadr(op, arg1, arg2, rslt);
		strcpy(comp_expr_val, rslt);
		
		if(strcmp($2, "==") == 0)
			strcpy(comp_expr_op, "BZ");
		
		else
			strcpy(comp_expr_op, "BNZ");
		
	}
	
    | STRING_LITERAL equality_cmprt STRING_LITERAL
    {
        last_comparison_expression_type = get_result_type(CHAR_TYPE, CHAR_TYPE, EQU_OP, Line, Col);
		//$$ = compare_string($1, $2, $3);
		
		// Ajout des quadruplets
		if(strcpy($2, "==") == 0)
			strcpy(comp_expr_op, "BE");
		
		else
			strcpy(comp_expr_op, "BNE");
			
	}
	
    | logical_opd equality_cmprt logical_opd 
    {
        last_comparison_expression_type = get_result_type(LOGC_TYPE, LOGC_TYPE, EQU_OP, Line, Col);
		//$$ = compare_logc($1, $2, $3);
		
		// Ajout des quadruplets
		if(strcmp($2, "==" ) == 0 )
			strcpy(comp_expr_op, "BE" );
		
		else
			strcpy(comp_expr_op, "BNE" );
		
	}
	| expression equality_cmprt logical_opd
	{
        last_comparison_expression_type = get_result_type(last_expr_type, LOGC_TYPE, EQU_OP, Line, Col);
		//$$ = compare_logc($1, $2, $3);
		
		// Ajout des quadruplets
		if(strcmp($2, "==" ) == 0 )
			strcpy(comp_expr_op, "BE" );
		
		else
			strcpy(comp_expr_op, "BNE" );
		
	}
	| logical_opd equality_cmprt expression
	{
        last_comparison_expression_type = get_result_type(LOGC_TYPE, last_expr_type, EQU_OP, Line, Col);
		//$$ = compare_logc($1, $2, $3);
		
		// Ajout des quadruplets
		if(strcmp($2, "==" ) == 0 )
			strcpy(comp_expr_op, "BE" );
		
		else
			strcpy(comp_expr_op, "BNE" );
		
	}
;

inter_expression:
	expression      {
						$$ = $1;
						last_inter_expression_type = last_expr_type;
						strcpy(inter_expr_val, expr_val);
					}
                   
;

logical_cmprt:
     mc_LT
	| mc_GT
	| mc_LE
	| mc_GE
;

equality_cmprt:
	mc_EQ
	| mc_NE
;

logical_opd:
	mc_TRUE         {$$ = $1;}
	| mc_FALSE		{$$ = $1;}
;

program_principal:
    mc_PROGRAM IDF
	{
		insertIdf($2, UNDEF, Line, 1);
		
	}
    declaration_list
	{
		//dumpIDF();
	}
    instruction_list
    mc_END 
;

instruction_list:
    instruction
    | instruction_list instruction
;

instruction:
    assignment
    | read_statement
    | write_statement
    | function_call
    | if_statement
	| if_else_statement
    | do_while_statement
	| equivalence_statement
;

assignment:
    IDF '=' expression ';'
	{
		
		if( get_result_type(get_type($1, get_scope()), last_expr_type, NONE, Line, Col) == INT_TYPE)
			set_val($1, extractFullPart(floatToString($3)), get_scope()); 
		else
			set_val($1, floatToString($3), get_scope());
			
		
		// Ajout des quadruplets
		strcpy(assgn_val, expr_val); 
        strcpy(op, ":=");
        //strcpy(arg1, floatToString($3));
		strcpy(arg1, assgn_val);
		strcpy(arg2, "vide");
        quadr(op, arg1, arg2, $1);
	
	}
	| IDF '=' logical_opd ';'
	{
		set_val($1, $3, get_scope());
		//printf("The Idf %s, the val %s\n", $1, $3);
		int y = get_result_type(get_type($1, get_scope()), LOGC_TYPE, NONE, Line, Col);
		
		// Ajout des quadruplets
		strcpy(op, ":=");
		strcpy(arg1, $3);
		strcpy(arg2, "vide");
        quadr(op, arg1, arg2, $1);  
		
		
	}
	| IDF '=' STRING_LITERAL ';'
	{
		set_val($1, $3, get_scope());
		int y = get_result_type(get_type($1, get_scope()), CHAR_TYPE, NONE, Line, Col);
		
		// Ajout des quadruplets
		strcpy(op, ":=");
		strcpy(arg1, $3);
		strcpy(arg2, "vide");
        quadr(op, arg1, arg2, $1);
	}
	| array_var '=' expression ';'   
	{
		int y = get_result_type(array_variable.type, last_expr_type, NONE, Line, Col);
		//valueeeeeeeee
		
		// Ajout des quadruplets pour une assignation à un tableau
		strcpy(assgn_val, expr_val);
		strcpy(op, ":=");
		//strcpy(arg1,floatToString($3) );
		strcpy(arg1, assgn_val);
		strcpy(arg2, "vide"); 
		strcpy(rslt, arrayToString(array_variable)); 
        quadr(op, arg1, arg2, rslt );
	}
	| array_var '=' logical_opd ';'
	{
		int y = get_result_type(get_type(array_variable.name, get_scope()), LOGC_TYPE, NONE, Line, Col);
		//valueeeeeeeee
		// Ajout des quadruplets pour une assignation à un tableau
		strcpy(op, ":=");
		strcpy(arg1, $3 );
		strcpy(arg2, "vide"); 
		strcpy(rslt, arrayToString(array_variable)); 
        quadr(op, arg1, arg2, rslt );
	}
	
;

read_statement:
    mc_READ '(' IDF ')' ';'
	| mc_READ '(' array_var ')' ';'  	
;

write_statement:
    mc_WRITE  '(' message ')' ';'
;

message: 
	not_void_message
	| void_message
;
	
not_void_message:
	elt_message
	| not_void_message ',' elt_message     
;

void_message:
;

elt_message:
	STRING_LITERAL  
	| expression
;

function_call:
    IDF '=' mc_CALL IDF '(' argument_list ')' ';'
	{
		int y = get_result_type(get_type($1, get_scope()), get_type($4, 1), NONE, Line, Col);
		int z = func_param_check($4, param_list.num_of_pars, param_list.param_array, Line, Col);
		
		// Ajout des quadruplets pour le branchement vers la fonction
		strcpy(op, "BR");
		strcpy(arg1, extractFullPart(floatToString(fnct_info[findFunction($4)].etiq)) );
		strcpy(arg2, "vide"); 
		strcpy(rslt, "vide"); 
        quadr(op, arg1, arg2, rslt );
		
		ajour_quad(fnct_info[findFunction($4)].fin_fnct, 1, extractFullPart(floatToString(qc)));
		
		// Ajout des quadruplets pour l'affectation
		strcpy(op, ":=");
		strcpy(arg1, return_val );
		strcpy(arg2, "vide"); 
		strcpy(rslt, $1); 
        quadr(op, arg1, arg2, rslt );
		
		fnct_info[findFunction($4)].fin_fnct = qc;	
	}
;

return_statement:
    IDF '=' expression ';'
	{
		
		if(strcmp($1, fnct_info[fnct_nbr].function_name) != 0)
		{
			setColor(255, 0, 0);
            printf("\n\nSemantic Error: return name must be the same as the fucntion name! at Line %d and Column %d\n", Line, Col);
            setColor(255, 255, 0);
            printf("%s != %s\n\n", $1, fnct_info[fnct_nbr].function_name);
            setColor(255, 255, 255);
			exit(1);
			
		}
		int y = get_result_type(get_type($1, get_scope()), last_expr_type, NONE, Line, Col);
		strcpy(return_val, expr_val );
		set_val($1, floatToString($3), get_scope());
		fnct_nbr ++;
	}
;

argument_list:
    | expression
	{
		 // Insert the parameters into the array
        param_list.param_array = (Param*)malloc(sizeof(Param));
        param_list.param_array[0].par_name = "NoN";
		param_list.param_array[0].par_type = last_expr_type;
		param_list.param_array[0].par_val = floatToString($1);
        param_list.num_of_pars = 1; 
	}
    | argument_list ',' expression 
	{
		param_list.param_array = (Param*)realloc(param_list.param_array, (param_list.num_of_pars + 1) * sizeof(Param));
        param_list.param_array[param_list.num_of_pars].par_name = "NoN";             
		param_list.param_array[param_list.num_of_pars].par_type = last_expr_type;
		param_list.param_array[param_list.num_of_pars].par_val = floatToString($3);
        param_list.num_of_pars = param_list.num_of_pars + 1; 
	}
;

condition_statement:
	condition                       {$$ = $1}
	| comparison_expression			{$$ = $1}
;

do_while_statement:
	D instruction_list mc_ENDDO ';' 
	{
		sprintf(tmp, "%d", qc);
		int previousLabel = pop(fin_while);
		ajour_quad(previousLabel, 1, tmp);
		
		// Ajout des quadruplets pour le branchement vers la fonction
		strcpy(op, "BR");
		previousLabel = pop(deb_while); 
		sprintf(tmp, "%d", previousLabel);
		strcpy(arg1, tmp );
		strcpy(arg2, "vide"); 
		strcpy(rslt, "vide"); 
		quadr(op, arg1, arg2, rslt );
		
	}
;
	
D: 
	mc_DOWHILE '(' condition_statement ')' 
	{
		
		if(bool_or_and == 0)
		{
			// Ajout des quadruplets
			if (strcmp(comp_expr_op, "BZ") == 0) strcpy(comp_expr_op, "BNZ");		
			if (strcmp(comp_expr_op, "BNZ") == 0) strcpy(comp_expr_op, "BZ");
			if (strcmp(comp_expr_op, "BP") == 0) strcpy(comp_expr_op, "BMZ");
			if (strcmp(comp_expr_op, "BMZ") == 0) strcpy(comp_expr_op, "BP");
			if (strcmp(comp_expr_op, "BM") == 0) strcpy(comp_expr_op, "BPZ");
			if (strcmp(comp_expr_op, "BPZ") == 0) strcpy(comp_expr_op, "BM");		
					
			// Ajout des quadruplets pour le branchement vers la fonction
			push(fin_while, qc);
			push(deb_while, qc);
			strcpy(op, comp_expr_op);
			strcpy(arg1, "fin_while" );
			strcpy(arg2, comp_expr_val); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
			bool_or_and = 0;
			bool_and = 0;
			bool_or = 0;
					
		}
		
		
		
		push(fin_while, qc); /////////////condition
		bool_or_and = 0;
		bool_and = 0;
		bool_or = 0;
	}
;
	
	

if_statement:
    A mc_THEN instruction_list mc_ENDIF
    {	
		sprintf(tmp, "%d", qc);
        int previousLabel = pop(fin_if); 
        ajour_quad(previousLabel, 1, tmp);
    }
;
	
A:
    mc_IF '(' condition_statement ')' 
    {	
		if(bool_or_and == 0)
		{
			// Ajout des quadruplets
			if (strcmp(comp_expr_op, "BZ") == 0) strcpy(comp_expr_op, "BNZ");		
			if (strcmp(comp_expr_op, "BNZ") == 0) strcpy(comp_expr_op, "BZ");
			if (strcmp(comp_expr_op, "BP") == 0) strcpy(comp_expr_op, "BMZ");
			if (strcmp(comp_expr_op, "BMZ") == 0) strcpy(comp_expr_op, "BP");
			if (strcmp(comp_expr_op, "BM") == 0) strcpy(comp_expr_op, "BPZ");
			if (strcmp(comp_expr_op, "BPZ") == 0) strcpy(comp_expr_op, "BM");		
					
			// Ajout des quadruplets pour le branchement vers la fonction
			push(fin_if, qc);
			strcpy(op, comp_expr_op);
			strcpy(arg1, "fin_if" );
			strcpy(arg2, comp_expr_val); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
			bool_or_and = 0;
			bool_and = 0;
			bool_or = 0;
					
		}
		push(fin_if, qc); ////condition
		bool_or_and = 0;
		bool_and = 0;
		bool_or = 0;
    }
    ;
	
if_else_statement:

		B mc_ELSE instruction_list mc_ENDIF
			{	
				sprintf(tmp, "%d", qc);
				int previousLabel = pop(fin_if); 
				ajour_quad(previousLabel, 1, tmp);
			}
;

B:
	C mc_THEN instruction_list
	{
		// Ajout des quadruplets pour le branchement vers la fonction
		push(fin_if, qc);
		strcpy(op, "BR");
		strcpy(arg1, "fin_if" );
		strcpy(arg2, "vide"); 
		strcpy(rslt, "vide"); 
		quadr(op, arg1, arg2, rslt );
		sprintf(tmp,"%d",qc); 
		int previousLabel = pop(fin_if);
		ajour_quad(previousLabel,1,tmp);

	}
;

C:
	mc_IF ',' '(' condition_statement ')'
	{
				
		if(bool_or_and == 0)
		{
			// Ajout des quadruplets
			if (strcmp(comp_expr_op, "BZ") == 0) strcpy(comp_expr_op, "BNZ");		
			if (strcmp(comp_expr_op, "BNZ") == 0) strcpy(comp_expr_op, "BZ");
			if (strcmp(comp_expr_op, "BP") == 0) strcpy(comp_expr_op, "BMZ");
			if (strcmp(comp_expr_op, "BMZ") == 0) strcpy(comp_expr_op, "BP");
			if (strcmp(comp_expr_op, "BM") == 0) strcpy(comp_expr_op, "BPZ");
			if (strcmp(comp_expr_op, "BPZ") == 0) strcpy(comp_expr_op, "BM");		
					
			// Ajout des quadruplets pour le branchement vers la fonction
			strcpy(op, comp_expr_op);
			strcpy(arg1, "deb_else" );
			strcpy(arg2, comp_expr_val); 
			strcpy(rslt, "vide"); 
			quadr(op, arg1, arg2, rslt );
			bool_or_and = 0;	
			bool_and = 0;
			bool_or = 0;
					
		}
		push(deb_else, qc);
		bool_or_and = 0;
		bool_and = 0;
		bool_or = 0;
	}
;


equivalence_statement:
    mc_EQUIVALENCE '(' inst_variable_list ')' ',' '(' inst_variable_list ')' ';'
;

%%
int yyerror(char *msg)
{
	setColor(255, 0, 0);
	printf ("\n\nErreur Syntaxique a ligne %d a colonne %d \n", Line,Col);
	setColor(255, 255, 255);
	return 1;
}
/*
int main()
{
	//initialisation();
	yyparse();
	//afficher();
	return 0;
}
*/
int yywrap(void)
{
	return 0;
}
