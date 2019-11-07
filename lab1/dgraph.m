ber = [0.1,0.0667,0.0280,0.0087,0.0027];
coderate = [1,4/7,1/3,1/5,1/7];
labels = ["No coding","Hamming code","R3","R5","R7"];
rcolor = randi(6,1,length(ber));
hold all
for i = 1:length(ber)

    plot(coderate(i),ber(i),'s');
end

%plot(coderate,ber,'o');
title("BER vs Coding Rate");
xlabel("Coding Rate");
ylabel("BER");
legend(labels)
