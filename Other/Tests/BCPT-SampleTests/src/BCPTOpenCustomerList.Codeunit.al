codeunit 149110 "BCPT Open Customer List"
{
    // Test codeunits can only run in foreground (UI)
    Subtype = Test;

    trigger OnRun();
    begin
    end;

    [Test]
    procedure OpenCustomerList()
    var
        CustomerList: testpage "Customer List";
    begin
        CustomerList.OpenView();
        CustomerList.Close();
    end;
}