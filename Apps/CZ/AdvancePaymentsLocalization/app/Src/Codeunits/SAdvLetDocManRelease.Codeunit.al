codeunit 31459 "S.Adv.Let.Doc.Man.Release CZZ"
{
    TableNo = "Sales Adv. Letter Header CZZ";

    trigger OnRun()
    var
        RelSalesAdvLetterDocCZZ: Codeunit "Rel. Sales Adv.Letter Doc. CZZ";
    begin
        RelSalesAdvLetterDocCZZ.PerformManualRelease(Rec);
    end;
}