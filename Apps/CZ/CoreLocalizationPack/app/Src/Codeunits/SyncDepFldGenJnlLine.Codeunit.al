#pragma warning disable AL0432
codeunit 31167 "Sync.Dep.Fld-GenJnlLine CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertGenJnlLine(var Rec: Record "Gen. Journal Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyGenJnlLine(var Rec: Record "Gen. Journal Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Gen. Journal Line")
    var
        PreviousRecord: Record "Gen. Journal Line";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldInt, NewFieldInt : Integer;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        SyncDepFldUtilities.SyncFields(Rec."VAT Date", Rec."VAT Date CZL", PreviousRecord."VAT Date", PreviousRecord."VAT Date CZL");
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
        SyncDepFldUtilities.SyncFields(Rec."EU 3-Party Intermediate Role", Rec."EU 3-Party Intermed. Role CZL", PreviousRecord."EU 3-Party Intermediate Role", PreviousRecord."EU 3-Party Intermed. Role CZL");
        SyncDepFldUtilities.SyncFields(Rec."Original Document VAT Date", Rec."Original Doc. VAT Date CZL", PreviousRecord."Original Document VAT Date", PreviousRecord."Original Doc. VAT Date CZL");
        DepFieldInt := Rec."Original Document Partner Type";
        NewFieldInt := Rec."Original Doc. Partner Type CZL";
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."Original Document Partner Type", PreviousRecord."Original Doc. Partner Type CZL");
        Rec."Original Document Partner Type" := DepFieldInt;
        Rec."Original Doc. Partner Type CZL" := NewFieldInt;
        DepFieldTxt := Rec."Original Document Partner No.";
        NewFieldTxt := Rec."Original Doc. Partner No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Original Document Partner No.", PreviousRecord."Original Doc. Partner No. CZL");
        Rec."Original Document Partner No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Original Document Partner No."));
        Rec."Original Doc. Partner No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Original Doc. Partner No. CZL"));
        SyncDepFldUtilities.SyncFields(Rec."Currency Factor VAT", Rec."VAT Currency Factor CZL", PreviousRecord."Currency Factor VAT", PreviousRecord."VAT Currency Factor CZL");
        DepFieldTxt := Rec."Currency Code VAT";
        NewFieldTxt := Rec."VAT Currency Code CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Currency Code VAT", PreviousRecord."VAT Currency Code CZL");
        Rec."Currency Code VAT" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Currency Code VAT"));
        Rec."VAT Currency Code CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."VAT Currency Code CZL"));
        SyncDepFldUtilities.SyncFields(Rec."VAT Delay", Rec."VAT Delay CZL", PreviousRecord."VAT Delay", PreviousRecord."VAT Delay CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'VAT Date', false, false)]
    local procedure SyncOnAfterValidateVatDate(var Rec: Record "Gen. Journal Line")
    begin
        Rec."VAT Date CZL" := Rec."VAT Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'VAT Date CZL', false, false)]
    local procedure SyncOnAfterValidateVatDateCZL(var Rec: Record "Gen. Journal Line")
    begin
        Rec."VAT Date" := Rec."VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Original Document VAT Date', false, false)]
    local procedure SyncOnAfterValidateOriginalDocumentVATDate(var Rec: Record "Gen. Journal Line")
    begin
        Rec."Original Doc. VAT Date CZL" := Rec."Original Document VAT Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Original Doc. VAT Date CZL', false, false)]
    local procedure SyncOnAfterValidateOriginalDocVATDateCZL(var Rec: Record "Gen. Journal Line")
    begin
        Rec."Original Document VAT Date" := Rec."Original Doc. VAT Date CZL";
    end;
}
