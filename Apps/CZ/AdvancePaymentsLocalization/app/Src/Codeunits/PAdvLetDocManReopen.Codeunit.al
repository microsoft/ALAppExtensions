codeunit 31462 "P.Adv.Let.Doc.Man.Reopen CZZ"
{
    TableNo = "Purch. Adv. Letter Header CZZ";

    trigger OnRun()
    var
        RelPurchAdvLetterDocCZZ: Codeunit "Rel. Purch.Adv.Letter Doc. CZZ";
    begin
        RelPurchAdvLetterDocCZZ.PerformManualReopen(Rec);
    end;
}