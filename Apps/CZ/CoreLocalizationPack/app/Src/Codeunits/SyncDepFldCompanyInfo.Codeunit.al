#if not CLEAN19
#pragma warning disable AL0432
codeunit 31149 "Sync.Dep.Fld-CompanyInfo CZL"
{
    Permissions = tabledata "Company Information" = rimd,
                  tabledata "Statutory Reporting Setup CZL" = rimd;
    ObsoleteState = Pending;
    ObsoleteReason = 'This codeunit will be removed after removing feature from Base Application.';
    ObsoleteTag = '17.0';

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertCompanyInformation(var Rec: Record "Company Information")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyCompanyInformation(var Rec: Record "Company Information")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Company Information")
    var
        PreviousRecord: Record "Company Information";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Default Bank Account Code";
        NewFieldTxt := Rec."Default Bank Account Code CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Default Bank Account Code", PreviousRecord."Default Bank Account Code CZL");
        Rec."Default Bank Account Code" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Default Bank Account Code"));
        Rec."Default Bank Account Code CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Default Bank Account Code CZL"));
#if not CLEAN17
        SyncDepFldUtilities.SyncFields(Rec."Bank Account Format Check", Rec."Bank Account Format Check CZL", PreviousRecord."Bank Account Format Check", PreviousRecord."Bank Account Format Check CZL");
        DepFieldTxt := Rec."Tax Registration No.";
        NewFieldTxt := Rec."Tax Registration No. CZL";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Tax Registration No.", PreviousRecord."Tax Registration No. CZL");
        Rec."Tax Registration No." := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Tax Registration No."));
        Rec."Tax Registration No. CZL" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Tax Registration No. CZL"));
#endif
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncOnAfterInsertCompanyInformation(var Rec: Record "Company Information")
    begin
        SyncCompanyInformation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncOnAfterModifyCompanyInformation(var Rec: Record "Company Information")
    begin
        SyncCompanyInformation(Rec);
    end;

    local procedure SyncCompanyInformation(var Rec: Record "Company Information")
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        SyncLoopingHelper: Codeunit "Sync. Looping Helper";
    begin
        if IsFieldSynchronizationDisabled() then
            exit;
        if Rec.IsTemporary() then
            exit;
        if SyncLoopingHelper.IsFieldSynchronizationSkipped(Database::"Company Information") then
            exit;
        SyncLoopingHelper.SkipFieldSynchronization(SyncLoopingHelper, Database::"Statutory Reporting Setup CZL");
        StatutoryReportingSetupCZL.ChangeCompany(Rec.CurrentCompany);
        if not StatutoryReportingSetupCZL.Get() then begin
            StatutoryReportingSetupCZL.Init();
            StatutoryReportingSetupCZL.SystemId := Rec.SystemId;
            StatutoryReportingSetupCZL.Insert(false, true);
        end;
#if not CLEAN17
        StatutoryReportingSetupCZL."Primary Business Activity" := Rec."Primary Business Activity";
        StatutoryReportingSetupCZL."Court Authority No." := Rec."Court Authority No.";
        StatutoryReportingSetupCZL."Tax Authority No." := Rec."Tax Authority No.";
        StatutoryReportingSetupCZL."Registration Date" := Rec."Registration Date";
        StatutoryReportingSetupCZL."Equity Capital" := Rec."Equity Capital";
        StatutoryReportingSetupCZL."Paid Equity Capital" := Rec."Paid Equity Capital";
        StatutoryReportingSetupCZL."General Manager No." := Rec."General Manager No.";
        StatutoryReportingSetupCZL."Accounting Manager No." := Rec."Accounting Manager No.";
        StatutoryReportingSetupCZL."Finance Manager No." := Rec."Finance Manager No.";
        StatutoryReportingSetupCZL.Modify(false);
#endif
        SyncLoopingHelper.RestoreFieldSynchronization(Database::"Statutory Reporting Setup CZL");
    end;

    local procedure IsFieldSynchronizationDisabled(): Boolean
    var
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
    begin
        exit(SyncDepFldUtilities.IsFieldSynchronizationDisabled());
    end;
}
#endif