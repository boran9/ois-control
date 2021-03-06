clear;clc;close all;
filename = mfilename('fullpath');
[pathstr,name,ext] = fileparts(filename);
addpath([pathstr '\frequency-response-data'],[pathstr '\experimental-results'] );

Type = 1; % 1 for controller frequency response; 2 for tracking performance data 

if Type == 1    
    for nomeaning = 1        
        load classical_forFRcomparison
        load mu_forFRcomparison
        load controller_mpdr % MLPV_2by2subs_3paras
        load Filters
        figure;        
        W = logspace(0,4,10000); W=W';
        [Mag,Phase]= bode(sysKll,W*2*pi);
        semilogx(W,20*log10(Mag(:)),'k-.','Linewidth',1); 
        hold on;

%         h = bodeplot(sysKmuR*BSfilter,{1*2*pi, 1e5*2*pi},'g--'); %,'--'
%         setoptions(h,'FreqUnits','Hz','PhaseVisible','off');
        [Mag,Phase]= bode(sysKmuR*BSfilter,W*2*pi);
        semilogx(W,20*log10(Mag(:)),'g--','Linewidth',1); 
        
%         h = bodeplot(Kpdr{3}*BSfilter,{1*2*pi, 1e5*2*pi},'r');%
%         setoptions(h,'FreqUnits','Hz','PhaseVisible','off');
        [Mag,Phase]= bode(Kpdr{3}*BSfilter,W*2*pi);
        semilogx(W,20*log10(Mag(:)),'r','Linewidth',1); 

        clear Kpdr
        load controller_mpdr_Ignore_w2n_Uncert % MLPV_2by2subs_3paras_Igw2nUncert
%         h = bodeplot(Kpdr{3}*BSfilter,{1*2*pi, 1e5*2*pi},'b:');%,':'
%         setoptions(h,'FreqUnits','Hz','PhaseVisible','off');
        [Mag,Phase]= bode(Kpdr{3}*BSfilter,W*2*pi);
        semilogx(W,20*log10(Mag(:)),'b:','Linewidth',1); 
        xlabel('Frequency (Hz)');
        ylabel('Magnitude (dB)'); 
%   xlim([1e1 1e3])
%         ylim([40 160])
        title('')  
        
        ax = gca;
        ax.XTick = [1 10 1e2 1e3 1e4 1e5];                                                                                                                                   
        grid on;  
        goodplot;
        legend({'$K_{cla}$','$K_\mu$','$K_{M}$','$K_{M2}$'},'Interpreter','latex','Location','SouthEast')
        goodplot;
        print -painters -dpdf -r150 ControllerFR.pdf
        %% 
        figure;         
        [Mag,Phase]= bode(BSfilter,W*2*pi);
        semilogx(W,20*log10(Mag(:)),'b'); 
        xlabel('Frequency (Hz)');
        ylabel('Magnitude (dB)'); 
        xlim([1e1 1e3])
%         ylim([40 160])
        title('')  
        grid on;
%         ax = gca;
%         ax.XTick = [1 10 1e2 1e3 1e4 1e5];  
        goodplot;
%         print -painters -dpdf -r150 BSFR.pdf
        
    end
else Type == 2
    for nomeaning = 1
%Settings 
        Tdata = 1e-3; % sample time for record data
        Dura = 2;
        NumPot = Dura/Tdata;

        %% Lead lag compensator 
        load f3_ll
        time = ExpData.X.Data;
        time = time - time(1);
        ref = ExpData.Y(1,1).Data*180/pi;
        yout = ExpData.Y(1,2).Data*180/pi;
        cur12 = ExpData.Y(1,3).Data;
        cur34 = ExpData.Y(1,4).Data;
        % find the first peak in reference signal
        for i = 1:length(ref)
            if ref(i) > 0.01429*180/pi && ref(i) <= 0.0143*180/pi
            index = i
            break;
            end
        end
        % put the start 0.1 second ahead of the first peak of the reference signal
        ref = ref((time(i)-0.1)/Tdata:(time(i)-0.1)/Tdata+NumPot-1); 
        yout = yout((time(i)-0.1)/Tdata:(time(i)-0.1)/Tdata+NumPot-1);
        cur12 = cur12((time(i)-0.1)/Tdata:(time(i)-0.1)/Tdata+NumPot-1);
        cur34 = cur34((time(i)-0.1)/Tdata:(time(i)-0.1)/Tdata+NumPot-1);
        time = time(1:NumPot);

        figure;
        subplot(2,1,1)
        % time = time(1:5.5/Ts);ref = ref(1:5.5/Ts);yout = yout(1:11.5/Ts);
        plot(time,ref*0,'k--','Linewidth',0.8)
        hold on;
        plot(time,ref,'b--','Linewidth',0.8)
        plot(time,yout,'k:','Linewidth',1.5)
        
        subplot(2,1,2) 
        plot(time,ref*0,'k--','Linewidth',0.8)
        hold on;
        plot(time,ref-yout,'k:','Linewidth',1.5)
        rms1 = rms(ref-yout)
%         rms_cur1 = rms(cur12)*2+rms(cur34)*2
        
        integ_cur1 = (sum(abs(cur12))*5e-4+sum(abs(cur34))*5e-4)*2 *1000/3600
        
%         subplot(3,1,3)
%         plot(time,cur12,'k','Linewidth',1)
%         hold on;

        %% Lead lag compensator 
        load f3_mu
        time = ExpData.X.Data;
        time = time - time(1);
        ref = ExpData.Y(1,1).Data*180/pi;
        yout = ExpData.Y(1,2).Data*180/pi;
        cur12 = ExpData.Y(1,3).Data;
        cur34 = ExpData.Y(1,4).Data;
        % find the first peak in reference signal
        for i = 1:length(ref)
            if ref(i) > 0.01429*180/pi && ref(i) <= 0.0143*180/pi
            index = i;
            break;
            end
        end
        % put the start 0.1 second ahead of the first peak of the reference signal
        ref = ref((time(i)-0.1)/Tdata:(time(i)-0.1)/Tdata+NumPot-1); 
        yout = yout((time(i)-0.1)/Tdata:(time(i)-0.1)/Tdata+NumPot-1);
        cur12 = cur12((time(i)-0.1)/Tdata:(time(i)-0.1)/Tdata+NumPot-1);
        cur34 = cur34((time(i)-0.1)/Tdata:(time(i)-0.1)/Tdata+NumPot-1);
        time = time(1:NumPot);

        subplot(2,1,1)
        % time = time(1:5.5/Ts);ref = ref(1:5.5/Ts);yout = yout(1:11.5/Ts);
        plot(time,yout,'g','Linewidth',1)
        subplot(2,1,2) 
        plot(time,ref-yout,'g','Linewidth',1)
%         subplot(3,1,3)
%         plot(time,cur12,'g--','Linewidth',1)
%         hold on;
        rms2 = rms(ref-yout)
        integ_cur2 = (sum(abs(cur12))*5e-4+sum(abs(cur34))*5e-4)*2 *1000/3600

        %% mlpv controller 
        load f3_mlpv
        time2 = ExpData.X.Data;
        time2 = time2 - time2(1);
        ref = ExpData.Y(1,1).Data*180/pi;
        yout = ExpData.Y(1,2).Data*180/pi;
        cur12 = ExpData.Y(1,3).Data;
        cur34 = ExpData.Y(1,3).Data;
        % figure;
        % plot(time2,ref,time2,yout)
        % return;
        % find the first peak in reference signal
        for i = 1:length(ref)
            if ref(i) > 0.01429*180/pi && ref(i) <= 0.0143*180/pi
            index = i;
            break;
            end
        end
        % put the start 0.1 second ahead of the first peak of the reference signal
        ref = ref((time2(i)-0.1)/Tdata:(time2(i)-0.1)/Tdata+NumPot-1); 
        yout = yout((time2(i)-0.1)/Tdata:(time2(i)-0.1)/Tdata+NumPot-1)*1.75/1.7;
        cur12 = cur12((time2(i)-0.1)/Tdata:(time2(i)-0.1)/Tdata+NumPot-1)*1.75/1.7;
        cur34 = cur34((time2(i)-0.1)/Tdata:(time2(i)-0.1)/Tdata+NumPot-1)*1.75/1.7;
        subplot(2,1,1)
        plot(time,yout,'r-.','Linewidth',1)
        % % simin4.time2 = time';
        % % simin4.signals.values = [cur1;cur2;cur3;cur4]';
        % % simin4.signals.dimensions = 4;        
        ylabel('Rot. angle(deg)');
        xlabel('Time (s)') 
        goodplot([7 7]);
%         legend('$K_{class}$','$K_\mu$','$K_{mLPV}$','Location','SouthEast')
%         goodplot;
        subplot(2,1,2)
        plot(time,ref-yout,'r-.','Linewidth',1)
        rms3 = rms(ref-yout)
        integ_cur3 = (sum(abs(cur12))*5e-4+sum(abs(cur34))*5e-4)*2 *1000/3600
%         legend('Classical controller','\mu controller','mLPV controller')
        xlabel('Time (s)');
        ylabel('Track error (deg)');
%         subplot(3,1,3)
%         xlabel('Time (s)');
%         ylabel('Current for coil 1&2 (A)');
%         plot(time,cur12,'r-.','Linewidth',1)
        goodplot([7 7]);
%         legend('$K_{class}$','$K_\mu$','$K_{mLPV}$','Location','SouthEast')
%         goodplot;
        print -painters -dpdf -r150 TrackPerf.pdf        
    end
end

