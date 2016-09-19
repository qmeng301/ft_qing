function [trl, event] = mytrialfun_MEG(cfg)
 
% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset,'trigindx',049,'threshold',2,'detectflank','up');
 
% search for "trigger" events according to 'trigchannel' defined outside the function
value  = [event(find(strcmp(cfg.trialdef.trigchannel, {event.type}))).value]';
sample = [event(find(strcmp(cfg.trialdef.trigchannel, {event.type}))).sample]';

trl = []; 
% creating your own trialdefinition based upon the events
for j = 1:length(value);
    trlbegin = sample(j) - cfg.trialdef.prestim * hdr.Fs;
    trlend   = sample(j) + cfg.trialdef.poststim * hdr.Fs;
    offset   = - cfg.trialdef.prestim * hdr.Fs;
    newtrl   = [ trlbegin trlend offset];
    trl      = [ trl; newtrl];  
end

