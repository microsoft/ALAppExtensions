codeunit 149109 "BCPT Open Chart of Accounts"
{
    // Test codeunits can only run in foreground (UI)
    Subtype = Test;

    trigger OnRun();
    begin
    end;

    [Test]
    procedure OpenChartAccount()
    var
        ChartAccount: testpage "Chart of Accounts";
    begin
        ChartAccount.OpenView();
        ChartAccount.Close();
    end;
}