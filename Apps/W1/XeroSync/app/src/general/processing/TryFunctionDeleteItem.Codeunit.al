codeunit 2416 "XS Try Function Delete Item"
{
    TableNo = Item;

    trigger OnRun()
    begin
        Rec.Delete(true);
    end;
}