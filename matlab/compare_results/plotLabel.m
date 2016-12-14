function plotLabel(FontSize);

%xlabel('Average Delivery Delay [channel use]','Interpreter', 'Latex','fontsize',FontSize); 
%ylabel('Average SNR [dB]','Interpreter', 'Latex','fontsize',FontSize); 
xlabel('Average Delivery Delay [channel use]','fontsize',FontSize); 
ylabel('Average SNR [dB]','fontsize',FontSize); 
%ylabel('Average $20\log \frac{{||\underline{x}||}_{\ell_2}}{{||\underline{x}-\underline{\hat{x}}||}_{\ell_2}}$ [dB]','Interpreter', 'Latex','fontsize',FontSize); 
%ylabel('Average $20\log {||\underline{x}||}_{\ell_2}/{||\underline{x}-\underline{\hat{x}}||}_{\ell_2}$ [dB]','Interpreter', 'Latex','fontsize',FontSize); 