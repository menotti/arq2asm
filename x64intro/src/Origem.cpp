#include<iostream>
#include<conio.h>

using namespace std;
int i;
extern "C" int val1;

extern "C"  int testeAsm();
int main()
{
	for (i=0;i<11;i++)
	{
		
		cout<<" "<<testeAsm()<<endl;
	}
	system("pause");
	
	return 0;

}