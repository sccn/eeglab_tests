classdef t_finputcheck < RegressionTest

	methods (Test)

		function test_1(testCase)

			results = finputcheck(testCase.inputs{1}{:});
			testCase.process(results);

		end

		function test_2(testCase)

			results = finputcheck(testCase.inputs{2}{:});
			testCase.process(results);

		end

		function test_3(testCase)

			results = finputcheck(testCase.inputs{3}{:});
			testCase.process(results);

		end

		function test_4(testCase)

			results = finputcheck(testCase.inputs{4}{:});
			testCase.process(results);

		end

		function test_5(testCase)

			results = finputcheck(testCase.inputs{5}{:});
			testCase.process(results);

		end

		function test_6(testCase)

			[results{1:2}] = finputcheck(testCase.inputs{6}{:});
			testCase.process(results);

		end

	end

end
