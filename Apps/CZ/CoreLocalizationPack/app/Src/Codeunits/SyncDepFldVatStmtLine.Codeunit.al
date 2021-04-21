#if not CLEAN17
#pragma warning disable AL0432
codeunit 31174 "Sync.Dep.Fld-VatStmtLine CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertVATStatementLine(var Rec: Record "VAT Statement Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Statement Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyVATStatementLine(var Rec: Record "VAT Statement Line")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "VAT Statement Line")
    var
        PreviousRecord: Record "VAT Statement Line";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
        DepFieldInt, NewFieldInt : Integer;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Attribute Code";
        NewFieldTxt := Rec."Attribute Code CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Attribute Code", PreviousRecord."Attribute Code CZL");
        Rec."Attribute Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Attribute Code"));
        Rec."Attribute Code CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Attribute Code CZL"));
        DepFieldInt := Rec."G/L Amount Type";
        NewFieldInt := Rec."G/L Amount Type CZL";
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."G/L Amount Type", PreviousRecord."G/L Amount Type CZL");
        Rec."G/L Amount Type" := DepFieldInt;
        Rec."G/L Amount Type CZL" := NewFieldInt;
        DepFieldTxt := Rec."Gen. Bus. Posting Group";
        NewFieldTxt := Rec."Gen. Bus. Posting Group CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Gen. Bus. Posting Group", PreviousRecord."Gen. Bus. Posting Group CZL");
        Rec."Gen. Bus. Posting Group" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Gen. Bus. Posting Group"));
        Rec."Gen. Bus. Posting Group CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Gen. Bus. Posting Group CZL"));
        DepFieldTxt := Rec."Gen. Prod. Posting Group";
        NewFieldTxt := Rec."Gen. Prod. Posting Group CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Gen. Prod. Posting Group", PreviousRecord."Gen. Prod. Posting Group CZL");
        Rec."Gen. Prod. Posting Group" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Gen. Prod. Posting Group"));
        Rec."Gen. Prod. Posting Group CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Gen. Prod. Posting Group CZL"));
        DepFieldInt := Rec.Show;
        NewFieldInt := Rec."Show CZL";
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord.Show, PreviousRecord."Show CZL");
        Rec.Show := DepFieldInt;
        Rec."Show CZL" := NewFieldInt;
        DepFieldInt := Rec."EU 3-Party Intermediate Role";
        NewFieldInt := Rec."EU 3-Party Intermed. Role CZL";
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."EU 3-Party Intermediate Role", PreviousRecord."EU 3-Party Intermed. Role CZL");
        Rec."EU 3-Party Intermediate Role" := DepFieldInt;
        Rec."EU 3-Party Intermed. Role CZL" := NewFieldInt;
        DepFieldInt := Rec."EU-3 Party Trade";
        NewFieldInt := Rec."EU-3 Party Trade CZL";
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."EU-3 Party Trade", PreviousRecord."EU-3 Party Trade CZL");
        Rec."EU-3 Party Trade" := DepFieldInt;
        Rec."EU-3 Party Trade CZL" := NewFieldInt;
        DepFieldTxt := Rec."VAT Control Rep. Section Code";
        NewFieldTxt := Rec."VAT Ctrl. Report Section CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."VAT Control Rep. Section Code", PreviousRecord."VAT Ctrl. Report Section CZL");
        Rec."VAT Control Rep. Section Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."VAT Control Rep. Section Code"));
        Rec."VAT Ctrl. Report Section CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."VAT Ctrl. Report Section CZL"));
        SyncDepFldUtilities.SyncFields(Rec."Ignore Simpl. Tax Doc. Limit", Rec."Ignore Simpl. Doc. Limit CZL", PreviousRecord."Ignore Simpl. Tax Doc. Limit", PreviousRecord."Ignore Simpl. Doc. Limit CZL");
    end;
}
#endif