permissionset 130450 "Test Runner - Exec"
{
    Assignable = true;
    Permissions =
        table "AL Test Suite" = X,
        table "Test Method Line" = X,
        table "AL Code Coverage Map" = X,
        tabledata "AL Test Suite" = rmid,
        tabledata "Test Method Line" = rmid,
        tabledata "Test Code Coverage Result" = rmid,
        tabledata "AL Code Coverage Map" = rmid,
        codeunit "ALTestRunner Reset Environment" = X,
        codeunit "Test Profile Management" = X,
        codeunit "Test Runner - Get Methods" = X,
        codeunit "Test Runner - Isol. Codeunit" = X,
        codeunit "Test Runner - Isol. Disabled" = X,
        codeunit "Test Runner - Mgt" = X,
        codeunit "Test Runner - Progress Dialog" = X,
        codeunit "Test Suite Mgt." = X,
        codeunit "AL Code Coverage Mgt." = X,
        codeunit "AL Code Coverage Subscribers" = X,
        xmlport "AL Code Coverage Map" = X,
        xmlport "Code Coverage Detailed" = X,
        xmlport "Code Coverage Results" = X,
        page "AL Test Tool" = X,
        page "AL Test Suites" = X,
        page "AL Code Coverage" = X,
        page "Command Line Test Tool" = X,
        page "Select TestRunner" = X,
        page "Select Tests By Range" = X,
        page "Select Tests" = X,
        page "Test Role Center" = X;
}