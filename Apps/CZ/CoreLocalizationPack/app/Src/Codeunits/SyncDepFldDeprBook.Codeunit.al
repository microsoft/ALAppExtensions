#if not CLEAN18
#pragma warning disable AL0432
codeunit 31206 "Sync.Dep.Fld-DeprBook CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Depreciation Book", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertDepreciationBook(var Rec: Record "Depreciation Book")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Depreciation Book", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyDepreciationBook(var Rec: Record "Depreciation Book")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Depreciation Book")
    var
        PreviousRecord: Record "Depreciation Book";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."Mark Reclass. as Corrections", Rec."Mark Reclass. as Correct. CZL", PreviousRecord."Mark Reclass. as Corrections", PreviousRecord."Mark Reclass. as Correct. CZL");
    end;
}
#endif