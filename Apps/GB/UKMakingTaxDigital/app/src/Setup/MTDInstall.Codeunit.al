// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 10539 "MTD Install"
{
    Subtype = Install;

    var
        VATReportLbl: Label 'HMRC MTD', Locked = true;
        NoSeriesCodeTxt: Label 'VATPERIODS', Locked = true;
        NoSeriesDescTxt: Label 'VAT Return Periods';
        VATReturnPeriodStartTxt: Label 'VATPER-0001', Locked = true;
        VATReturnPeriodEndTxt: Label 'VATPER-9999', Locked = true;

    trigger OnInstallAppPerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        OnCompanyInitialize();

        if InitializeDone() then
            exit;

        MoveTableMTDLiability();
        MoveTableMTDPayment();
        MoveTableMTDReturnDetails();

        UpgradeTag.SetAllUpgradeTags();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure OnCompanyInitialize()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        MTDOAuth20Mgt: Codeunit "MTD OAuth 2.0 Mgt";
        VATReportLabelText: Code[10];
    begin
        if not OAuth20Setup.Get(MTDOAuth20Mgt.GetOAuthPRODSetupCode()) then
            MTDOAuth20Mgt.InitOAuthSetup(OAuth20Setup, MTDOAuth20Mgt.GetOAuthPRODSetupCode());

        VATReportLabelText := CopyStr(VATReportLbl, 1, MaxStrLen(VATReportLabelText));
        InitVATReportsConfiguration(VATReportLabelText);

        InitVATReportSetup(VATReportLabelText);
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure InitializeDone(): boolean
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() <> Version.Create('0.0.0.0'));
    end;

    local procedure InitNoSeries() SeriesCode: Code[20]
    var
        NoSeries: Record "No. Series";
    begin
        SeriesCode := CopyStr(NoSeriesCodeTxt, 1, MaxStrLen(SeriesCode));
        if not NoSeries.Get(SeriesCode) then
            InsertSeries(
              SeriesCode, SeriesCode, CopyStr(NoSeriesDescTxt, 1, 30),
              CopyStr(VATReturnPeriodStartTxt, 1, 20), CopyStr(VATReturnPeriodEndTxt, 1, 20), '', '', 1, true);
    end;

    local procedure InitVATReportSetup(VATReportLabelText: Code[10])
    var
        VATReportSetup: Record "VAT Report Setup";
        IsModify: Boolean;
    begin
        with VATReportSetup do begin
            if not Get() then
                Insert();
            if ("VAT Return Period No. Series" = '') or ("Report Version" = '') then begin
                if "VAT Return Period No. Series" = '' then
                    "VAT Return Period No. Series" := InitNoSeries();
                "Report Version" := VATReportLabelText;
                "Update Period Job Frequency" := "Update Period Job Frequency"::Never;
                "Manual Receive Period CU ID" := Codeunit::"MTD Manual Receive Period";
                "Auto Receive Period CU ID" := Codeunit::"MTD Auto Receive Period";
                "Receive Submitted Return CU ID" := Codeunit::"MTD Receive Submitted";
                InitProductionMode(VATReportSetup);
                InitPeriodReminderCalculation(VATReportSetup);
                "MTD Disable FraudPrev. Headers" := false;
                Modify();
            end;
        end;
    end;

    local procedure InitVATReportsConfiguration(VATReportVersion: Code[10])
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        with VATReportsConfiguration do
            if not Get("VAT Report Type"::"VAT Return", VATReportVersion) then begin
                "VAT Report Type" := "VAT Report Type"::"VAT Return";
                "VAT Report Version" := VATReportVersion;

                "Suggest Lines Codeunit ID" := Codeunit::"VAT Report Suggest Lines";
                "Content Codeunit ID" := Codeunit::"MTD Create Return Content";
                "Submission Codeunit ID" := Codeunit::"MTD Submit Return";
                "Validate Codeunit ID" := Codeunit::"MTD Validate Return";
                Insert();
            end;
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        VATReportSetup: Record "VAT Report Setup";
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MTD Return Details");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"MTD Liability");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"MTD Payment");
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Report Setup", VATReportSetup.FieldNo("MTD OAuth Setup Option"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Report Setup", VATReportSetup.FieldNo("MTD Gov Test Scenario"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Report Setup", VATReportSetup.FieldNo("MTD Disable FraudPrev. Headers"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Report Setup", VATReportSetup.FieldNo("MTD FP WinClient Due DateTime"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Report Setup", VATReportSetup.FieldNo("MTD FP WebClient Due DateTime"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Report Setup", VATReportSetup.FieldNo("MTD FP Batch Due DateTime"));
        DataClassificationMgt.SetFieldToPersonal(Database::"VAT Report Setup", VATReportSetup.FieldNo("MTD FP WinClient Json"));
        DataClassificationMgt.SetFieldToPersonal(Database::"VAT Report Setup", VATReportSetup.FieldNo("MTD FP WebClient Json"));
        DataClassificationMgt.SetFieldToPersonal(Database::"VAT Report Setup", VATReportSetup.FieldNo("MTD FP Batch Json"));
    end;

    local procedure MoveTableMTDLiability();
    var
        MTDLiabilityNew: Record "MTD Liability";
        MTDLiabilityOld: Record "MTD-Liability";
    begin
        if MTDLiabilityOld.FindSet() then begin
            repeat
                MTDLiabilityNew.Init();
                MTDLiabilityNew.Validate("From Date", MTDLiabilityOld."From Date");
                MTDLiabilityNew.Validate("To Date", MTDLiabilityOld."To Date");
                MTDLiabilityNew.Validate(Type, MTDLiabilityOld.Type);
                MTDLiabilityNew.Validate("Original Amount", MTDLiabilityOld."Original Amount");
                MTDLiabilityNew.Validate("Outstanding Amount", MTDLiabilityOld."Outstanding Amount");
                MTDLiabilityNew.Validate("Due Date", MTDLiabilityOld."Due Date");
                MTDLiabilityNew.Insert(true);
            until MTDLiabilityOld.Next() = 0;

            MTDLiabilityOld.DeleteAll();
        end;
    end;

    local procedure MoveTableMTDPayment();
    var
        MTDPaymentNew: Record "MTD Payment";
        MTDPaymentOld: Record "MTD-Payment";
    begin
        if MTDPaymentOld.FindSet() then begin
            repeat
                MTDPaymentNew.Init();
                MTDPaymentNew.Validate("Start Date", MTDPaymentOld."Start Date");
                MTDPaymentNew.Validate("End Date", MTDPaymentOld."End Date");
                MTDPaymentNew.Validate("Entry No.", MTDPaymentOld."Entry No.");
                MTDPaymentNew.Validate("Received Date", MTDPaymentOld."Received Date");
                MTDPaymentNew.Validate(Amount, MTDPaymentOld.Amount);
                MTDPaymentNew.Insert(true);
            until MTDPaymentOld.Next() = 0;

            MTDPaymentOld.DeleteAll();
        end;
    end;

    local procedure MoveTableMTDReturnDetails();
    var
        MTDReturnDetailsNew: Record "MTD Return Details";
        MTDReturnDetailsOld: Record "MTD-Return Details";
    begin
        if MTDReturnDetailsOld.FindSet() then begin
            repeat
                MTDReturnDetailsNew.Init();
                MTDReturnDetailsNew.Validate("Start Date", MTDReturnDetailsOld."Start Date");
                MTDReturnDetailsNew.Validate("End Date", MTDReturnDetailsOld."End Date");
                MTDReturnDetailsNew.Validate("Period Key", MTDReturnDetailsOld."Period Key");
                MTDReturnDetailsNew.Validate("VAT Due Sales", MTDReturnDetailsOld."VAT Due Sales");
                MTDReturnDetailsNew.Validate("VAT Due Acquisitions", MTDReturnDetailsOld."VAT Due Acquisitions");
                MTDReturnDetailsNew.Validate("Total VAT Due", MTDReturnDetailsOld."Total VAT Due");
                MTDReturnDetailsNew.Validate("VAT Reclaimed Curr Period", MTDReturnDetailsOld."VAT Reclaimed Curr Period");
                MTDReturnDetailsNew.Validate("Net VAT Due", MTDReturnDetailsOld."Net VAT Due");
                MTDReturnDetailsNew.Validate("Total Value Sales Excl. VAT", MTDReturnDetailsOld."Total Value Sales Excl. VAT");
                MTDReturnDetailsNew.Validate("Total Value Purchases Excl.VAT", MTDReturnDetailsOld."Total Value Purchases Excl.VAT");
                MTDReturnDetailsNew.Validate("Total Value Goods Suppl. ExVAT", MTDReturnDetailsOld."Total Value Goods Suppl. ExVAT");
                MTDReturnDetailsNew.Validate("Total Acquisitions Excl. VAT", MTDReturnDetailsOld."Total Acquisitions Excl. VAT");
                MTDReturnDetailsNew.Validate(Finalised, MTDReturnDetailsOld.Finalised);
                MTDReturnDetailsNew.Insert(true);
            until MTDReturnDetailsOld.Next() = 0;

            MTDReturnDetailsOld.DeleteAll();
        end;
    end;

    local procedure InsertSeries(var SeriesCode: code[20]; Code: Code[20]; Description: Text[30]; StartingNo: Code[20]; EndingNo: Code[20]; LastNumberUsed: Code[20]; WarningNo: Code[20]; IncrementByNo: Integer; ManualNos: Boolean)
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeries.Init();
        NoSeries.Code := Code;
        NoSeries.Description := Description;
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := ManualNos;
        NoSeries.Insert();

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.VALIDATE("Starting No.", StartingNo);
        NoSeriesLine.VALIDATE("Ending No.", EndingNo);
        NoSeriesLine.VALIDATE("Last No. Used", LastNumberUsed);
        if WarningNo <> '' then
            NoSeriesLine.VALIDATE("Warning No.", WarningNo);
        NoSeriesLine.VALIDATE("Increment-by No.", IncrementByNo);
        NoSeriesLine.Insert(true);

        SeriesCode := Code;
    end;

    internal procedure InitProductionMode(var VATReportSetup: Record "VAT Report Setup"): Boolean
    begin
        with VATReportSetup do begin
            if "MTD OAuth Setup Option" = "MTD OAuth Setup Option"::Production then
                exit(false);

            "MTD OAuth Setup Option" := "MTD OAuth Setup Option"::Production;
            "MTD Gov Test Scenario" := '';
            exit(true);
        end;
    end;

    internal procedure InitPeriodReminderCalculation(var VATReportSetup: Record "VAT Report Setup"): Boolean
    var
        DateFormulaText: Text;
    begin
        with VATReportSetup do begin
            if IsPeriodReminderCalculation() or ("Period Reminder Time" = 0) then
                exit(false);

            DateFormulaText := StrSubstNo('<%1D>', "Period Reminder Time");
            Evaluate("Period Reminder Calculation", DateFormulaText);
            "Period Reminder Time" := 0;
            exit(true);
        end;
    end;
}
