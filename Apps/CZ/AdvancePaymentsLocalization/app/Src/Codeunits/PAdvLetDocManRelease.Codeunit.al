codeunit 31461 "P.Adv.Let.Doc.Man.Release CZZ"
{
    TableNo = "Purch. Adv. Letter Header CZZ";

    trigger OnRun()
    var
        RelPurchAdvLetterDocCZZ: Codeunit "Rel. Purch.Adv.Letter Doc. CZZ";
    begin
        RelPurchAdvLetterDocCZZ.PerformManualRelease(Rec);
    end;
}