codeunit 139700 "Run All Tests"
{
    trigger OnRun();

    var
        MigrationStatusMgmtTests: Codeunit "Migration Status Mgmt. Tests";
    begin
        MigrationStatusMgmtTests.Run();
    end;
}