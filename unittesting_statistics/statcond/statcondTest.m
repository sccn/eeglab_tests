% statcond - EEGLAB statistical testing function
%
% Statistics are critical for inference testing in Science. It is thus
% primordial to make sure that all the statistics implemented are robust
% and at least bug free. Statistical function using complex formulas are
% inherently prone to bugs. EEGLAB functions are all the more prone to bugs
% given that they only use complex MATLAB code to avoid loops and speed up
% computation.
%
% This test class does not guarantee that EEGLAB statistical functions are
% bug free. It does assure though that bugs are unlikely and minor if they
% are present.
%
% This test class tests 3 things:
%
%   Tagged: VectorReference
% * First, it checks that for vector inputs the EEGLAB functions returns
%   the same output as other reference functions from the Statistics (and
%   Machine Learning) Toolbox or from other packages tested against the
%   SPSS software for repeated measure ANOVA (rm_anova2 function).
%
%   Tagged: Dimensions
% * Second, it checks that array inputs with different number of dimensions
%   (from 1 to 3) the EEGLAB function returns the same output.
%
%   Tagged: Shuffle
% * Third, it checks that the permutation and bootstrap methods shuffle
%   the data properly by running multiple tests.

classdef statcondTest < matlab.unittest.TestCase
    
    properties
        sameRelTol = 1e-2;
    end
    
    properties (TestParameter)
        ttest_a = {{ rand(1,10) rand(1,10)+0.5 }};
        anova_a = {{ rand(1,10) rand(1,10) rand(1,10)+0.2; rand(1,10) rand(1,10)+0.2 rand(1,10) }};
        
        dimT_par = { statcondTest.calculateDimParameters('T') };
        dim1A_par = { statcondTest.calculateDimParameters('1A') };
        dim2A_par = { statcondTest.calculateDimParameters('2A') };
        
        method = {1, 2};
        shuffle_par = statcondTest.calculateShuffleParameters();
        
    end
    
    
    methods(Test, TestTags = {'VectorReference'})
        
        function pairedTTest(testCase, ttest_a)
            % testing paired t-test
            a = ttest_a;
            
            [t, df, pvals, ~] = statcond(a, 'mode', 'param', 'verbose', 'off', 'paired', 'on');
            [~, p, ~, stats] = ttest(a{1}, a{2});
            testCase.log( ...
                sprintf("Statistics paired statcond    t-value %2.2f df=%d p=%0.4f\n", t, df, pvals) + ...
                sprintf("Statistics paired ttest func. t-value %2.2f df=%d p=%0.4f\n", stats.tstat, stats.df, p) ...
                );
            
            testCase.verifySame(t, stats.tstat);
            testCase.verifySame(df, stats.df);
            testCase.verifySame(pvals, p);
        end
        
        
        function unpairedTTest(testCase, ttest_a)
            % testing unpaired t-test
            a = ttest_a;
            
            [t, df, pvals, ~] = statcond(a, 'mode', 'param', 'verbose', 'off', 'paired', 'off', 'variance', 'homogenous');
            [~, p, ~, stats] = ttest2(a{1}, a{2});
            testCase.log( ...
                sprintf("Statistics unpaired statcond     t-value %2.2f df=%d p=%0.4f\n", t, df, pvals) + ...
                sprintf("Statistics unpaired ttest2 func. t-value %2.2f df=%d p=%0.4f\n", stats.tstat, stats.df, p) ...
                );
            
            testCase.verifySame(t, stats.tstat);
            testCase.verifySame(df, stats.df);
            testCase.verifySame(pvals, p);
        end
        
        
        function paired1Anova(testCase, anova_a)
            % testing paired 1-way ANOVA
            a = anova_a;
            
            [F, df, pvals, ~] = statcond(a(1,:), 'mode', 'param', 'verbose', 'off', 'paired', 'on');
            z = zeros(10,1); o = ones(10,1); t = ones(10,1)*2;
            stats = rm_anova2(  [ a{1,1}';a{1,2}';a{1,3}'], repmat((1:10)', [3 1]), [o;o;o], [z;o;t], {'a','b'});
            testCase.log( ...
                sprintf("Statistics 1-way paired statcond        F-value %2.2f df1=%d df2=%d p=%0.4f\n", F, df(1), df(2), pvals) + ...
                sprintf("Statistics 1-way paired rm_anova2 func. F-value %2.2f df1=%d df2=%d p=%0.4f\n", stats{3,5}, stats{3,3}, stats{6,3}, stats{3,6}) ...
                );
            
            testCase.verifySame(double(F), stats{3,5});
            testCase.verifySame(df(1), stats{3,3});
            testCase.verifySame(df(2), stats{6,3});
            testCase.verifySame(double(pvals), stats{3,6});
            
        end
        
        
        function paired2Anova(testCase, anova_a)
            % testing paired 2-way ANOVA
            a = anova_a;
            
            [F, df, pvals, ~] = statcond(a, 'mode', 'param', 'verbose', 'off', 'paired', 'on');
            z = zeros(10,1); o = ones(10,1); t = ones(10,1)*2;
            stats = rm_anova2(  [ a{1,1}';a{1,2}';a{1,3}';a{2,1}';a{2,2}';a{2,3}' ], ...
                repmat((1:10)', [6 1]), [o;o;o;z;z;z], [z;o;t;z;o;t], {'a','b'});
            testCase.log( ...
                sprintf("Statistics 2-way paired statcond        F-value %2.2f df1=%d df2=%d p=%0.4f\n", F{3}, df{3}(1), df{3}(2), pvals{3}) + ...
                sprintf("Statistics 2-way paired rm_anova2 func. F-value %2.2f df1=%d df2=%d p=%0.4f\n", stats{4,5}, stats{4,3}, stats{7,3}, stats{4,6}) ...
                );
            
            testCase.verifySame(double(F{3}), stats{4,5});
            testCase.verifySame(df{3}(1), stats{4,3});
            testCase.verifySame(df{3}(2), stats{7,3});
            testCase.verifySame(double(pvals{3}), stats{4,6});
            
        end

        
        function unpaired1Anova(testCase, anova_a)
            % testing 1-way unpaired ANOVA
            a = anova_a;
            
            [F, df, pvals , ~] = statcond(a(1,:), 'mode', 'param', 'verbose', 'off', 'paired', 'off');
            [~, stats] = anova1( [ a{1,1}' a{1,2}' a{1,3}' ],{}, 'off');
            testCase.log( ...
                sprintf("Statistics 1-way unpaired statcond     F-value %2.2f df1=%d df2=%d p=%0.4f\n", F, df(1), df(2), pvals) + ...
                sprintf("Statistics 1-way unpaired anova1 func. F-value %2.2f df1=%d df2=%d p=%0.4f\n", stats{2,5}, stats{2,3}, stats{3,3}, stats{2,6}) ...
                );

            testCase.verifySame(double(F), stats{2,5});
            testCase.verifySame(df(1), stats{2,3});
            testCase.verifySame(df(2), stats{3,3});
            testCase.verifySame(double(pvals),  stats{2,6});

        end
    
        
        function unpaired2Anova(testCase, anova_a)
            % testing 2-way unpaired ANOVA
            a = anova_a;

            [F, df, pvals , ~] = statcond(a, 'mode', 'param', 'verbose', 'off', 'paired', 'off');
            [~, stats] = anova2( [ a{1,1}' a{1,2}' a{1,3}'; a{2,1}' a{2,2}' a{2,3}' ], 10, 'off');
            testCase.log( ...
                sprintf("Statistics 2-way unpaired statcond     F-value %2.2f df1=%d df2=%d p=%0.4f\n", F{3}, df{3}(1), df{3}(2), pvals{3}) + ...
                sprintf("Statistics 2-way unpaired anova2 func. F-value %2.2f df1=%d df2=%d p=%0.4f\n", stats{4,5}, stats{4,3}, stats{5,3}, stats{4,6}) ... 
                );
    
            testCase.verifySame(double(F{3}), stats{4,5});
            testCase.verifySame(df{3}(1), stats{4,3});
            testCase.verifySame(df{3}(2), stats{5,3});
            testCase.verifySame(double(pvals{3}),  stats{4,6});
            
        end
        
    end
    
    methods(Test, TestTags = {'Dimensions'})
        % testing different dimensions in statcond
        
        function pairedDimTTest(testCase, dimT_par)
            
            FUT = @(data) statcond(data, 'mode', 'param', 'verbose', 'off', 'paired', 'on');
            
            [t, df, pvals] = cellfun(FUT, dimT_par, 'UniformOutput', false);
            
            testCase.log( ...
                sprintf("Statistics paired statcond t-test dim1 t-value %2.2f df=%d p=%0.4f\n", t{1},        df{1}, pvals{1}) + ...
                sprintf("Statistics paired statcond t-test dim2 t-value %2.2f df=%d p=%0.4f\n", t{2}(4),     df{2}, pvals{2}(4)) + ...
                sprintf("Statistics paired statcond t-test dim3 t-value %2.2f df=%d p=%0.4f\n", t{3}(2,4),   df{3}, pvals{3}(2,4)) + ...
                sprintf("Statistics paired statcond t-test dim4 t-value %2.2f df=%d p=%0.4f\n", t{4}(1,2,4), df{4}, pvals{4}(1,2,4)) ...
                );
            
            testCase.verifySame(t{1}, t{2}(4), t{3}(2,4), t{4}(1,2,4));
            testCase.verifySame(df{:});
            testCase.verifySame(pvals{1}, pvals{2}(4), pvals{3}(2,4), pvals{4}(1,2,4));
            
        end
        
        
        function unpairedDimTTest(testCase, dimT_par)
            
            FUT = @(data) statcond(data, 'mode', 'param', 'verbose', 'off', 'paired', 'off', 'variance', 'homogenous');
            
            [t, df, pvals] = cellfun(FUT, dimT_par, 'UniformOutput', false);
            
            testCase.log( ...
                sprintf("Statistics unpaired statcond t-test dim1 t-value %2.2f df=%d p=%0.4f\n", t{1},        df{1}, pvals{1}) + ...
                sprintf("Statistics unpaired statcond t-test dim2 t-value %2.2f df=%d p=%0.4f\n", t{2}(4),     df{2}, pvals{2}(4)) + ...
                sprintf("Statistics unpaired statcond t-test dim3 t-value %2.2f df=%d p=%0.4f\n", t{3}(2,4),   df{3}, pvals{3}(2,4)) + ...
                sprintf("Statistics unpaired statcond t-test dim4 t-value %2.2f df=%d p=%0.4f\n", t{4}(1,2,4), df{4}, pvals{4}(1,2,4)) ...
                );
            
            testCase.verifySame(t{1}, t{2}(4), t{3}(2,4), t{4}(1,2,4));
            testCase.verifySame(df{:});
            testCase.verifySame(pvals{1}, pvals{2}(4), pvals{3}(2,4), pvals{4}(1,2,4));
            
        end
        
        
        function pairedDim1Anova(testCase, dim1A_par)
            
            FUT = @(data) statcond(data, 'mode', 'param', 'verbose', 'off', 'paired', 'on');
            
            [t, df, pvals] = cellfun(FUT, dim1A_par, 'UniformOutput', false);
            
            testCase.log( ...
                sprintf("Statistics paired statcond anova 1-way dim1 t-value %2.2f df1=%d df2=%d p=%0.4f\n", t{1},        df{1}, pvals{1}) + ...
                sprintf("Statistics paired statcond anova 1-way dim2 t-value %2.2f df1=%d df2=%d p=%0.4f\n", t{2}(4),     df{2}, pvals{2}(4)) + ...
                sprintf("Statistics paired statcond anova 1-way dim3 t-value %2.2f df1=%d df2=%d p=%0.4f\n", t{3}(2,4),   df{3}, pvals{3}(2,4)) + ...
                sprintf("Statistics paired statcond anova 1-way dim4 t-value %2.2f df1=%d df2=%d p=%0.4f\n", t{4}(1,2,4), df{4}, pvals{4}(1,2,4)) ...
                );
            
            testCase.verifySame(t{1}, t{2}(4), t{3}(2,4), t{4}(1,2,4));
            testCase.verifySame(df{:});
            testCase.verifySame(pvals{1}, pvals{2}(4), pvals{3}(2,4), pvals{4}(1,2,4));
            
        end
        
        
        function unpairedDim1Anova(testCase, dim1A_par)
            
            FUT = @(data) statcond(data, 'mode', 'param', 'verbose', 'off', 'paired', 'off');
            
            [t, df, pvals] = cellfun(FUT, dim1A_par, 'UniformOutput', false);
            
            testCase.log( ...
                sprintf("Statistics unpaired statcond anova 1-way dim1 t-value %2.2f df1=%d df2=%d p=%0.4f\n", t{1},        df{1}, pvals{1}) + ...
                sprintf("Statistics unpaired statcond anova 1-way dim2 t-value %2.2f df1=%d df2=%d p=%0.4f\n", t{2}(4),     df{2}, pvals{2}(4)) + ...
                sprintf("Statistics unpaired statcond anova 1-way dim3 t-value %2.2f df1=%d df2=%d p=%0.4f\n", t{3}(2,4),   df{3}, pvals{3}(2,4)) + ...
                sprintf("Statistics unpaired statcond anova 1-way dim4 t-value %2.2f df1=%d df2=%d p=%0.4f\n", t{4}(1,2,4), df{4}, pvals{4}(1,2,4)) ...
                );
            
            testCase.verifySame(t{1}, t{2}(4), t{3}(2,4), t{4}(1,2,4));
            testCase.verifySame(df{:});
            testCase.verifySame(pvals{1}, pvals{2}(4), pvals{3}(2,4), pvals{4}(1,2,4));
            
        end
        
        
        function pairedDim2Anova(testCase, dim2A_par)
            
            FUT = @(data) statcond(data, 'mode', 'param', 'verbose', 'off', 'paired', 'on');
            
            [t, df, pvals] = cellfun(FUT, dim2A_par, 'UniformOutput', false);
            
            testCase.log( ...
                sprintf("Statistics paired statcond anova 2-way dim1 t-value %2.2f df1=%d df2=%d p=%0.4f\n", t{1}{3},        df{1}{3}(1), df{1}{3}(2), pvals{1}{3}) + ...
                sprintf("Statistics paired statcond anova 2-way dim2 t-value %2.2f df1=%d df2=%d p=%0.4f\n", t{2}{3}(4),     df{2}{3}(1), df{2}{3}(2), pvals{2}{3}(4)) + ...
                sprintf("Statistics paired statcond anova 2-way dim3 t-value %2.2f df1=%d df2=%d p=%0.4f\n", t{3}{3}(2,4),   df{3}{3}(1), df{3}{3}(2), pvals{3}{3}(2,4)) + ...
                sprintf("Statistics paired statcond anova 2-way dim4 t-value %2.2f df1=%d df2=%d p=%0.4f\n", t{4}{3}(1,2,4), df{4}{3}(1), df{4}{3}(2), pvals{4}{3}(1,2,4)) ...
                );
            
            testCase.verifySame(t{1}{3}, t{2}{3}(4), t{3}{3}(2,4), t{4}{3}(1,2,4));
            testCase.verifySame(df{1}{3}(1), df{2}{3}(1), df{3}{3}(1), df{4}{3}(1));
            testCase.verifySame(df{1}{3}(2), df{2}{3}(2), df{3}{3}(2), df{4}{3}(2));
            testCase.verifySame(pvals{1}{3}, pvals{2}{3}(4), pvals{3}{3}(2,4), pvals{4}{3}(1,2,4));
            
        end
        
        
        function unpairedDim2Anova(testCase, dim2A_par)
            
            FUT = @(data) statcond(data, 'mode', 'param', 'verbose', 'off', 'paired', 'off');
            
            [t, df, pvals] = cellfun(FUT, dim2A_par, 'UniformOutput', false);
            
            testCase.log( ...
                sprintf("Statistics unpaired statcond anova 2-way dim1 t-value %2.2f df1=%d df2=%d p=%0.4f\n", t{1}{3},        df{1}{3}(1), df{1}{3}(2), pvals{1}{3}) + ...
                sprintf("Statistics unpaired statcond anova 2-way dim2 t-value %2.2f df1=%d df2=%d p=%0.4f\n", t{2}{3}(4),     df{2}{3}(1), df{2}{3}(2), pvals{2}{3}(4)) + ...
                sprintf("Statistics unpaired statcond anova 2-way dim3 t-value %2.2f df1=%d df2=%d p=%0.4f\n", t{3}{3}(2,4),   df{3}{3}(1), df{3}{3}(2), pvals{3}{3}(2,4)) + ...
                sprintf("Statistics unpaired statcond anova 2-way dim4 t-value %2.2f df1=%d df2=%d p=%0.4f\n", t{4}{3}(1,2,4), df{4}{3}(1), df{4}{3}(2), pvals{4}{3}(1,2,4)) ...
                );
            
            testCase.verifySame(t{1}{3}, t{2}{3}(4), t{3}{3}(2,4), t{4}{3}(1,2,4));
            testCase.verifySame(df{1}{3}(1), df{2}{3}(1), df{3}{3}(1), df{4}{3}(1));
            testCase.verifySame(df{1}{3}(2), df{2}{3}(2), df{3}{3}(2), df{4}{3}(2));
            testCase.verifySame(pvals{1}{3}, pvals{2}{3}(4), pvals{3}{3}(2,4), pvals{4}{3}(1,2,4));
            
        end
    end
    
    methods(Test, ParameterCombination = 'exhaustive', TestTags = {'Shuffle'})
        function shuffleAndPermutation(testCase, method, shuffle_par)
            opt = {};
            if method == 2
                opt = {'arraycomp', 'off'};
            end
            
            sa1 = statcond(shuffle_par, 'mode', 'bootstrap', 'verbose', 'off', 'paired', 'on',  'returnresamplingarray', 'on', opt{:}, 'naccu', 10);
            sa2 = statcond(shuffle_par, 'mode', 'perm'     , 'verbose', 'off', 'paired', 'on',  'returnresamplingarray', 'on', opt{:}, 'naccu', 10);
            sa3 = statcond(shuffle_par, 'mode', 'bootstrap', 'verbose', 'off', 'paired', 'off', 'returnresamplingarray', 'on', opt{:}, 'naccu', 10);
            sa4 = statcond(shuffle_par, 'mode', 'perm'     , 'verbose', 'off', 'paired', 'off', 'returnresamplingarray', 'on', opt{:}, 'naccu', 10);
            
            % select data
            nd = ndims(sa1{1});
            if nd == 2 && size(sa1{1},2) > 1
                for t=1:length(sa1)
                    sa1{t} = sa1{t}(end,:);
                    sa2{t} = sa2{t}(end,:);
                    sa3{t} = sa3{t}(end,:);
                    sa4{t} = sa4{t}(end,:);
                end
            elseif nd == 3
                for t=1:length(sa1)
                    sa1{t} = squeeze(sa1{t}(end,end,:));
                    sa2{t} = squeeze(sa2{t}(end,end,:));
                    sa3{t} = squeeze(sa3{t}(end,end,:));
                    sa4{t} = squeeze(sa4{t}(end,end,:));
                end
            elseif nd == 4
                for t=1:length(sa1)
                    sa1{t} = squeeze(sa1{t}(end,end,end,:));
                    sa2{t} = squeeze(sa2{t}(end,end,end,:));
                    sa3{t} = squeeze(sa3{t}(end,end,end,:));
                    sa4{t} = squeeze(sa4{t}(end,end,end,:));
                end
            end
            
            % for paired bootstrap, we make sure that the resampling has only shuffled between conditions
            % for instance [101 2 1003 104 ...] is an acceptable sequence
            testCase.verifyEqual(rem(sa1{1}(:)',10), single([1:9 0]), 'Bootstrap paired resampling Error')
            testCase.verifyEqual(rem(sa1{2}(:)',10), single([1:9 0]), 'Bootstrap paired resampling Error')
            
            % for paired permutation, in addition, we make sure that the sum accross condition is constant
            % which is not true for bootstrap
            msa = statcondTest.meansa(sa2); msa = msa(:)-msa(1);
            testCase.verifyEqual(rem(sa1{1}(:)',10), single([1:9 0]), 'Permutation paired resampling Error')
            testCase.verifyEqual(rem(sa1{2}(:)',10), single([1:9 0]), 'Permutation paired resampling Error')
            testCase.verifyEqual(round(msa), single((0:9)'), 'Permutation paired resampling Error')
            testCase.verifyLength(unique(sa2{1}), 10, 'Permutation paired resampling Error');
            testCase.verifyLength(unique(sa2{2}), 10, 'Permutation paired resampling Error');
            
            % for unpaired bootstrap, only make sure there are enough unique
            % values
            testCase.verifyGreaterThan(length(unique(sa3{1})), 3, 'Bootstrap unpaired reampling Error')
            testCase.verifyGreaterThan(length(unique(sa3{2})), 3, 'Bootstrap unpaired reampling Error')
            
            % for unpaired permutation, the number of unique values must be 10
            % and the sum must be constant (not true for bootstrap)
            testCase.verifyLength(unique(sa4{1}), 10, 'Permutation unpaired reampling Error')
            testCase.verifyLength(unique(sa4{2}), 10, 'Permutation unpaired reampling Error')
            testCase.verifyTrue( ...
                floor(mean(statcondTest.meansa(sa4))) == 55 || ...
                floor(mean(statcondTest.meansa(sa4))) == 372, 'Permutation unpaired reampling Error')
            
        end
    end
    
    methods
        
        function verifySame(testCase, varargin)
            % verify that all args in varargin are the same (considering
            % the default RelTol in this test case)
            for idx=2:length(varargin)
                testCase.verifyEqual(varargin{1}, varargin{idx}, 'RelTol', testCase.sameRelTol);
            end
            
        end
        
    end
    
    methods(Static)
        
        function dim_p = calculateDimParameters(type)
            % prepare input parameters for the Dim tests
            a = { rand(1,10)      rand(1,10)+0.5      rand(1,10)};
            b = { rand(10,10)     rand(10,10)+0.5     rand(10,10)};     b{1}(4,:)     = a{1}; b{2}(4,:)     = a{2}; b{3}(4,:)     = a{3};
            c = { rand(5,10,10)   rand(5,10,10)+0.5   rand(5,10,10)};   c{1}(2,4,:)   = a{1}; c{2}(2,4,:)   = a{2}; c{3}(2,4,:)   = a{3};
            d = { rand(2,5,10,10) rand(2,5,10,10)+0.5 rand(2,5,10,10)}; d{1}(1,2,4,:) = a{1}; d{2}(1,2,4,:) = a{2}; d{3}(1,2,4,:) = a{3};
            
            switch (type)
                case 'T'
                    dim_p = { a(1:2), b(1:2), c(1:2), d(1:2) };
                    
                case '1A'
                    dim_p = {a, b, c, d};
                    
                case '2A'
                    a(2,:) = a; a{1} = a{1}/2;
                    b(2,:) = b; b{1} = b{1}/2;
                    c(2,:) = c; c{1} = c{1}/2;
                    d(2,:) = d; d{1} = d{1}/2;
                    
                    dim_p = {a, b, c, d};
                    
            end
            
        end
        
        function a = calculateShuffleParameters()
            % prepare input parameters for Shuffle tests
            m1 = 1:10;
            m2 = (1:10) + 100;
            m3 = (1:10) + 1000;
            
            a{1} = { m1 m2 };
            a{2} = { m1 m2 m3 };
            a{3} = { [ zeros(9,10); m1] [ zeros(9,10); m2] };
            a{4} = { [ zeros(9,10); m1] [ zeros(9,10); m2] [ zeros(9,10); m3] };
            tmpa = zeros(9,8,10); tmpa(end,end,:) = m1;
            tmpb = zeros(9,8,10); tmpb(end,end,:) = m2;
            tmpc = zeros(9,8,10); tmpc(end,end,:) = m3;
            a{5} = { tmpa tmpb };
            a{6} = { tmpa tmpb tmpc };
            
        end
        
        function meanmat = meansa(mat)
            % mean for sa cell arrays
            
            meanmat = zeros(size(mat{1}));
            for index = 1:length(mat)
                meanmat = meanmat + mat{index} / length(mat);
            end
            
        end
        
    end
    
end
