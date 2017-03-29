function  [ uatualiza , Erro ] = Untitled( iteration, Tolerancia,Kg, f )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
uatual=zeros(length(Kg));
uatualiza=zeros(length(Kg));


    for k=1:iteration
        for i=1:length(Kg)
            for j=1:length(Kg)
                if j == i
                else
                    uatualiza(i)=(uatualiza(i)+Kg(i,j)*uatual(j)+f(i));
                end 
            
            
            end
            uatualiza(i)=(uatualiza(i))/Kg(i,i);
            
            Erro = uatualiza(i)-uatual(i);
            
            fprintf(Erro);
            
            
        end
    end

end

