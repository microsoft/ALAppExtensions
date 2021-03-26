codeunit 149115 "BCPT Open Vendor List"
{
    // Test codeunits can only run in foreground (UI)
    Subtype = Test;

    trigger OnRun();
    begin
    end;

    [Test]
    procedure OpenVendorList()
    var
        VendorList: testpage "Vendor List";
    begin
        VendorList.OpenView();
        VendorList.Close();
    end;
}