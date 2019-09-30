Test Runner is used to run the automated tests.

There are two ways to run tests:
- In the UI, open the AL Test Tool page and manually run the tests.
- In the Console, which is suitable for running in CI/CD pipeline. To set this up you must use the ALTestRunner.psm1 file in this module.

Do mot modify or extend this module. In the future we will move test execution to a platform-based API.