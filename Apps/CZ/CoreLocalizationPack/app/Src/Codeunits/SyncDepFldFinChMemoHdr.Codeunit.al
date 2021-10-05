#if not CLEAN18
#pragma warning disable AL0432
codeunit 31182 "Sync.Dep.Fld-FinChMemoHdr CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '18.0';

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertFinChargeMemoHeader(var Rec: Record "Finance Charge Memo Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyFinChargeMemoHeader(var Rec: Record "Finance Charge Memo Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Finance Charge Memo Header")
    var
        PreviousRecord: Record "Finance Charge Memo Header";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Specific Symbol";
        NewFieldTxt := Rec."Specific Symbol CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Specific Symbol", PreviousRecord."Specific Symbol CZL");
        Rec."Specific Symbol" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Specific Symbol"));
        Rec."Specific Symbol CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Specific Symbol CZL"));
        DepFieldTxt := Rec."Variable Symbol";
        NewFieldTxt := Rec."Variable Symbol CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Variable Symbol", PreviousRecord."Variable Symbol CZL");
        Rec."Variable Symbol" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Variable Symbol"));
        Rec."Variable Symbol CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Variable Symbol CZL"));
        DepFieldTxt := Rec."Constant Symbol";
        NewFieldTxt := Rec."Constant Symbol CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Constant Symbol", PreviousRecord."Constant Symbol CZL");
        Rec."Constant Symbol" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Constant Symbol"));
        Rec."Constant Symbol CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Constant Symbol CZL"));
        DepFieldTxt := Rec."Bank No.";
        NewFieldTxt := Rec."Bank Account Code CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Bank No.", PreviousRecord."Bank Account Code CZL");
        Rec."Bank No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Bank No."));
        Rec."Bank Account Code CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Bank Account Code CZL"));
        DepFieldTxt := Rec."Bank Account No.";
        NewFieldTxt := Rec."Bank Account No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Bank Account No.", PreviousRecord."Bank Account No. CZL");
        Rec."Bank Account No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Bank Account No."));
        Rec."Bank Account No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Bank Account No. CZL"));
        DepFieldTxt := Rec."Bank Branch No.";
        NewFieldTxt := Rec."Bank Branch No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Bank Branch No.", PreviousRecord."Bank Branch No. CZL");
        Rec."Bank Branch No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Bank Branch No."));
        Rec."Bank Branch No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Bank Branch No. CZL"));
        DepFieldTxt := Rec."Bank Name";
        NewFieldTxt := Rec."Bank Name CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Bank Name", PreviousRecord."Bank Name CZL");
        Rec."Bank Name" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Bank Name"));
        Rec."Bank Name CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Bank Name CZL"));
        DepFieldTxt := Rec."Transit No.";
        NewFieldTxt := Rec."Transit No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Transit No.", PreviousRecord."Transit No. CZL");
        Rec."Transit No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Transit No."));
        Rec."Transit No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Transit No. CZL"));
        DepFieldTxt := Rec.IBAN;
        NewFieldTxt := Rec."IBAN CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord.IBAN, PreviousRecord."IBAN CZL");
        Rec.IBAN := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec.IBAN));
        Rec."IBAN CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."IBAN CZL"));
        DepFieldTxt := Rec."SWIFT Code";
        NewFieldTxt := Rec."SWIFT Code CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."SWIFT Code", PreviousRecord."SWIFT Code CZL");
        Rec."SWIFT Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."SWIFT Code"));
        Rec."SWIFT Code CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."SWIFT Code CZL"));
#if not CLEAN17
        DepFieldTxt := Rec."Registration No.";
        NewFieldTxt := Rec."Registration No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Registration No.", PreviousRecord."Registration No. CZL");
        Rec."Registration No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Registration No."));
        Rec."Registration No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Registration No. CZL"));
        DepFieldTxt := Rec."Tax Registration No.";
        NewFieldTxt := Rec."Tax Registration No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Tax Registration No.", PreviousRecord."Tax Registration No. CZL");
        Rec."Tax Registration No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Tax Registration No."));
        Rec."Tax Registration No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Tax Registration No. CZL"));
#endif
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnAfterValidateEvent', 'Bank No.', false, false)]
    local procedure SyncOnAfterValidateBankNo(var Rec: Record "Finance Charge Memo Header")
    var
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Finance Charge Memo Header", Rec.FieldNo("Bank No.")) then
            exit;

        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Finance Charge Memo Header", Rec.FieldNo("Bank Account Code CZL"));
        Rec.Validate("Bank Account Code CZL", Rec."Bank No.");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Finance Charge Memo Header", Rec.FieldNo("Bank Account Code CZL"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnAfterValidateEvent', 'Bank Account Code CZL', false, false)]
    local procedure SyncOnAfterValidateBankAccountCodeCZL(var Rec: Record "Finance Charge Memo Header")
    var
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Finance Charge Memo Header", Rec.FieldNo("Bank Account Code CZL")) then
            exit;

        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Finance Charge Memo Header", Rec.FieldNo("Bank No."));
        Rec.Validate("Bank No.", Rec."Bank Account Code CZL");
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Finance Charge Memo Header", Rec.FieldNo("Bank No."));
    end;
}
#endif