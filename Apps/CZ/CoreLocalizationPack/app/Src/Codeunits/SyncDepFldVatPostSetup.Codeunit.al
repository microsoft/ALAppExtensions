#if not CLEAN17
#pragma warning disable AL0432,AL0603
codeunit 31173 "Sync.Dep.Fld-VatPostSetup CZL"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"VAT Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertVATPostingSetup(var Rec: Record "VAT Posting Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Posting Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyVATPostingSetup(var Rec: Record "VAT Posting Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "VAT Posting Setup")
    var
        PreviousRecord: Record "VAT Posting Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldInt, NewFieldInt : Integer;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldInt := Rec."VAT Rate";
        NewFieldInt := Rec."VAT Rate CZL".AsInteger();
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."VAT Rate", PreviousRecord."VAT Rate CZL".AsInteger());
        Rec."VAT Rate" := DepFieldInt;
        Rec."VAT Rate CZL" := NewFieldInt;
        DepFieldInt := Rec."Supplies Mode Code";
        NewFieldInt := Rec."Supplies Mode Code CZL".AsInteger();
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."Supplies Mode Code", PreviousRecord."Supplies Mode Code CZL".AsInteger());
        Rec."Supplies Mode Code" := DepFieldInt;
        Rec."Supplies Mode Code CZL" := NewFieldInt;
        SyncDepFldUtilities.SyncFields(Rec."Ratio Coefficient", Rec."Ratio Coefficient CZL", PreviousRecord."Ratio Coefficient", PreviousRecord."Ratio Coefficient CZL");
        DepFieldInt := Rec."Corrections for Bad Receivable";
        NewFieldInt := Rec."Corrections Bad Receivable CZL".AsInteger();
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."Corrections for Bad Receivable", PreviousRecord."Corrections Bad Receivable CZL".AsInteger());
        Rec."Corrections for Bad Receivable" := DepFieldInt;
        Rec."Corrections Bad Receivable CZL" := NewFieldInt;
        DepFieldTxt := Rec."Sales VAT Delay Account";
        NewFieldTxt := Rec."Sales VAT Curr. Exch. Acc CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Sales VAT Delay Account", PreviousRecord."Sales VAT Curr. Exch. Acc CZL");
        Rec."Sales VAT Delay Account" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Sales VAT Delay Account"));
        Rec."Sales VAT Curr. Exch. Acc CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Sales VAT Curr. Exch. Acc CZL"));
        DepFieldTxt := Rec."Purchase VAT Delay Account";
        NewFieldTxt := Rec."Purch. VAT Curr. Exch. Acc CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Purchase VAT Delay Account", PreviousRecord."Purch. VAT Curr. Exch. Acc CZL");
        Rec."Purchase VAT Delay Account" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Purchase VAT Delay Account"));
        Rec."Purch. VAT Curr. Exch. Acc CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Purch. VAT Curr. Exch. Acc CZL"));
        DepFieldInt := Rec."Reverse Charge Check";
        NewFieldInt := Rec."Reverse Charge Check CZL".AsInteger();
        SyncDepFldUtilities.SyncFields(DepFieldInt, NewFieldInt, PreviousRecord."Reverse Charge Check", PreviousRecord."Reverse Charge Check CZL".AsInteger());
        Rec."Reverse Charge Check" := DepFieldInt;
        Evaluate(Rec."Reverse Charge Check CZL", format(NewFieldInt));
        SyncDepFldUtilities.SyncFields(Rec."VIES Purchases", Rec."VIES Purchase CZL", PreviousRecord."VIES Purchases", PreviousRecord."VIES Purchase CZL");
        SyncDepFldUtilities.SyncFields(Rec."VIES Sales", Rec."VIES Sales CZL", PreviousRecord."VIES Sales", PreviousRecord."VIES Sales CZL");
        SyncDepFldUtilities.SyncFields(Rec."Intrastat Service", Rec."Intrastat Service CZL", PreviousRecord."Intrastat Service", PreviousRecord."Intrastat Service CZL");
    end;
}
#endif