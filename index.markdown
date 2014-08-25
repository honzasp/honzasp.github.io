---
layout: page
class: home
---

## Hello, world!

{: .bf }
    #include <stdio.h>
    #include <stdlib.h>
    int main(int z,char**v){int x,y,i,d,m,j,
    r;char a,p[80][25],t[10000],*s=t;m=j=x=
    y=*(s++)=0;d=r=1;FILE*f=fopen(v[1],"r")
    ;for(;;){i=fgetc(f);if(i==EOF)break;(i
    =='\n')?(x=0,++y):(p[x++][y]=i);}x=y=0;
    while(r){if(m){if((*(s++)=p[x][y])=='"')
    --s,m=0;}else if(j){j=0;}else{switch(a=p
    [x][y]){case'+':s[-2]+=s[-1];--s;break;
    case'-':s[-2]-=s[-1];--s;break;case'*':
    s[-2]*=s[-1];--s;break;case'/':s[-2]/=s
    [-1];--s;break;case'%':s[-2]%=s[-1];--s;
    break;case'!':s[-1]=s[-1]?0:1;break;case
    '`':s[-2]=s[-2]>s[-1]?1:0;--s;break;case
    '>':d=1;break;case'<':d=3;break;case'^':
    d=0;break;case'v':d=2;break;case'?':d=
    rand()%4;break;case'_':d=*(--s)?3:1;
    break;case'|':d=*(--s)?0:2;break;case
    '"':m=1;break;case':':*s=s[-1];++s;
    break;case'\\':a=s[-1];s[-1]=s[-2];s[-2
    ]=a;break;case'$':--s;break;case'.':
    printf("%d",(int)*(--s));break;case',':
    printf("%c",*(--s));break;case'#':j=1;
    break;case'g':s[-2]=p[s[-2]][s[-1]];--s
    ;break;case'p':p[s[-2]][s[-1]]=s[-3];s
    -=3;break;case'&':scanf("%d",&i);*(s++)
    =(char)i;break;case'~':scanf("%c",s++);
    break;case'@':r=0;case' ':break;default
    :if(a>='0'&&a<='9')*(s++)=a-'0';break;}
    }switch(d){case 0:--y;break;case 2:++y;
    break;case 3:--x;break;case 1:++x;break
    ;}x=x%80;y=y%25;}return 0;}
