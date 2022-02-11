codeunit 31409 "Posted Invt. Rcpt.-Printed CZL"
{
    Permissions = TableData "Invt. Receipt Header" = rimd;
    TableNo = "Invt. Receipt Header";

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
    local procedure OnBeforeModify(var InvtReceiptHeader: Record "Invt. Receipt Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnRun(var InvtReceiptHeader: Record "Invt. Receipt Header"; var SuppressCommit: Boolean)
    begin
    end;
}

