classdef (Abstract = true) RegressionTest < matlab.unittest.TestCase
    
    properties
        dataFile
        inputs
        expResults
    end
    
    methods(TestMethodSetup)
        function setDefaultSeed(~)
            rng('default');
        end
    end
    
    methods
        function obj = RegressionTest
            obj.dataFile = obj.getDataFullfile();
            obj.loadDataFromFile();
            
        end
        
        function process(obj, results)
            
            testName = obj.getTestMethod();
            
            reference = obj.expResults.(testName).value;
            absTol = obj.expResults.(testName).absTol;
            relTol = obj.expResults.(testName).relTol;
            obj.verifyEqual(results, reference, 'AbsTol', absTol, 'RelTol', relTol);
            
        end
        
        function dataFile = getDataFullfile(obj)
            
            testFile = which(class(obj));
            dataFile = [testFile(1:end-1) 'mat'];
            
        end
        
        function loadDataFromFile(obj)
            
            loadedData = load(obj.dataFile);
            
            obj.inputs = loadedData.inputs;
            obj.expResults = rmfield(loadedData, 'inputs');
            
        end
        
    end
    
    
    methods(Static)
        
        function testMethod = getTestMethod()
            
            stackInfo = dbstack;
            testFullName = stackInfo(3).name;
            dotpos = strfind(testFullName, '.');
            testMethod = testFullName(dotpos(1) + 1 : end);
            
        end
        
    end
    
end
