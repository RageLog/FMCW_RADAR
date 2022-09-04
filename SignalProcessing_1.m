classdef SignalProcessing_1
    properties
        mixedSignal
        filteredSignal
        UpChirpWindowingFunction
        DownChirpWindowingFunction
        UpChirpWindowedFunction
        DownChirpWindowedFunction
        UpChirpFftSignal
        DownChirpFftSignal

        CFarUpChirp
        CFarUpChirpThreshold
        CFarDownChirp
        CFarDownChirpThreshold
    end
    
    methods
        function obj = SignalProcessing_1(param,SignalGenerator)
            obj.mixedSignal = SignalGenerator.SplitedSignal .* conj(SignalGenerator.RxSignal);
            obj.filteredSignal = lowpass(obj.mixedSignal,((param.Fd*param.Rmax)/(param.C0*param.Ts))+((param.Fc*param.Vmax)/param.C0),param.Fs);          
            obj = obj.windowing(param);
            X = obj.UpChirpWindowedFunction;
            L = length(X);
            Y = fft(X);
            P2 = abs(Y/L);
            P1 = P2(1:L/2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            f = param.Fs*(0:(L/2))/L;

            figure(1)
            plot(SignalGenerator.Time,X)

            figure(2)
            plot(f,P1) 
            title('Single-Sided Amplitude Spectrum of X(t)')
            xlabel('f (Hz)')
            ylabel('|P1(f)|')
            obj = obj.FftProcess(param);
            obj = obj. CFarCalculation(param);



        end
        function obj = windowing(obj,param)
            obj.UpChirpWindowingFunction = hamming(param.SampPerMod* param.TRate,"periodic")';
            obj.DownChirpWindowingFunction = hamming(param.SampPerMod* (1-param.TRate),"periodic")';
            obj.UpChirpWindowedFunction = zeros(param.NumOfMod,(param.SampPerMod*param.TRate));
            obj.DownChirpWindowedFunction = zeros(param.NumOfMod,(param.SampPerMod*(1-param.TRate)));
            for it= 1:param.NumOfMod
                obj.UpChirpWindowedFunction(it,:) = obj.filteredSignal((it-1)*param.SampPerMod+1:((it-1)*param.SampPerMod+1)+(param.SampPerMod* param.TRate)-1) .*  obj.UpChirpWindowingFunction;
                obj.DownChirpWindowedFunction(it,:) = obj.filteredSignal((((it-1)*param.SampPerMod+1)+(param.SampPerMod* param.TRate)):it*param.SampPerMod) .*  obj.DownChirpWindowingFunction;
            end
        end
        function obj = FftProcess(obj,param)
            UpChirpZeroPaddingSignal = [ obj.UpChirpWindowedFunction zeros(size(obj.UpChirpWindowedFunction))];
            temp1 = zeros(size(UpChirpZeroPaddingSignal));
            for it = 1 : param.NumOfMod
                temp1(it,:) = fftshift(fft(UpChirpZeroPaddingSignal(it,:)));
            end
            obj.UpChirpFftSignal = temp1(:,1:ceil(size(temp1,2)/2));
            DownChirpZeroPaddingSignal = [ obj.DownChirpWindowedFunction zeros(size(obj.DownChirpWindowedFunction))];
            temp2 = zeros(size(DownChirpZeroPaddingSignal));
            for it = 1 : param.NumOfMod
                temp2(it,:) = fftshift(fft(DownChirpZeroPaddingSignal(it,:)));
            end
            obj.DownChirpFftSignal = temp2(:,1:ceil(size(temp2,2)/2));
        end
        function obj = CFarCalculation(obj,param)
            uChirp = abs(obj.UpChirpFftSignal/(param.SampPerMod*param.TRate));
            dChirp = abs(obj.DownChirpFftSignal/(param.SampPerMod*(1-param.TRate)));    

            mCFar = phased.CFARDetector('NumTrainingCells',4,'NumGuardCells',2);
            mCFar.ThresholdFactor = 'Auto';
            mCFar.ThresholdOutputPort = true;
            mCFar.ProbabilityFalseAlarm = 1e-3;

            [obj.CFarUpChirp,obj.CFarUpChirpThreshold] = mCFar(uChirp,1:127);
            [obj.CFarDownChirp,obj.CFarDownChirpThreshold] = mCFar(dChirp,1:127);

            figure()
            plot(obj.CFarUpChirp,"r");
            hold on
            plot(obj.CFarUpChirpThreshold,"g");
            hold on
            plot(find(obj.CFarUpChirp),obj.UpChirpFftSignal(obj.CFarUpChirp),'o');

        end
    end

end








