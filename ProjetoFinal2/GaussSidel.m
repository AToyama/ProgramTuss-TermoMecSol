%% JACOBI
function [ u, Erro ] = Jacobi(iterations, Tolerancia, Kg, f)

[ord, j]= size(Kg);% tamanho de i e j que são iguais
disloc = zeros(ord, j);%tamanho de disloc
u = zeros(ord,2);%tamanho de u
Erro=zeros(ord,1); %tamanho do Erro
for k= 1:iterations
    for i = 1:ord %i = linha (length(1,Kg))
        Kii=Kg(i,i);%pegando a diagonal
        soma = f(i)/Kii;%pegando o vetor de forças coluna i
        
        for j=1:ord %j =coluna (length(Kg,1))
            if i ~=j;%checa se i e j são diferentes pois na primeira iteração (1,1) e nao deve entrar
                disloc(i,j)=Kg(i,j)/Kii; %dividindo todos os elementos pelos elementos da diagonal
                soma = soma-(disloc(i,j)*u(j,1));%salvando o novo u em soma
            end
        end
        
        u(i,2)=soma;%salvando o novo u na 2 coluna de u
        uAnterior = u(i,1);%pega a primeira coluna de i
        u(i,1)=u(i,2); %Gauss Sidel (importante)
        Erro(i,1)=abs(u(i,2)-uAnterior);%abs = valor absoluto
%         f(i)=f(i)/Kii;
    end
    
    if max(Erro)<Tolerancia %checa o maior erro e compara com a tolerancia para ver se o erro é menor e quando for menor sai
        fprintf('%d',Erro);
        break
    end
    
%     u(i,2)=u(i,1); Para Jacobi
end

u = u(:,2);

end