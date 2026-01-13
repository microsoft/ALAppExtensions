// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Payables;
using Microsoft.Utilities;
using System.Environment.Configuration;
using System.Media;
using System.Telemetry;

codeunit 10016 "IRS 1096 Form Mgt."
{
    Permissions = TableData "IRS 1096 Form Header" = imd,
                  TableData "IRS 1096 Form Line" = imd;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ServDeclFormTok: Label 'Service Declaration', Locked = true;
        InstallIRS1096NotificationNameTxt: Label 'IRS 1096 Form - Install feature';
        InstallIRS1096NotificationDescriptionTxt: Label 'This notification is used to let users know about the new IRS 1096 feature . It can be used to open the Feature Management and install the 1096 feature.';
        NoEntriesToCreateFormsMsg: Label 'No entries have been found by filters specified.';
        FormsCreatedMsg: Label 'IRS 1096 forms have been created';
        AssistedSetupTxt: Label 'Set up an IRS 1096 feature';
        AssistedSetupDescriptionTxt: Label 'This feature provides functionality that enables an easy overview and reporting of the 1096 form to IRS.';
        AssistedSetupHelpTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2204541', Locked = true;
        OneOrMoreFormsNotReleasedErr: Label 'One or more forms within the period are not released. You can only print released forms. Open the form card and click Release to release the form.';
        NoFormsHaveBeenCreatedMsg: Label 'No IRS 1096 forms have been created';

    procedure IsFeatureEnabled() IsEnabled: Boolean
    begin
        IsEnabled := true;
        OnAfterCheckFeatureEnabled(IsEnabled);
    end;

    procedure ReleaseForm(var IRS1096FormHeader: Record "IRS 1096 Form Header")
    begin
        IRS1096FormHeader.TestField("Starting Date");
        IRS1096FormHeader.TestField("Ending Date");
        IRS1096FormHeader.TestField("IRS Code");
        IRS1096FormHeader.TestField("Total Number Of Forms");
        IRS1096FormHeader.TestField("Total Amount To Report");
        IRS1096FormHeader.Validate(Status, IRS1096FormHeader.Status::Released);
        IRS1096FormHeader.Modify(true);
    end;

    procedure ReopenForm(var IRS1096FormHeader: Record "IRS 1096 Form Header")
    begin
        IRS1096FormHeader.Validate(Status, IRS1096FormHeader.Status::Open);
        IRS1096FormHeader.Modify(true);
    end;

    procedure CreateForms(StartDate: Date; EndDate: Date; Replace: Boolean)
    var
        TempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary;
        TempIRS1096FormHeader: Record "IRS 1096 Form Header" temporary;
        TempCreatedIRS1096FormHeader: Record "IRS 1096 Form Header" temporary;
        IRS1096FormHeader: Record "IRS 1096 Form Header";
        IRS1096FormLine: Record "IRS 1096 Form Line";
        EntryApplicationManagement: Codeunit "Entry Application Management";
        PeriodDate: array[2] of Date;
    begin
        PeriodDate[1] := StartDate;
        PeriodDate[2] := EndDate;
        EntryApplicationManagement.GetAppliedVendorEntries(
          TempVendorLedgerEntry, '', PeriodDate, true);
        TempVendorLedgerEntry.SetFilter("Document Type", '%1|%2', TempVendorLedgerEntry."Document Type"::Invoice, TempVendorLedgerEntry."Document Type"::"Credit Memo");
        if not TempVendorLedgerEntry.FindSet() then begin
            Message(NoEntriesToCreateFormsMsg);
            exit;
        end;

        IRS1096FormHeader.SetRange("Starting Date", StartDate);
        IRS1096FormHeader.SetRange("Ending Date", EndDate);
        if IRS1096FormHeader.FindSet() then
            repeat
                TempIRS1096FormHeader := IRS1096FormHeader;
                TempIRS1096FormHeader.Insert();
            until IRS1096FormHeader.Next() = 0;

        IRS1096FormHeader.Reset();
        IRS1096FormHeader.LockTable();
        IRS1096FormLine.LockTable();
        repeat
        until TempVendorLedgerEntry.Next() = 0;
        if TempCreatedIRS1096FormHeader.IsEmpty() then begin
            if GuiAllowed() then
                Message(NoFormsHaveBeenCreatedMsg);
            exit;
        end;
        if GuiAllowed() then
            Message(FormsCreatedMsg);
    end;

    procedure PrintSingleForm(var IRS1096FormHeader: Record "IRS 1096 Form Header")
    var
        IRS1096FormHeaderToPrint: Record "IRS 1096 Form Header";
    begin
        IRS1096FormHeader.TestField(Status, IRS1096FormHeader.Status::Released);
        SetPrintingDetails(IRS1096FormHeader);
        IRS1096FormHeaderToPrint := IRS1096FormHeader;
        IRS1096FormHeaderToPrint.SetRecFilter();
        PrintForms(IRS1096FormHeaderToPrint);
    end;

    procedure PrintFormByPeriod(IRS1096FormHeader: Record "IRS 1096 Form Header")
    var
        IRS1096FormHeaderToPrint: Record "IRS 1096 Form Header";
    begin
        IRS1096FormHeaderToPrint.SetRange("Starting Date", IRS1096FormHeader."Starting Date");
        IRS1096FormHeaderToPrint.SetRange("Ending Date", IRS1096FormHeader."Ending Date");
        IRS1096FormHeaderToPrint.SetRange(Status, IRS1096FormHeaderToPrint.Status::Open);
        if not IRS1096FormHeaderToPrint.IsEmpty() then
            error(OneOrMoreFormsNotReleasedErr);

        IRS1096FormHeaderToPrint.SetRange(Status);
        IRS1096FormHeaderToPrint.FindSet();
        repeat
            SetPrintingDetails(IRS1096FormHeaderToPrint);
        until IRS1096FormHeaderToPrint.Next() = 0;
        PrintForms(IRS1096FormHeaderToPrint);
    end;

    local procedure PrintForms(var IRS1096FormHeader: Record "IRS 1096 Form Header")
    var
        IRS1096FormReport: Report "IRS 1096 Form";
    begin
        Commit();
        FeatureTelemetry.LogUptake('0000ISB', ServDeclFormTok, Enum::"Feature Uptake Status"::Used);
        IRS1096FormReport.SetTableView(IRS1096FormHeader);
        IRS1096FormReport.Run();
        FeatureTelemetry.LogUsage('0000ISC', ServDeclFormTok, 'File created');
    end;

    procedure DontShowAgainDisableAutomaticNotificationAction(var Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Disable(GetIRS1096FeatureNotificationId()) then
            MyNotifications.InsertDefault(GetIRS1096FeatureNotificationId(), InstallIRS1096NotificationNameTxt, InstallIRS1096NotificationDescriptionTxt, false);
    end;

    procedure ShowRelatedVendorsLedgerEntries(FormNo: Code[20]; FormLineNo: Integer)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary;
        IRS1096FormLineRelation: Record "IRS 1096 Form Line Relation";
    begin
        IRS1096FormLineRelation.SetRange("Form No.", FormNo);
        if FormLineNo <> 0 then
            IRS1096FormLineRelation.SetRange("Line No.", FormLineNo);
        if not IRS1096FormLineRelation.FindSet() then
            exit;

        repeat
            VendorLedgerEntry.Get(IRS1096FormLineRelation."Entry No.");
            TempVendorLedgerEntry := VendorLedgerEntry;
            TempVendorLedgerEntry.Insert();
        until IRS1096FormLineRelation.Next() = 0;
        Page.Run(0, TempVendorLedgerEntry);
    end;

    local procedure GetIRS1096FeatureNotificationId(): Guid
    begin
        exit('dd66a823-fe4b-4010-846d-77209a07ab33');
    end;

    local procedure SetPrintingDetails(var IRS1096FormHeader: Record "IRS 1096 Form Header")
    begin
        IRS1096FormHeader.Validate(Printed, true);
        IRS1096FormHeader.Validate("Printed By", UserId());
        IRS1096FormHeader.Validate("Printed Date-Time", CurrentDateTime());
        IRS1096FormHeader.Modify(true);
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure InsertIntoAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
    begin
        GuidedExperience.InsertAssistedSetup(AssistedSetupTxt, CopyStr(AssistedSetupTxt, 1, 50), AssistedSetupDescriptionTxt, 5, ObjectType::Page, Page::"IRS 1096 Setup Wizard", AssistedSetupGroup::FinancialReporting,
                                            '', VideoCategory::FinancialReporting, AssistedSetupHelpTxt);
    end;

#if not CLEAN27
    [Obsolete('This event is no longer used.', '27.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetGeneral1099CodeFromVendLedgEntry(VendLedgEntry: Record "Vendor Ledger Entry"; var IRSCode: Code[20]; var IsHandled: Boolean)
    begin
    end;
#endif
    [IntegrationEvent(true, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
    end;
}