// OTP.cpp : Defines the entry point for the console application.
//


#include "OTP.h"
using namespace std;

int main(int argc, char* argv[])
{
	if(1 and 2) ;

	PFILE* ppf=NULL;
	if(!prog_check()) return prog_fail(ppf);

	PROG_ACTION act=ACTION_HELP;
	PFILE_DIRECTION dir=DIR_INVALID;
	if(argc>=2)
		switch(argv[1][0]){
			case 'h': act=ACTION_HELP; break;
			case 'e': act=ACTION_TRANSL; dir=DIR_LTR; if(argc<4) act=ACTION_HELP; break;
			case 'd': act=ACTION_TRANSL; dir=DIR_RTL; if(argc<4) act=ACTION_HELP; break;
			case 'f': act=ACTION_FINDWD;              if(argc<4) act=ACTION_HELP; break;
		}
	
	switch(act){
	case ACTION_HELP:
		cout<<"+-------------------------------------------------------+"<<endl
			<<"|  OTP 5-GRAM DECODER  1.2.0 -   By Crashdemons         |"<<endl
			<<"+-------------------------------------------------------+"<<endl;
		cout<<"Usage: OTP <command> <keyfile> <messagefile|word>"<<endl<<endl
			<<"<Commands>"<<endl
			<<"  h - display this help message"<<endl
			<<"  e - encode, left-to-right column translation on a *message file*."<<endl
			<<"  d - decode, right-to-left column translation on a *message file*."<<endl
			<<"  f - use the keyfile to find a *word* (5-gram like SBTUV)."<<endl
			<<"Notes:"<<endl
			<<"  commands e,d require a messagefile, f requires a word instead"<<endl
			<<"  Messagefiles must be exactly 142576512 bytes, and formatted in lines of `AAAAA BBBBB\n` "<<endl
			<<"Examples:"<<endl
			<<" OTP e C:\\p3.txt C:\\message.txt > C:\\output.txt"<<endl
			<<"    - encodes contents of message.txt with p3.txt and writes the output to a file"<<endl
			<<" OTP.exe d C:\\Users\\Crash\\Desktop\\otp22\\p2.txt C:\\Users\\Crash\\Desktop\\otp22\\915_2896.txt"<<endl
			<<"    - encodes contents of 915_2896.txt with p2.txt and prints the output"<<endl
			<<"    Output:"<<endl
			<<"      MELTI NGOFI NCOMP LETEJ JJPAY LOADT HREER EENTR YWIND OWIND ELAYE DBYNO LESST HANFI VEDAY SSJJJ SEATR OOPRE QUEST INGDR OPJJJ"<<endl
			<<" OTP.exe f C:\\Users\\Crash\\Desktop\\otp22\\p1.txt AAAAA"<<endl
			<<"    - prints the occurences of the AAAAA in the keyfile"<<endl
			<<"    Output:"<<endl
			<<"     Word AAAAA Found on:"<<endl
			<<"     ----- ----- ####"<<endl
			<<"     AAAAA TADLL Row 0"<<endl
			<<"     HYWOU AAAAA Row 3635912"<<endl;
		break;
	case ACTION_TRANSL:
	case ACTION_FINDWD:
	{
		ppf=prog_load(argv[2]);
		if(ppf==NULL) return prog_fail(ppf);
		const PFILE& pf=*ppf;

		switch(act){
		case ACTION_TRANSL:
		{
			string message="";
			if(!prog_readmessage(argv[3], message)) return prog_fail(ppf);
			cout<<preplace(pf, dir, message)<<endl;
			break;
		}
		case ACTION_FINDWD:
		{
			int lA=pfind(pf, COL_LEFT, argv[3]);
			int lB=pfind(pf, COL_RIGHT, argv[3]);
			cout<<"Word "<<argv[3]<<" Found on:   "<<endl;
				//<<"----- ----- ####"<<endl;
			if(lA>=0) cout<<pf[lA][COL_LEFT]<<" "<<pf[lA][COL_RIGHT]<<" Row "<<lA<<",   "<<endl;
			if(lB>=0) cout<<pf[lB][COL_LEFT]<<" "<<pf[lB][COL_RIGHT]<<" Row "<<lB<<endl;

			break;
		}
		}
		break;
	}
	}
	return prog_success(ppf);
}

bool prog_readmessage(string filename, string& message)
{
	ifstream t(filename.c_str());
	if(t.is_open())//.good()?
	{

		message="";

		t.seekg(0, ios::end);   
		message.reserve(t.tellg());
		t.seekg(0, ios::beg);

		message.assign((istreambuf_iterator<char>(t)),
					istreambuf_iterator<char>());

		t.close();
		return true;
	}else{
		cerr<<"ERROR: could not open messagefile "<<filename<<"!"<<endl;
	}


	return false;
}

int prog_exit(PFILE* ppf, int ret){
	if(ppf!=NULL) delete ppf;
	return ret;
}


PFILE* prog_load(string filename)
{
	//cout<<"Allocating structure..."<<endl;
	PFILE* ppf=new PFILE;//too big for stack memory it seems.
	PFILE& pf=*ppf;
	//cout<<"Reading keyfile into memory..."<<endl;
	if(!pload(ppf, filename)){
		delete ppf;
		cerr<<"ERROR: could not open keyfile "<<filename<<"!"<<endl;
		return NULL;
	}
	//cout<<"Preparing structures for processing..."<<endl;
	for(int l=0;l<OTP_LINES;l++) for(int w=0;w<2;w++) pf.get(l,w).sep=0;
	return ppf;
}

bool prog_check(){
	if( sizeof(PFILE) != OTP_SIZES )
	{
		cerr<<"ERROR: Compilation Incorrect - "<<endl
			<<"  - PFILE must be packed to exact size of contents  "<<endl
			<<"Expected: "<<OTP_SIZES<<endl
			<<"Actual  : "<<sizeof(PFILE)<<endl;
		return false;
	}
	return true;
}


void prog_pause(){cout<<endl<<"Press ENTER to continue..."<<endl;getchar();}


bool pload(PFILE* pf, string filename)
{
	FILE* pFile=fopen(filename.c_str(), "r");
	if(pFile!=NULL)
	{
		fread((void*) pf, OTP_SIZES, 1, pFile);
		fclose(pFile);
		return true;
	}
	return false;
}


int pfind(const PFILE& pf, PFILE_COLUMN col, const char* str)
{
	//cout<<"FIND:"<<str<<endl;
	for(int l=0;l<OTP_LINES;l++) if(strcmp(str, pf[l][col])==0) return l;
	return -1;
}

const char* pwordrepl(const PFILE& pf, PFILE_DIRECTION dir, const char* str)
{
	PFILE_COLUMN col1=(PFILE_COLUMN) dir;// COL_LEFT==DIR_LTR, COL_RIGHT==DIR_RTL  we look for the matching column in either case.
	PFILE_COLUMN col2=(PFILE_COLUMN)( (col1+1) % 2);
	int l=pfind(pf, col1, str);
	if(l<0) return NULL;
	return pf[l][col2];//supplies const char* via operator above
}

string preplace(const PFILE& pf, PFILE_DIRECTION dir, const string str)
{
	stringstream ss(str);
	string sw;
	string out="";
	while(ss>>sw){
		const char* cs=pwordrepl(pf,dir,sw.c_str());
		if(cs==NULL) out+="ERR["+sw+"]";
		else out+=cs;
		out+=" ";
	}
	return out;
}


