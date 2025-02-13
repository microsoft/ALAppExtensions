// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft;
using Microsoft.EServices.EDocument;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;
using System.Upgrade;

#pragma warning disable AL0432,AL0603
codeunit 31270 "Install Application CZC"
{
    Subtype = Install;
    Permissions = tabledata "Compensations Setup CZC" = im,
                      tabledata "Compensation Header CZC" = im,
                      tabledata "Compensation Line CZC" = im,
                      tabledata "Posted Compensation Header CZC" = im,
                      tabledata "Posted Compensation Line CZC" = im,
                      tabledata "Source Code" = i,
                      tabledata "Compens. Report Selections CZC" = i,
                      tabledata "Source Code Setup" = m,
                      tabledata "Cust. Ledger Entry" = m,
                      tabledata "Vendor Ledger Entry" = m,
                      tabledata "Gen. Journal Line" = m,
                      tabledata "Posted Gen. Journal Line" = m,
                      tabledata "Incoming Document" = m;

    var
        InstallApplicationsMgtCZL: Codeunit "Install Applications Mgt. CZL";
        AppInfo: ModuleInfo;

    trigger OnInstallAppPerCompany()
    begin
        if not InitializeDone() then begin
            BindSubscription(InstallApplicationsMgtCZL);
            CopyData();
            UnbindSubscription(InstallApplicationsMgtCZL);
        end;
        CompanyInitialize();
    end;

    local procedure InitializeDone(): boolean
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() <> Version.Create('0.0.0.0'));
    end;

    local procedure CopyData()
    begin
        CopySourceCodeSetup();
        MoveIncomingDocument();
        InitCompensationSourceCode();
    end;

    local procedure CopySourceCodeSetup();
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.SetLoadFields(Credit);
        if SourceCodeSetup.Get() then begin
            SourceCodeSetup."Compensation CZC" := SourceCodeSetup.Credit;
            SourceCodeSetup.Modify(false);
        end;
    end;

    local procedure MoveIncomingDocument()
    var
        IncomingDocument: Record "Incoming Document";
    begin
        IncomingDocument.SetRange("Document Type", 8);
        IncomingDocument.ModifyAll("Document Type", IncomingDocument."Document Type"::"Compensation CZC");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    var
        DataClassEvalHandlerCZC: Codeunit "Data Class. Eval. Handler CZC";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        InitCompensationsSetup();
        CreateCompensationSourceCode();
        InitCompensationReportSelections();

        DataClassEvalHandlerCZC.ApplyEvaluationClassificationsForPrivacy();
        UpgradeTag.SetAllUpgradeTags();
    end;

    local procedure CreateCompensationSourceCode()
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if not SourceCodeSetup.Get() then
            exit;
        if SourceCodeSetup."Compensation CZC" = '' then
            InitCompensationSourceCode();
    end;

    local procedure InitCompensationsSetup()
    var
        CompensationsSetupCZC: Record "Compensations Setup CZC";
    begin
        if CompensationsSetupCZC.Get() then
            exit;
        CompensationsSetupCZC.Init();
        CompensationsSetupCZC.Insert();
    end;

    local procedure InitCompensationSourceCode()
    var
        CompensationSourceCodeTxt: Label 'COMPENS', MaxLength = 10;
        CompensationSourceDescriptionTxt: Label 'Compensation Evidence', MaxLength = 100;
    begin
        InsertSourceCode(CompensationSourceCodeTxt, CompensationSourceDescriptionTxt);
        SetupSourceCode(CompensationSourceCodeTxt);
    end;

    local procedure InsertSourceCode(SourceCodeCode: Code[10]; SourceCodeDescription: Text[100])
    var
        SourceCode: Record "Source Code";
    begin
        if SourceCode.Get(SourceCodeCode) then
            exit;
        SourceCode.Init();
        SourceCode.Code := SourceCodeCode;
        SourceCode.Description := SourceCodeDescription;
        SourceCode.Insert();
    end;

    local procedure SetupSourceCode(SourceCodeCode: Code[10])
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if not SourceCodeSetup.Get() then
            exit;
        if SourceCodeSetup."Compensation CZC" = SourceCodeCode then
            exit;
        SourceCodeSetup."Compensation CZC" := SourceCodeCode;
        SourceCodeSetup.Modify();
    end;

    local procedure InitCompensationReportSelections()
    var
        ReportUsage: Enum "Compens. Report Sel. Usage CZC";
    begin
        InsertCompensationReportSelectionsCZC(ReportUsage::"Compensation", '1', Report::"Compensation CZC");
        InsertCompensationReportSelectionsCZC(ReportUsage::"Posted Compensation", '1', Report::"Posted Compensation CZC");
    end;

    local procedure InsertCompensationReportSelectionsCZC(ReportUsage: Enum "Compens. Report Sel. Usage CZC"; ReportSequence: Code[10];
                                                                           ReportID: Integer)
    var
        CompensReportSelectionsCZC: Record "Compens. Report Selections CZC";
    begin
        if CompensReportSelectionsCZC.Get(ReportUsage, ReportSequence) then
            exit;

        CompensReportSelectionsCZC.Init();
        CompensReportSelectionsCZC.Validate(Usage, ReportUsage);
        CompensReportSelectionsCZC.Validate(Sequence, ReportSequence);
        CompensReportSelectionsCZC.Validate("Report ID", ReportID);
        CompensReportSelectionsCZC.Insert();
    end;
}
