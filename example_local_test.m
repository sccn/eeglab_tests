import matlab.unittest.TestRunner;
import matlab.unittest.Verbosity;
import matlab.unittest.constraints.StartsWithSubstring;
import matlab.unittest.plugins.CodeCoveragePlugin;
import matlab.unittest.plugins.TestReportPlugin;
import matlab.unittest.plugins.XMLPlugin;
import matlab.unittest.plugins.codecoverage.CoberturaFormat;
import matlab.unittest.selectors.HasBaseFolder;
% import sltest.plugins.TestManagerResultsPlugin;

addpath(genpath('eeglab/functions'));

suite = testsuite(pwd, 'IncludeSubfolders', true);
suite = suite.selectIf(HasBaseFolder(StartsWithSubstring(fullfile(pwd, './'))));

[~,~] = mkdir('test-results');

runner = TestRunner.withTextOutput('OutputDetail', Verbosity.Detailed);
runner.addPlugin(TestReportPlugin.producingPDF('test-results/results_R2020a.pdf'));
runner.addPlugin(XMLPlugin.producingJUnitFormat('test-results/results_R2020a.xml'));
% runner.addPlugin(TestManagerResultsPlugin());
runner.addPlugin(CodeCoveragePlugin.forFolder({'eeglab/functions'}, 'IncludingSubfolders', true, 'Producing', CoberturaFormat('coverage_R2020a.xml')));

results = runner.run(suite);

nfailed = nnz([results.Failed]);
assert(nfailed == 0, [num2str(nfailed) ' test(s) failed.']);