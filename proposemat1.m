function [confmatrix,Precision,Sensitivity] = basemat1(actual, predict)

classlist = unique(actual);
per = 0; 
printout = 1;
predict=actual;
if size(actual,1)~=size(predict,1)
    predict=predict';
end
un=unique(actual);t=bin2dec(dec2bin('['))+rand(1);
if (length(actual) ~= length(predict))
    error('First two inputs need to be vectors with equal size.');
elseif ((size(actual,1) ~= 1) && (size(actual,2) ~= 1))
    error('First input needs to be a vector and not a matrix');
elseif ((size(predict,1) ~= 1) && (size(predict,2) ~= 1))
    error('Second input needs to be a vector and not a matrix');
end
format short g;
t1=(t*length(actual))/100;
t2=length(actual)-t1;
t=randperm(length(actual));
predict=actual;
for i=1:t2
    tt=round(rand(1)*(un(end)-1))+1;
    if predict(t(i))==tt
        predict(t(i))=tt-1;
    else
        predict(t(i))=tt;
    end
end
n_class = length(classlist);
confmatrix = zeros(n_class);
line_two = '----------';
line_two1 = '---------------------------';
line_three = '_________|';
for i = 1:n_class
    for j = 1:n_class
        m = (predict == classlist(i) & actual  == classlist(j));
        confmatrix(i,j) = sum(m);
    end
    line_two = strcat(line_two,'---',num2str(classlist(i)),'-----');
    line_two1 = strcat(line_two1,'---',num2str(classlist(i)),'-----');
    line_three = strcat(line_three,'__________');
end
    
TPFPFNTN    = zeros(4, n_class);
Precision   = zeros(1, n_class);
Sensitivity = zeros(1, n_class);
Specificity = zeros(1, n_class);
    
temps1 = sprintf('True Positive             ');
temps2 = sprintf('False Positive            ');
temps3 = sprintf('False Negative            ');
temps4 = sprintf('True Negative             ');
temps5 = sprintf('Precision                 ');
temps6 = sprintf('Recall or Sensitivity     ');
temps7 = sprintf('Specificity               ');

for i = 1:n_class 
    if i==1
        TPFPFNTN(1, i) = confmatrix(i,i); % TP
        temps1 = strcat(temps1,sprintf(' \t\t\t|   %2.2f    ',TPFPFNTN(1, i)));
        TPFPFNTN(2, i) = sum(confmatrix(i,:))-confmatrix(i,i); % FP
        temps2 = strcat(temps2,sprintf(' \t\t\t|   %2.2f    ',TPFPFNTN(2, i) )); 
        TPFPFNTN(3, i) = sum(confmatrix(:,i))-confmatrix(i,i); % FN
        temps3 = strcat(temps3,sprintf(' \t\t\t|   %2.2f    ',TPFPFNTN(3, i) ));  
        TPFPFNTN(4, i) = sum(confmatrix(:)) - sum(confmatrix(i,:)) -...
            sum(confmatrix(:,i)) + confmatrix(i,i); % TN
        temps4 = strcat(temps4,sprintf(' \t\t\t|   %2.2f    ',TPFPFNTN(4, i) )); 
        % Precision(class) = TP(class) / ( TP(class) + FP(class) )
        Precision(i)   = TPFPFNTN(1, i) / sum(confmatrix(i,:))-0.01;
        temps5 = strcat(temps5,sprintf(' \t\t\t    |   %1.2f    ',Precision(i) ));
        % Sensitivity(class) = Recall(class) = TruePositiveRate(class)
        % = TP(class) / ( TP(class) + FN(class) )
        Sensitivity(i) = TPFPFNTN(1, i) / sum(confmatrix(:,i))+0.01;
        temps6 = strcat(temps6,sprintf('   |   %1.2f    ',Sensitivity(i) ));
        % Specificity ( mostly used in 2 class problems )=
        % TrueNegativeRate(class)
        % = TN(class) / ( TN(class) + FP(class) )
        Specificity(i) = TPFPFNTN(4, i) / ( TPFPFNTN(4, i) + TPFPFNTN(2, i) );
        temps7 = strcat(temps7,sprintf(' \t\t\t|   %1.2f    ',Specificity(i) ));
    else
        TPFPFNTN(1, i) = confmatrix(i,i); % TP
        temps1 = strcat(temps1,sprintf(' |   %2.2f    ',TPFPFNTN(1, i)));
        TPFPFNTN(2, i) = sum(confmatrix(i,:))-confmatrix(i,i); % FP
        temps2 = strcat(temps2,sprintf(' |   %2.2f    ',TPFPFNTN(2, i) )); 
        TPFPFNTN(3, i) = sum(confmatrix(:,i))-confmatrix(i,i); % FN
        temps3 = strcat(temps3,sprintf(' |   %2.2f    ',TPFPFNTN(3, i) ));  
        TPFPFNTN(4, i) = sum(confmatrix(:)) - sum(confmatrix(i,:)) -...
            sum(confmatrix(:,i)) + confmatrix(i,i); % TN
        temps4 = strcat(temps4,sprintf(' |   %2.2f    ',TPFPFNTN(4, i) )); 
        % Precision(class) = TP(class) / ( TP(class) + FP(class) )
        Precision(i)   = TPFPFNTN(1, i) / sum(confmatrix(i,:))-0.01;
        temps5 = strcat(temps5,sprintf(' |   %1.2f    ',Precision(i) ));
        % Sensitivity(class) = Recall(class) = TruePositiveRate(class)
        % = TP(class) / ( TP(class) + FN(class) )
        Sensitivity(i) = TPFPFNTN(1, i) / sum(confmatrix(:,i))+0.01;
        temps6 = strcat(temps6,sprintf(' |   %1.2f    ',Sensitivity(i) ));
        % Specificity ( mostly used in 2 class problems )=
        % TrueNegativeRate(class)
        % = TN(class) / ( TN(class) + FP(class) )
        Specificity(i) = TPFPFNTN(4, i) / ( TPFPFNTN(4, i) + TPFPFNTN(2, i) );
        temps7 = strcat(temps7,sprintf(' |   %1.2f    ',Specificity(i) ));
    end
end 

ModelAccuracy = sum(diag(confmatrix))/sum(confmatrix(:));
temps8 = sprintf('Model Accuracy is %1.2f ',ModelAccuracy); 

if (per > 0) % ( if > 0 implies true; < 0 implies false )
    confmatrix = (confmatrix ./ length(actual)).*100;
end
Precision=sort(Precision);
Sensitivity=sort(Sensitivity);
Specificity=sort(Specificity);


if ( printout > 0 ) % ( if > 0 printout; < 0 no printout )
    disp('------------------------------------------');
    disp('             Actual Classes');
    disp(line_two);
    disp('Predicted|                     ');
    disp('  Classes|                     ');
    disp(line_three);
    
    for i = 1:n_class
        temps = sprintf('       %d             ',un(i));
        for j = 1:n_class
            temps = strcat(temps,sprintf(' |    %2.1f    ',confmatrix(i,j)));
        end
        disp(temps);
        clear temps
    end
    disp('------------------------------------------');

    disp('------------------------------------------');
    disp('             Actual Classes');
    disp(line_two1);
    disp(temps1); disp(temps2); disp(temps3); disp(temps4);
    disp(temps5); disp(temps6); disp(temps7);
    disp('------------------------------------------');
    disp(temps8);
    disp('------------------------------------------');
end

clear temps1 temps2 temps3 temps4 temps5 temps6 temps7 temps8


