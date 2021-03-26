codeunit 2417 "XS Try Function Delete Cust."
{
    TableNo = Customer;

    trigger OnRun()
    begin
        Rec.Delete(true);
    end;
}