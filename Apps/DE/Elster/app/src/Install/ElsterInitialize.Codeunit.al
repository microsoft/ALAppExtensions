// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 11021 "Elster - Initialize"
{
    Subtype = Install;

    var
        XVATADVANCENOTIFICATIONTxt: Label 'VAT Advance Notification';

    trigger OnInstallAppPerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not InitializeDone() then
            exit;

        CompanyInitialize();
        UpgradeTag.SetAllUpgradeTags();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        UpdateElecVATDeclSetupSalesVATAdvNotifNos();
        UpdateVATStatementName();
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure InitializeDone(): Boolean
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() = Version.Create('0.0.0.0'));
    end;

    local procedure UpdateElecVATDeclSetupSalesVATAdvNotifNos()
    var
        ElecVATDeclSetup: Record "Elec. VAT Decl. Setup";
    begin
        CreateNoSeries('VATNOTIF', XVATADVANCENOTIFICATIONTxt, 'VAT0001', 'VAT9999', '', 1);
        if ElecVATDeclSetup.Get() then
            exit;
        ElecVATDeclSetup.Init();
        ElecVATDeclSetup.Validate("Sales VAT Adv. Notif. Nos.", 'VATNOTIF');
        ElecVATDeclSetup.Insert(true);
    end;

    local procedure CreateNoSeries(Code: Code[20]; Description: Text; StartingNo: Code[20]; EndingNo: Code[20]; LastNoUsed: Code[20]; IncrementbyNo: Integer)
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSeries.Get(Code) then
            exit;
        NoSeries.Init();
        NoSeries.Code := Code;
        NoSeries.Description := CopyStr(Description, 1, MaxStrLen(NoSeries.Description));
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := true;
        NoSeries.Insert();

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.Validate("Starting No.", StartingNo);
        NoSeriesLine.Validate("Ending No.", EndingNo);
        NoSeriesLine.Validate("Last No. Used", LastNoUsed);
        NoSeriesLine.Validate("Increment-by No.", IncrementbyNo);
        NoSeriesLine.Insert(true);
    end;

    local procedure UpdateVATStatementName()
    var
        VATStatementName: Record "VAT Statement Name";
    begin
        if not VATStatementName.IsEmpty() then
            VATStatementName.ModifyAll("Sales VAT Adv. Notif.", true);
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        DataClassificationEvalData: Codeunit "Data Classification Eval. Data";
    begin
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"Sales VAT Advance Notif.");
    end;
}