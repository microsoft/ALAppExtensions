#if not CLEAN17
#pragma warning disable AL0432
codeunit 31125 "Sync.Dep.Fld-PaymentMethod CZP"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnAfterValidateEvent', 'Cash Desk Code', false, false)]
    local procedure SyncOnAfterValidateCashDeskCode(var Rec: Record "Payment Method")
    begin
        If Rec."Cash Desk Code" <> '' then begin
            Rec."Cash Desk Code CZP" := '';
            Rec."Cash Document Action CZP" := Rec."Cash Document Action CZP"::" ";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnAfterValidateEvent', 'Cash Desk Code CZP', false, false)]
    local procedure SyncOnAfterValidateCashDeskCodeCZP(var Rec: Record "Payment Method")
    begin
        If Rec."Cash Desk Code CZP" <> '' then begin
            Rec."Cash Desk Code" := '';
            Rec."Cash Document Status" := Rec."Cash Document Status"::" ";
        end;
    end;
}
#endif