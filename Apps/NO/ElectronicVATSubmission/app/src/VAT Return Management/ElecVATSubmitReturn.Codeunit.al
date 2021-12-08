codeunit 10685 "Elec. VAT Submit Return"
{

    TableNo = "VAT Report Header";

    trigger OnRun()
    var
        ElecVATConnectionMgt: Codeunit "Elec. VAT Connection Mgt.";
    begin
        ElecVATConnectionMgt.SubmitVATReturn(Rec);
    end;
}