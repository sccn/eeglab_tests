# What is EEGLAB_tests?

EEGLAB_tests is the repository on GitHub with tests to validate correct behavior of [EEGLAB](https://github.com/sccn/eeglab). This repository uses (or intents to use) concepts like MATLAB Projects, MATLAB Unit Testing, Git LFS, Git submodules and GitHub Actions to automate running tests on EEGLAB in the cloud. The concepts are further explained in this Readme.

# Installing/cloning

```
git clone --recurse-submodules https://github.com/sccn/eeglab_tests.git
```

If you forgot to clone the submodule, go to the eeglab folder and type

```
git submodule update --init --recursive --remote
git pull --recurse-submodules
```

## MATLAB Projects

MATLAB Projects is a project management tool inside MATLAB for managing MATLAB or Simulink Projects. For more information: <https://www.mathworks.com/solutions/projects.html> and <https://www.mathworks.com/help/matlab/projects.html>
Main benefits for EEGLAB_tests:

- Automate MATLAB path management when opening/closing Project
- Test specification, picked up by GitHub action for running tests
- Source Control Management actions from within MATLAB

For creating a MATLAB Project from an existing MATLAB codebase in a folder, on the **Home** tab, click **New** > **Project** > **From Folder**.

The MATLAB Project stores it settings and configurations in the resources folder in the repo.

## MATLAB Unit Testing

EEGLAB_tests includes many tests created before MATLAB Unit Testing was available. In order to re-use those tests, EEGLAB_tests includes *wrapperTest.m test functions that call the legacy test functions.

For more information on MATLAB Unit Testing: <https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html> and specifically on the function-based tests: <https://www.mathworks.com/help/matlab/matlab_prog/write-simple-test-case-with-functions.html>.

MATLAB Unit Testing can be extended with plugins, e.g. to perform code coverage analysis. The code coverage can be inspected from running tests from within MATLAB locally, but can also be calculated as part of the cloud-based tests. More information about Unit Test plugin, including Code Coverage:
<https://www.mathworks.com/help/matlab/matlab_prog/generate-artifacts-using-matlab-unit-test-plugins.html>

Example unit test in statcond -> statcondTest.m
## Git LFS

Since some tests require substantial data files to verify correct functionality, and Git is a source code management tool, not a data management tool, EEGLAB_tests uses Git LFS to store large files in GitHub LFS. For more information on using Git LFS with GitHub:
<https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-git-large-file-storage>

In order to work with Git LFS, you need to have Git LFS installed, for this, see:
<https://git-lfs.github.com>

Once Git LFS is installed and configured, you can use the typical `git commit`, `git add`, `git push`, `git pull`, etc. actions and Git LFS will make sure the large files that are configured in the repo are handled automatically through Git LFS.

## Git submodules

The reference from EEGLAB_tests to the EEGLAB repo with the actual EEGLAB code to be tested is using Git submodules. For more information: <https://git-scm.com/docs/gitsubmodules>

In .yml file, need to specify 'recursive' for 'submodules' for CI to pull the nested submodules (EEGLAB plugins) as well.

## GitHub Actions

To automate actions, or Continuous Integration automation steps directly from GitHub in the Cloud, GitHub provides GitHub Actions. For instance on each commit in a specified branch, all tests should run on a few MATLAB versions and a test report can show if all tests pass or if any would fail with details on why the test failed.

The following are useful actions for EEGLAB_tests:

- [actions/checkout@v2](https://github.com/actions/checkout)
  for checking out the repo (consider specifying submodules and lfs) on the test runner in the cloud
- [matlab-actions/setup-matlab@v1](https://github.com/matlab-actions/setup-matlab/)
  configure the MATLAB version to be used
- [matlab-actions/run-tests@v1](https://github.com/matlab-actions/run-tests)
  run a test suite in the configured MATLAB
- [codecov/codecov-action@v2](https://github.com/codecov/codecov-action)
  upload the coverage results that were generated from the testsuite to codecov.io
- [dorny/test-reporter@v1](https://github.com/dorny/test-reporter)
  display test pass/fail overview directly in GitHub Actions menu
- [actions/upload-artifact@v2](https://github.com/actions/upload-artifact)
  upload artifacts from running tests in cloud back to GitHub Project for inspection
 
