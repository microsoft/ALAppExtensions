codeunit 31410 "Posted Invt. Shpt.-Printed CZL"
{
    Permissions = TableData "Invt. Shipment Header" = rimd;
    TableNo = "Invt. Shipment Header";

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
    local procedure OnBeforeModify(var InvtShipmentHeader: Record "Invt. Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnRun(var InvtShipmentHeader: Record "Invt. Shipment Header"; var SuppressCommit: Boolean)
    begin
    end;
}

