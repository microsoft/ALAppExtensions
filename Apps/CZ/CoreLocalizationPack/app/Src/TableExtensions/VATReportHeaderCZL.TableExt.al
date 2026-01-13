// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Environment.Configuration;
using Microsoft.Finance.VAT.Ledger;
using System.Utilities;
using Microsoft.Utilities;

tableextension 31060 "VAT Report Header CZL" extends "VAT Report Header"
{
    fields
    {
        modify("VAT Report Version")
        {
            trigger OnAfterValidate()
            begin
                if GetVATReportsConfiguration() then begin
                    "Statement Template Name" := VATReportsConfiguration."VAT Statement Template";
                    "Statement Name" := VATReportsConfiguration."VAT Statement Name";
                end;
            end;
        }
        modify("VAT Report Type")
        {
            trigger OnAfterValidate()
            begin
                CheckOnlyStandardVATReportInPeriod(false);
            end;
        }
        modify("Period Type")
        {
            trigger OnAfterValidate()
            begin
                ValidatePeriod();
            end;
        }
        modify("Period Year")
        {
            trigger OnAfterValidate()
            begin
                ValidatePeriod();
            end;
        }
        modify("Period No.")
        {
            trigger OnAfterValidate()
            begin
                ValidatePeriod();
            end;
        }
        field(11700; "Round to Integer CZL"; Boolean)
        {
            Caption = 'Round to Integer';
            DataClassification = CustomerContent;
        }
        field(11701; "Rounding Direction CZL"; Option)
        {
            Caption = 'Rounding Direction';
            OptionCaption = 'Nearest,Down,Up';
            OptionMembers = Nearest,Down,Up;
            DataClassification = CustomerContent;
        }
    }

    trigger OnAfterInsert()
    begin
        CheckOnlyStandardVATReportInPeriod(false);
    end;

    trigger OnAfterDelete()
    begin
        UnlinkVATEntries();
    end;

    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
        OnlyStandardVATReportInPeriodNameTxt: Label 'The only standard VAT report in the period';
        OnlyStandardVATReportInPeriodDescriptionTxt: Label 'Warn if standard VAT report is not only one in the period.';
        StandardVATReportExistsErr: Label 'There is already exist a standard VAT report in the same period.';
        LinesExitQst: Label 'There are VAT Statement Report Lines. To continue all the lines will be deleted.\\Do you want to continue?';

    internal procedure GetMonth(): Integer
    begin
        exit(GetRequiredPeriodNo("Period Type"::Month));
    end;

    internal procedure GetQuarter(): Integer
    begin
        exit(GetRequiredPeriodNo("Period Type"::Quarter));
    end;

    local procedure GetRequiredPeriodNo(RequiredPeriodType: Option): Integer
    begin
        if "Period Type" = RequiredPeriodType then
            exit("Period No.");
        exit(0);
    end;

    local procedure GetVATReportsConfiguration(): Boolean
    begin
        if (VATReportsConfiguration."VAT Report Type" <> "VAT Report Config. Code") or
           (VATReportsConfiguration."VAT Report Version" <> "VAT Report Version")
        then
            exit(VATReportsConfiguration.Get("VAT Report Config. Code", "VAT Report Version"));
    end;

    internal procedure ConvertVATReportTypeToVATStmtDeclarationType(): Enum "VAT Stmt. Declaration Type CZL"
    begin
        case "VAT Report Type" of
            "VAT Report Type"::Standard:
                exit("VAT Stmt. Declaration Type CZL"::Recapitulative);
            "VAT Report Type"::Corrective:
                exit("VAT Stmt. Declaration Type CZL"::Corrective);
            "VAT Report Type"::Supplementary:
                exit("VAT Stmt. Declaration Type CZL"::Supplementary);
        end;
    end;

    local procedure ValidatePeriod()
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        CheckOnlyStandardVATReportInPeriod(false);
        if LinesExistCZL() then begin
            if not ConfirmManagement.GetResponseOrDefault(LinesExitQst, false) then
                Error('');
            RemoveLines();
        end;
    end;

    procedure LinesExistCZL(): Boolean
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        VATStatementReportLine.SetRange("VAT Report No.", "No.");
        VATStatementReportLine.SetRange("VAT Report Config. Code", Rec."VAT Report Config. Code");
        exit(not VATStatementReportLine.IsEmpty());
    end;

    internal procedure RemoveLines()
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        VATStatementReportLine.SetRange("VAT Report No.", "No.");
        VATStatementReportLine.SetRange("VAT Report Config. Code", "VAT Report Config. Code");
        VATStatementReportLine.DeleteAll(true);
    end;

    internal procedure CheckOnlyStandardVATReportInPeriod(ShowError: Boolean)
    begin
        if ("VAT Report Type" = "VAT Report Type"::Standard) and
           IsAnotherStandardVATReportInPeriod()
        then begin
            if ShowError then
                Error(StandardVATReportExistsErr);
            ShowOnlyStandardVATReportInPeriodNotification()
        end else
            if not ShowError then
                RecallOnlyStandardVATReportInPeriodNotification();
    end;

    internal procedure IsAnotherStandardVATReportInPeriod(): Boolean
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        VATReportHeader.SetRange("VAT Report Config. Code", "VAT Report Config. Code");
        VATReportHeader.SetFilter("No.", '<>%1', "No.");
        VATReportHeader.SetRange("VAT Report Type", "VAT Report Type"::Standard);
        VATReportHeader.SetFilter("Start Date", '<=%1', "Start Date");
        VATReportHeader.SetFilter("End Date", '>=%1', "End Date");
        exit(not VATReportHeader.IsEmpty());
    end;

    procedure SetOnlyStandardVATReportInPeriodNotificationDefaultStateCZL()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefault(GetOnlyStandardVATReportInPeriodNotificationIdCZL(),
          OnlyStandardVATReportInPeriodNameTxt, OnlyStandardVATReportInPeriodDescriptionTxt, true);
    end;

    procedure GetOnlyStandardVATReportInPeriodNotificationIdCZL(): Guid
    begin
        exit('d924f329-7d94-4e7b-813e-6c1c47e865e1');
    end;

    local procedure ShowOnlyStandardVATReportInPeriodNotification()
    var
        MyNotifications: Record "My Notifications";
        InstructionMgt: Codeunit "Instruction Mgt.";
        OnlyStandardVATReportInPeriodNotification: Notification;
    begin
        if not MyNotifications.IsEnabled(GetOnlyStandardVATReportInPeriodNotificationIdCZL()) then
            exit;
        InstructionMgt.CreateMissingMyNotificationsWithDefaultState(GetOnlyStandardVATReportInPeriodNotificationIdCZL());

        OnlyStandardVATReportInPeriodNotification.Id := GetOnlyStandardVATReportInPeriodNotificationIdCZL();
        OnlyStandardVATReportInPeriodNotification.Message := StandardVATReportExistsErr;
        OnlyStandardVATReportInPeriodNotification.Scope := NotificationScope::LocalScope;
        OnlyStandardVATReportInPeriodNotification.Send();
    end;

    local procedure RecallOnlyStandardVATReportInPeriodNotification()
    var
        MyNotifications: Record "My Notifications";
        OnlyStandardVATReportInPeriodNotification: Notification;
    begin
        if not MyNotifications.IsEnabled(GetOnlyStandardVATReportInPeriodNotificationIdCZL()) then
            exit;

        OnlyStandardVATReportInPeriodNotification.Id := GetOnlyStandardVATReportInPeriodNotificationIdCZL();
        OnlyStandardVATReportInPeriodNotification.Recall();
    end;

    internal procedure GetVATStmtCalcParameters() VATStmtCalcParameters: Record "VAT Stmt. Calc. Parameters CZL"
    begin
        VATStmtCalcParameters."Start Date" := "Start Date";
        VATStmtCalcParameters.SetEndDate("End Date");
        VATStmtCalcParameters."Selection" := VATStmtCalcParameters.Selection::"Open and Closed";
        VATStmtCalcParameters."Period Selection" := VATStmtCalcParameters."Period Selection"::"Within Period";
        VATStmtCalcParameters."Print in Integers" := "Round to Integer CZL";
        VATStmtCalcParameters."Use Amounts in Add. Currency" := "Amounts in Add. Rep. Currency";
        VATStmtCalcParameters.SetRoundingType("Rounding Direction CZL");
        VATStmtCalcParameters."VAT Report No. Filter" := "No.";
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"VAT Report Entry Link CZL", 'd', InherentPermissionsScope::Both)]
    internal procedure UnlinkVATEntries()
    var
        VATReportEntryLink: Record "VAT Report Entry Link CZL";
    begin
        VATReportEntryLink.SetRange("VAT Report No.", "No.");
        VATReportEntryLink.DeleteAll();
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"VAT Report Entry Link CZL", 'i', InherentPermissionsScope::Both)]
    internal procedure LinkVATEntries(var TempVATEntry: Record "VAT Entry" temporary)
    var
        VATReportEntryLinkCZL: Record "VAT Report Entry Link CZL";
    begin
        TempVATEntry.Reset();
        if TempVATEntry.FindSet() then
            repeat
                VATReportEntryLinkCZL.Init();
                VATReportEntryLinkCZL."VAT Report No." := "No.";
                VATReportEntryLinkCZL."VAT Entry No." := TempVATEntry."Entry No.";
                VATReportEntryLinkCZL.Insert();
            until TempVATEntry.Next() = 0;
    end;
}