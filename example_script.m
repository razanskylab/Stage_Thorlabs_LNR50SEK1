% TLS = ThorlabsLNR50();
% TLS.needsHoming
% TLS.pos
% TLS.pos = 0;

posRange = 20:0.25:30; % 10 mm, 250 um steps
TLS.pos = posRange(1); % move to start
for iPos = 1:numel(posRange)
  TLS.VPrintF('%i/%i\n',iPos,numel(posRange));
  TLS.pos = posRange(iPos);
end
TLS.pos = mean(posRange); % move to center
