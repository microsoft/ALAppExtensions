codeunit 31460 "S.Adv.Let.Doc.Man.Reopen CZZ"
{
    TableNo = "Sales Adv. Letter Header CZZ";

    trigger OnRun()
    var
        RelSalesAdvLetterDocCZZ: Codeunit "Rel. Sales Adv.Letter Doc. CZZ";
    begin
        RelSalesAdvLetterDocCZZ.PerformManualReopen(Rec);
    end;
}