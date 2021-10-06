#if not CLEAN19
#pragma warning disable AL0432, AL0603
codeunit 31163 "Sync.Dep.Fld-SalesSetup CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Sales & Receivables Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertSalesSetup(var Rec: Record "Sales & Receivables Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales & Receivables Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifySalesSetup(var Rec: Record "Sales & Receivables Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Sales & Receivables Setup")
    var
        PreviousRecord: Record "Sales & Receivables Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepField, NewFieldInt : Integer;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepField := Rec."Default VAT Date";
        NewFieldInt := Rec."Default VAT Date CZL".AsInteger();
        SyncDepFldUtilities.SyncFields(DepField, NewFieldInt, PreviousRecord."Default VAT Date", PreviousRecord."Default VAT Date CZL".AsInteger());
        Rec."Default VAT Date" := DepField;
        Rec."Default VAT Date CZL" := NewFieldInt;
#if not CLEAN18
        SyncDepFldUtilities.SyncFields(Rec."Allow Alter Posting Groups", Rec."Allow Alter Posting Groups CZL", PreviousRecord."Allow Alter Posting Groups", PreviousRecord."Allow Alter Posting Groups CZL");
#endif        
    end;
}
#endif