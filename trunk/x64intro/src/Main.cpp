#include<iostream>
#include<conio.h>

using namespace std;

//expressao = (a+b+c+d+e)/(f+1.5)

/* o extern "C" é usado para "avisar" que sera usado um arquivo externo e evitar a name mangling ou decoração de nomes*/

extern "C"  double CombineA(int a,int b,int c,int d,int e,double f);


int main()
{
	
	cout<<"CombineA: "<<CombineA(1,2,3,4,5,6.1)<<endl;
	system("pause");
	
	return 0;

}