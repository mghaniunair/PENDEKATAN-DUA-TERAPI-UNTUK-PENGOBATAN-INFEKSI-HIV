function [t,f]=simulation_HIV(lamda,beta,d,p,a,l,s,b,Tm,T,X0,Y0,Z0,A,A1,A2)
N=1000;
t=linspace(0,T,N+1);
h=T/N;
h2=h/2;
%State Without Control
X=zeros(1,N+1);
Y=zeros(1,N+1);
Z=zeros(1,N+1);
X(1)=X0;
Y(1)=Y0;
Z(1)=Z0;

%State With Control (HAART) 
stateX=zeros(1,N+1);
stateY=zeros(1,N+1);
stateZ=zeros(1,N+1);
stateX(1)=X0;
stateY(1)=Y0;
stateZ(1)=Z0;

%Co-State (HAART)
co_stateX=zeros(1,N+1);
co_stateY=zeros(1,N+1);
co_stateZ=zeros(1,N+1);

%Control HAART
u=zeros(1,N+1);

%State With Control (HAART+Immunotherapy IL-2) 
X2=zeros(1,N+1);
Y2=zeros(1,N+1);
Z2=zeros(1,N+1);
X2(1)=X0;
Y2(1)=Y0;
Z2(1)=Z0;

%Co-State (HAART+Immunotherapy IL-2)
PX2=zeros(1,N+1);
PY2=zeros(1,N+1);
PZ2=zeros(1,N+1);

%Control HAART+Immunotherapy IL-2
ucomb1=zeros(1,N+1);
ucomb2=zeros(1,N+1);
iteration=0;
for i=1:N
    iteration=iteration+1;
    oldu=u;
    olducomb1=ucomb1;
    olducomb2=ucomb2;
    %fprintf('iterasi ke= %i\n',iteration);
    
    %Part1 State With Control HAART
    for i=1:N
        value_stateX=lamda+p*stateX(i)*(1-stateX(i)/Tm)-d*stateX(i)-(1-u(i))...
            *beta*stateX(i)*stateY(i);
        value_stateY=(1-u(i))*beta*stateX(i)*stateY(i)-a*stateY(i)-l*stateY(i)...
            *stateZ(i);
        value_stateZ=s*stateY(i)-b*stateZ(i);
        %------------------------------------------------------------------
        value_state2X=lamda+p*(stateX(i)+h2*value_stateX)...
            *(1-(stateX(i)+h2*value_stateX)/Tm)-d*(stateX(i)+h2*value_stateX)...
            -(1-0.5*(u(i)+u(i+1)))*beta*(stateX(i)+h2*value_stateX)...
            *(stateY(i)+h2*value_stateY);
        value_state2Y=(1-0.5*(u(i)+u(i+1)))*beta*(stateX(i)+h2*value_stateX)...
            *(stateY(i)+h2*value_stateY)-a*(stateY(i)+h2*value_stateY)...
            -l*(stateY(i)+h2*value_stateY)*(stateZ(i)+h2*value_stateZ);
        value_state2Z=s*(stateY(i)+h2*value_stateY)...
            -b*(stateZ(i)+h2*value_stateZ);
        %------------------------------------------------------------------
        value_state3X=lamda+p*(stateX(i)+h2*value_state2X)...
            *(1-(stateX(i)+h2*value_state2X)/Tm)-d*(stateX(i)+h2*value_state2X)...
            -(1-0.5*(u(i)+u(i+1)))*beta*(stateX(i)+h2*value_state2X)...
            *(stateY(i)+h2*value_state2Y);
        value_state3Y=(1-0.5*(u(i)+u(i+1)))*beta*(stateX(i)+h2*value_state2X)...
            *(stateY(i)+h2*value_state2Y)-a*(stateY(i)+h2*value_state2Y)...
            -l*(stateY(i)+h2*value_state2Y)*(stateZ(i)+h2*value_state2Z);
        value_state3Z=s*(stateY(i)+h2*value_state2Y)...
            -b*(stateZ(i)+h2*value_state2Z);
        %------------------------------------------------------------------
        value_state4X=lamda+p*(stateX(i)+h*value_state3X)...
            *(1-(stateX(i)+h*value_state3X)/Tm)-d*(stateX(i)+h*value_state3X)...
            -(1-u(i))*beta*(stateX(i)+h*value_state3X)...
            *(stateY(i)+h*value_state3Y);
        value_state4Y=(1-u(i))*beta*(stateX(i)+h*value_state3X)...
            *(stateY(i)+h*value_state3Y)-a*(stateY(i)+h*value_state3Y)...
            -l*(stateY(i)+h*value_state3Y)*(stateZ(i)+h*value_state3Z);
        value_state4Z=s*(stateY(i)+h*value_state3Y)...
            -b*(stateZ(i)+h*value_state3Z);
        %------------------------------------------------------------------
        stateX(i+1)=stateX(i)+(h/6)*(value_stateX+2*value_state2X...
            +2*value_state3X+value_state4X);
        stateY(i+1)=stateY(i)+(h/6)*(value_stateY+2*value_state2Y...
            +2*value_state3Y+value_state4Y);
        stateZ(i+1)=stateZ(i)+(h/6)*(value_stateZ+2*value_state2Z...
            +2*value_state3Z+value_state4Z);
    end;
    %End Of Part1
    
    %Part2 Co-State HAART
    for i=1:N
        j=N+2-i;
        value_stateX=-1+co_stateX(j)*((2*p*stateX(j)/Tm)+d-p)+...
            beta*stateY(j)*(1-u(j))*(co_stateX(j)-co_stateY(j));
        value_stateY= beta*stateY(j)*(1-u(j))*(co_stateX(j)-co_stateY(j))...
            +co_stateY(j)*(a+l*stateZ(j))-co_stateZ(j)*s;
        value_stateZ=-1+co_stateY(j)*l*stateY(j)+co_stateZ(j)*b;
        %------------------------------------------------------------------
        value_state2X=-1+(co_stateX(j)-h2*value_stateX)...
            *((2*p*0.5*(stateX(j)+stateX(j-1))/Tm)+d-p)...
            +beta*(stateY(j)+stateY(j-1))*(1-0.5*(u(j)+u(j-1)))...
            *((co_stateX(j)-h2*value_stateX)-(co_stateY(j)-h2*value_stateY));
        value_state2Y= beta*0.5*(stateY(j)+stateY(j-1))*(1-0.5*(u(j)+u(j-1)))...
            *((co_stateX(j)-h2*value_stateX)-(co_stateY(j)-h2*value_stateY))...
            +(co_stateY(j)-h2*value_stateY)*(a+l*0.5*(stateZ(j)+stateZ(j-1)))...
            -(co_stateZ(j)-h2*value_stateZ)*s;
        value_state2Z=-1+(co_stateY(j)-h2*value_stateY)...
            *l*0.5*(stateY(j)+stateY(j-1))+(co_stateZ(j)-h2*value_stateZ)*b;
        %------------------------------------------------------------------
        value_state3X=-1+(co_stateX(j)-h2*value_state2X)...
            *((2*p*0.5*(stateX(j)+stateX(j-1))/Tm)+d-p)...
            +beta*0.5*(stateY(j)+stateY(j-1))*(1-0.5*(u(j)+u(j-1)))...
            *((co_stateX(j)-h2*value_state2X)...
            -(co_stateY(j)-h2*value_state2Y));
        value_state3Y= beta*0.5*(stateY(j)+stateY(j-1))*(1-0.5*(u(j)+u(j-1)))...
            *((co_stateX(j)-h2*value_state2X)-(co_stateY(j)-h2*value_state2Y))...
            +(co_stateY(j)-h2*value_state2Y)...
            *(a+l*0.5*(stateZ(j)+stateZ(j-1)))...
            -(co_stateZ(j)-h2*value_state2Z)*s;
        value_state3Z=-1+(co_stateY(j)-h2*value_state2Y)...
            *l*0.5*(stateY(j)+stateY(j-1))+(co_stateZ(j)-h2*value_state2Z)*b;
        %------------------------------------------------------------------
        value_state4X=-1+(co_stateX(j)-h*value_state3X)...
            *((2*p*(stateX(j-1))/Tm)+d-p)...
            +beta*(stateY(j-1))*(1-u(j))...
            *((co_stateX(j)-h*value_state3X)-(co_stateY(j)-h*value_state3Y));
        value_state4Y= beta*(stateY(j-1))*(1-u(j))...
            *((co_stateX(j)-h*value_state3X)-(co_stateY(j)-h*value_state3Y))...
            +(co_stateY(j)-h*value_state3Y)...
            *(a+l*(stateZ(j-1)))...
            -(co_stateZ(j)-h*value_state3Z)*s;
        value_state4Z=-1+(co_stateY(j)-h*value_state3Y)...
            *l*(stateY(j-1))...
            +(co_stateZ(j)-h*value_state3Z)*b;
        %------------------------------------------------------------------
        co_stateX(j-1)=co_stateX(j)-(h/6)*(value_stateX+2*value_state2X...
            +2*value_state3X+value_state4X);
        co_stateY(j-1)=co_stateY(j)-(h/6)*(value_stateY+2*value_state2Y...
            +2*value_state3Y+value_state4Y);
        co_stateZ(j-1)=co_stateZ(j)-(h/6)*(value_stateZ+2*value_state2Z...
            +2*value_state3Z+value_state4Z);
        %------------------------------------------------------------------
        u(j)=min(1,max(0,(beta*stateX(j)*stateY(j)...
            *(co_stateX(j)-co_stateY(j)))/A));
    end;
    %End Of Part2
    
    %Part3 State Without Control
    for i=1:N
        valueX=lamda+p*X(i)*(1-X(i)/Tm)-d*X(i)-beta*X(i)*Y(i);
        valueY=beta*X(i)*Y(i)-a*Y(i)-l*Y(i)*Z(i);
        valueZ=s*Y(i)-b*Z(i);
        %------------------------------------------------------------------
        value2X=lamda+p*(X(i)+h2*valueX)*(1-(X(i)+h2*valueX)/Tm)...
            -d*(X(i)+h2*valueX)-beta*(X(i)+h2*valueX)*(Y(i)+h2*valueY);
        value2Y=beta*(X(i)+h2*valueX)*(Y(i)+h2*valueY)...
            -a*(Y(i)+h2*valueY)-l*(Y(i)+h2*valueY)*(Z(i)+h2*valueZ);
        value2Z=s*(Y(i)+h2*valueY)-b*(Z(i)+h2*valueZ);
        %------------------------------------------------------------------
        value3X=lamda+p*(X(i)+h2*value2X)*(1-(X(i)+h2*value2X)/Tm)...
            -d*(X(i)+h2*value2X)-beta*(X(i)+h2*value2X)*(Y(i)+h2*value2Y);
        value3Y=beta*(X(i)+h2*value2X)*(Y(i)+h2*value2Y)...
            -a*(Y(i)+h2*value2Y)-l*(Y(i)+h2*value2Y)*(Z(i)+h2*value2Z);
        value3Z=s*(Y(i)+h2*value2Y)-b*(Z(i)+h2*value2Z);
        %------------------------------------------------------------------
        value4X=lamda+p*(X(i)+h*value3X)*(1-(X(i)+h*value3X)/Tm)...
            -d*(X(i)+h*value3X)-beta*(X(i)+h*value3X)*(Y(i)+h*value3Y);
        value4Y=beta*(X(i)+h*value3X)*(Y(i)+h*value3Y)...
            -a*(Y(i)+h*value3Y)-l*(Y(i)+h*value3Y)*(Z(i)+h*value3Z);
        value4Z=s*(Y(i)+h*value3Y)-b*(Z(i)+h*value3Z);
        %------------------------------------------------------------------
        X(i+1)=X(i)+(h/6)*(valueX+2*value2X+2*value3X+value4X);
        Y(i+1)=Y(i)+(h/6)*(valueY+2*value2Y+2*value3Y+value4Y);
        Z(i+1)=Z(i)+(h/6)*(valueZ+2*value2Z+2*value3Z+value4Z);
    end;
    %End of Part3
    
    %Part4 State With Control HAART+Immunotherapy IL-2
    for i=1:N
        combX=lamda+p*X2(i)*(1-X2(i)/Tm)-d*X2(i)-(1-ucomb1(i))...
            *beta*X2(i)*Y2(i)+ucomb2(i)*X2(i);
        combY=(1-ucomb1(i))*beta*X2(i)*Y2(i)-a*Y2(i)-l*Y2(i)...
            *Z2(i);
        combZ=s*Y2(i)-b*Z2(i);
        %------------------------------------------------------------------
        comb2X=lamda+p*(X2(i)+h2*combX)...
            *(1-(X2(i)+h2*combX)/Tm)-d*(X2(i)+h2*combX)-0.5*(2-ucomb1(i)...
            -ucomb1(i+1))*beta*(X2(i)+h2*combX)*(Y2(i)+h2*combY)...
            +ucomb2(i)*(X2(i)+h2*combX);
        comb2Y=0.5*(2-ucomb1(i)-ucomb1(i+1))*beta*(X2(i)+h2*combX)...
            *(Y2(i)+h2*combY)-a*(Y2(i)+h2*combY)...
            -l*(Y2(i)+h2*combY)*(Z2(i)+h2*combZ);
        comb2Z=s*(Y2(i)+h2*combY)-b*(Z2(i)+h2*combZ);
        %------------------------------------------------------------------
        comb3X=lamda+p*(X2(i)+h2*comb2X)...
            *(1-(X2(i)+h2*comb2X)/Tm)-d*(X2(i)+h2*comb2X)-0.5*(2-ucomb1(i)...
            -ucomb1(i+1))*beta*(X2(i)+h2*comb2X)*(Y2(i)+h2*comb2Y)...
            +ucomb2(i)*(X2(i)+h2*comb2X);
        comb3Y=0.5*(2-ucomb1(i)-ucomb1(i+1))*beta*(X2(i)+h2*comb2X)...
            *(Y2(i)+h2*comb2Y)-a*(Y2(i)+h2*comb2Y)...
            -l*(Y2(i)+h2*comb2Y)*(Z2(i)+h2*comb2Z);
        comb3Z=s*(Y2(i)+h2*comb2Y)-b*(Z2(i)+h2*comb2Z);
        %------------------------------------------------------------------
        comb4X=lamda+p*(X2(i)+h*comb3X)...
            *(1-(X2(i)+h*comb3X)/Tm)-d*(X2(i)+h*comb3X)-0.5*(2-ucomb1(i)...
            -ucomb1(i+1))*beta*(X2(i)+h*comb3X)*(Y2(i)+h*comb3Y)...
            +ucomb2(i)*(X2(i)+h*comb3X);
        comb4Y=0.5*(2-ucomb1(i)-ucomb1(i+1))*beta*(X2(i)+h*comb3X)...
            *(Y2(i)+h*comb3Y)-a*(Y2(i)+h*comb3Y)...
            -l*(Y2(i)+h*comb3Y)*(Z2(i)+h*comb3Z);
        comb4Z=s*(Y2(i)+h*comb3Y)-b*(Z2(i)+h*comb3Z);
        %------------------------------------------------------------------
        X2(i+1)=X2(i)+(h/6)*(combX+2*comb2X+2*comb3X+comb4X);
        Y2(i+1)=Y2(i)+(h/6)*(combY+2*comb2Y+2*comb3Y+comb4Y);
        Z2(i+1)=Z2(i)+(h/6)*(combZ+2*comb2Z+2*comb3Z+comb4Z);
    end;
    %End Of Part4
    
    %Part5 Co-State HAART+Immunotherapy Using IL-2
    for i=1:N
       j=N+2-i;
        combX=-1+PX2(j)*((2*p*X2(j)/Tm)+d-p-ucomb2(j))+...
            beta*Y2(j)*(1-ucomb1(j))*(PX2(j)-PY2(j));
        combY= beta*Y2(j)*(1-ucomb1(j))*(PX2(j)-PY2(j))...
            +PY2(j)*(a+l*Z2(j))-PZ2(j)*s;
        value_stateZ=-1+PY2(j)*l*Y2(j)+PZ2(j)*b;
        %------------------------------------------------------------------
        comb2X=-1+(PX2(j)-h2*combX)*((2*p*0.5*(stateX(j)...
            +X2(j-1))/Tm)+d-p-0.5*(2-ucomb2(j)-ucomb2(j-1)))...
            +beta*(Y2(j)+Y2(j-1))*0.5*(2-ucomb1(j)-ucomb1(j-1))...
            *((PX2(j)-h2*combX)-(PY2(j)-h2*combY));
        comb2Y= beta*0.5*(Y2(j)+Y2(j-1))*0.5*(2-ucomb1(j)-ucomb1(j-1))...
            *((PX2(j)-h2*combX)-(PY2(j)-h2*combY))...
            +(PY2(j)-h2*combY)*(a+l*0.5*(Z2(j)+Z2(j-1)))-(PZ2(j)-h2*combZ)*s;
        comb2Z=-1+(PY2(j)-h2*combY)*l*0.5*(Y2(j)+Y2(j-1))...
            +(PZ2(j)-h2*combZ)*b;
        %------------------------------------------------------------------
        comb3X=-1+(PX2(j)-h2*comb2X)*((2*p*0.5*(stateX(j)...
            +X2(j-1))/Tm)+d-p-0.5*(2-ucomb2(j)-ucomb2(j-1)))...
            +beta*(Y2(j)+Y2(j-1))*0.5*(2-ucomb1(j)-ucomb1(j-1))...
            *((PX2(j)-h2*comb2X)-(PY2(j)-h2*comb2Y));
        comb3Y= beta*0.5*(Y2(j)+Y2(j-1))*0.5*(2-ucomb1(j)-ucomb1(j-1))...
            *((PX2(j)-h2*comb2X)-(PY2(j)-h2*comb2Y))...
            +(PY2(j)-h2*comb2Y)*(a+l*0.5*(Z2(j)+Z2(j-1)))-(PZ2(j)-h2*comb2Z)*s;
        comb3Z=-1+(PY2(j)-h2*comb2Y)*l*0.5*(Y2(j)+Y2(j-1))...
            +(PZ2(j)-h2*comb2Z)*b;
        %------------------------------------------------------------------
        comb4X=-1+(PX2(j)-h*comb3X)*((2*p*0.5*(stateX(j)...
            +X2(j-1))/Tm)+d-p-0.5*(2-ucomb2(j)-ucomb2(j-1)))...
            +beta*(Y2(j)+Y2(j-1))*0.5*(2-ucomb1(j)-ucomb1(j-1))...
            *((PX2(j)-h*comb3X)-(PY2(j)-h*comb3Y));
        comb4Y= beta*0.5*(Y2(j)+Y2(j-1))*0.5*(2-ucomb1(j)-ucomb1(j-1))...
            *((PX2(j)-h*comb3X)-(PY2(j)-h*comb3Y))...
            +(PY2(j)-h*comb3Y)*(a+l*0.5*(Z2(j)+Z2(j-1)))-(PZ2(j)-h*comb3Z)*s;
        comb4Z=-1+(PY2(j)-h*comb3Y)*l*0.5*(Y2(j)+Y2(j-1))...
            +(PZ2(j)-h*comb3Z)*b;
        %------------------------------------------------------------------
        PX2(j-1)=PX2(j)-(h/6)*(combX+2*comb2X+2*comb3X+comb4X);
        PY2(j-1)=PY2(j)-(h/6)*(combY+2*comb2Y+2*comb3Y+comb4Y);
        PZ2(j-1)=PZ2(j)-(h/6)*(combZ+2*comb2Z+2*comb3Z+comb4Z);
        %------------------------------------------------------------------
        ucomb1(j)=min(1,max(0,(beta*X2(j)*Y2(j)...
            *(PX2(j)-PY2(j)))/A1)); 
        ucomb2(j)=min(0.003,max(0.0001,X2(j)*PX2(j)/A2));
    end;
    %End Of Part5
    
    temp=(beta*stateX.*stateY.*(co_stateX-co_stateY))/A;
    u1=min(1,max(0,temp));
    u=0.5*(u1+oldu);
    
    tempcomb1=(beta*X2.*Y2.*(PX2-PY2))/A1;
    u2=min(1,max(0,tempcomb1));
    ucomb1=0.5*(u2+olducomb1);
    
    tempcomb2=(X2.*PX2)/A2;
    u3=min(0.003,max(0.0001,tempcomb2));
    ucomb2=0.5*(u3+olducomb2);
end;
f(1,:)=X;
f(2,:)=Y;
f(3,:)=Z;
f(4,:)=stateX;
f(5,:)=stateY;
f(6,:)=stateZ;
f(7,:)=u;
f(8,:)=X2;
f(9,:)=Y2;
f(10,:)=Z2;
f(11,:)=ucomb1;
f(12,:)=ucomb2;
        