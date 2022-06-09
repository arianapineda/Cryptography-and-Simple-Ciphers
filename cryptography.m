% Ariana Pineda, CAAM 210, SPRING 2022, Text Decryption
% cryptography.m
% this script decodes encrypted text
% Last modified: April 29, 2022

function cryptography()
%this driver decodes the encoded text using the decoder method

text1=fileread('encodedtext1.txt');
text1=strip(text1);
disp('Message 1: ');
disp(decoder(text1, 10^5))

text2=fileread('encodedtext2.txt');
text2=strip(text2);

disp('Message 2: ');
disp(decoder(text2, 10^4))

end

function [NumText] = downlow(Text)
%converts text into ASCII
%inputs: Text-string
%outputs: NumText-ASCII conversion of string
[NumText]=double(Text)-95;
end

function [Text]= downlowinv(NumText)
%converts ASCII into a string of letters
%inputs: NumText-ASCII representation of a string
%outputs: Text-string conversion of ASCII

Text=char(NumText+95);

%substitute ' with a space
for i = 1:length(Text)
    if Text(i) == "`"
        Text(i) = " ";
    end
end
end

function [value] = loglike(text,guess,letterprob)
%computes the value of loglike function for a given transition probability
%matrix and key guess
%inputs: text-encoded text, guess-key, letterprob-transition probability matrix
%outputs: value-computed value of loglike function for letterprob

%initialize variables
M=letterprob;
S=zeros(1,length(text)-1);
text=downlow(text);

%compute loglike function for letterprob
for i = 1:length(text)-1
    val = M(guess(text(i)),guess(text(i+1)));
    S(i) = log(val);
end
value=sum(S);
end


function [message] = decoder(text,maxiter)
%decodes the given text using the Metropolis Algorithm
%Inputs: text-encoded text, maxiter-number of iterations
%Outputs: message-decoded text

%load lettter prob matrix
data = load("LetterProb.mat");
M=data.letterprob;

T = downlow(text);

%generate rand key
y = randperm(27);
%randomly modify rand key in maxiter iterations
for i = 1:maxiter
    R = randi([1,27],1,2);

    ymaybe = y;

    %swap ymaybe values
    [ymaybe(R(2)), ymaybe(R(1))] = deal(ymaybe(R(1)),ymaybe(R(2)));

    %compute the loglike values of both keys
    loglikey=loglike(text,y,M);
    loglikeymaybe=loglike(text,ymaybe,M);

    %compare the loglike values of both keys, then reset y key
    if loglikey>loglikeymaybe
        r = rand();
        if r < exp(loglike(text,ymaybe,M)-loglike(text,y,M))
            y = ymaybe;
        else
            y = y;
        end
    else if loglikeymaybe > loglikey
            y = ymaybe;
    end
    end

end
%decode text
for k = 1:length(T)
    decodedtext(k)=y(T(k));
end
message = downlowinv(decodedtext);
end
