A = randi([1,10],[10,10]);
C = (A >= 3) .* (A <= 8);
B = zeros([2,2]);
for row=1:2:size(A,1)
    for col=1:2:size(A,2)
        if C([row,row+1],[col,col+1])
            sumA = sum(A([row,row+1],[col,col+1]),'all');
            sumB = sum(B,'all');
            if sumB == 0
                B = A([row,row+1],[col,col+1]);
            elseif sumA < sumB
                B = A([row,row+1],[col,col+1]);
            end
        end
    end
end
