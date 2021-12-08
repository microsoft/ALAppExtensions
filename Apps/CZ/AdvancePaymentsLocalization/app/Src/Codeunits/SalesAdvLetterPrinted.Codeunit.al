codeunit 31406 "Sales Adv. Letter-Printed CZZ"
{
    Permissions = TableData "Sales Adv. Letter Header CZZ" = rimd;
    TableNo = "Sales Adv. Letter Header CZZ";

    trigger OnRun()
    begin
        OnBeforeOnRun(Rec, SuppressCommit);
        Rec.Find();
        Rec."No. Printed" := Rec."No. Printed" + 1;
        OnBeforeModify(Rec);
        Rec.Modify();
        if not SuppressCommit then
            Commit();
    end;

    var
        SuppressCommit: Boolean;

    procedure SetSuppressCommit(NewSuppressCommit: Boolean)
    begin
        SuppressCommit := NewSuppressCommit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnRun(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SuppressCommit: Boolean)
    begin
    end;
}

