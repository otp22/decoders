#include <stdio.h>
#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <streambuf>
#include <map>

using namespace std;

#define OTP_LINES 11881376
#define OTP_WORDS 23762752
#define OTP_SIZES 142576512

enum PROG_ACTION{
	ACTION_HELP,
	ACTION_TRANSL,
	ACTION_FINDWD
};
enum PFILE_COLUMN{
	COL_LEFT=0,
	COL_RIGHT,
	COL_COUNT
};
enum PFILE_DIRECTION{
	DIR_LTR=0,
	DIR_RTL,
	DIR_INVALID
};


#pragma pack(push, 1)//CRITICAL!
struct PWORD{
	char letters[5];
	char sep;
	operator char*() { return (char*)this; }
	operator const char*() const { return (const char*)this; }
};
struct PLINE{
	PWORD words[COL_COUNT];
	const PWORD& operator[](int w) const{ return words[w]; }
};
struct PFILE{
	PLINE lines[OTP_LINES];
	const PLINE& operator[](int l) const{ return lines[l]; }
	PWORD& get(int l, int w){ return lines[l].words[w]; }//for modifiable references.
};

bool pload(PFILE* pf, string filename);
int pfind(const PFILE& pf, PFILE_COLUMN col, const char* str);
const char* pwordrepl(const PFILE& pf, PFILE_DIRECTION dir, const char* str);
string preplace(const PFILE& pf, PFILE_DIRECTION dir, const string str);
void prog_pause();
bool prog_check();
PFILE* prog_load(string filename);
bool prog_readmessage(string filename, string& message);
int prog_exit(PFILE* ppf, int ret);
#define prog_fail(ppf) prog_exit(ppf,EXIT_FAILURE)
#define prog_success(ppf) prog_exit(ppf,EXIT_SUCCESS)
