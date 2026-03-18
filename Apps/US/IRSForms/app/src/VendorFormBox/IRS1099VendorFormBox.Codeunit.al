// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;

codeunit 10037 "IRS 1099 Vendor Form Box"
{
    Access = Internal;
    Permissions = TableData "Purch. Cr. Memo Hdr." = rm, tabledata "Purch. Inv. Header" = rm;

    procedure SuggestVendorsForFormBoxSetup(PeriodNo: Code[20])
    var
        IRS1099SuggestVendorsReport: Report "IRS 1099 Suggest Vendors";
    begin
        IRS1099SuggestVendorsReport.InitializeRequest(PeriodNo);
        IRS1099SuggestVendorsReport.Run();
    end;

    procedure PropagateVendorFormBoxSetupToExistingEntries(IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup")
    var
        IRS1099PropagateVendorSetup: Report "IRS 1099 Propagate Vend. Setup";
    begin
        IRS1099VendorFormBoxSetup.SetRecFilter();
        IRS1099PropagateVendorSetup.SetTableView(IRS1099VendorFormBoxSetup);
        IRS1099PropagateVendorSetup.Run();
    end;

    procedure PropagateVendorsFormBoxSetupToExistingEntries(var IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup")
    var
        IRS1099PropagateVendorSetup: Report "IRS 1099 Propagate Vend. Setup";
    begin
        IRS1099PropagateVendorSetup.SetTableView(IRS1099VendorFormBoxSetup);
        IRS1099PropagateVendorSetup.Run();
    end;

    /// <summary>
    /// Gets the IRS 1099 setup for a vendor as of the current work date.
    /// </summary>
    procedure GetVendorIRS1099FormBoxSetupAsOfWorkdate(var IRSReportingPeriodNo: Code[20]; var IRS1099FormNo: Code[20]; var IRS1099FormBox: Code[20]; VendNo: Code[20])
    var
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
    begin
        Clear(IRSReportingPeriodNo);
        Clear(IRS1099FormNo);
        Clear(IRS1099FormBox);
        if not GetVendorIRS1099FormBoxSetupAsOfWorkdate(IRS1099VendorFormBoxSetup, VendNo) then
            exit;
        IRSReportingPeriodNo := IRS1099VendorFormBoxSetup."Period No.";
        IRS1099FormNo := IRS1099VendorFormBoxSetup."Form No.";
        IRS1099FormBox := IRS1099VendorFormBoxSetup."Form Box No.";
    end;

    /// <summary>
    /// Shows the IRS 1099 setup for a vendor as of the current work date.
    /// </summary>
    procedure ShowVendor1099FormBoxSetupAsOfWorkDate(VendNo: Code[20])
    var
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
    begin
        if not GetVendorIRS1099FormBoxSetupAsOfWorkdate(IRS1099VendorFormBoxSetup, VendNo) then
            exit;
        Page.Run(0, IRS1099VendorFormBoxSetup);
    end;

    /// <summary>
    /// Shows a notification if the vendor has a 1099 code in the previous period but not in the current period.
    /// </summary>
    procedure ShowNotificationIfVendorHas1099CodePrevPeriodButNotCurr(VendNo: Code[20]; PostingDate: Date)
    var
        IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup";
        Notification: Notification;
        RunIRS1099VendorFormBoxSetupQst: Label 'You have a 1099 code for this vendor in the previous reporting period but not in the current one. Do you want to open the vendor setup to handle current one?';
        OpenIRS1099VendorFormBoxSetupPageLbl: Label 'Open IRS 1099 Vendor Form Box Setup';
    begin
        if VendNo = '' then
            exit;
        if PostingDate = 0D then
            exit;
        if GetVendorIRS1099FormBoxSetupAsOfDate(IRS1099VendorFormBoxSetup, VendNo, PostingDate) then
            exit;
        PostingDate := CalcDate('<-1Y>', PostingDate);
        if not GetVendorIRS1099FormBoxSetupAsOfDate(IRS1099VendorFormBoxSetup, VendNo, PostingDate) then
            exit;
        Notification.Id := ShowIfVendorHas1099CodePrevPeriodButNotCurrNotificationId();
        if Notification.Recall() then;
        Notification.Message := RunIRS1099VendorFormBoxSetupQst;
        Notification.Scope(NotificationScope::LocalScope);
        Notification.AddAction(OpenIRS1099VendorFormBoxSetupPageLbl, Codeunit::"IRS 1099 Vendor Form Box", 'OpenIRS1099VendorFormBoxFromNotification');
        Notification.Send();
    end;

    /// <summary>
    /// Opens the IRS 1099 Vendor Form Box Setup page from a notification action.
    /// </summary>
    procedure OpenIRS1099VendorFormBoxFromNotification(Notification: Notification)
    var
        IRS1099VendorFormBoxSetupPage: Page "IRS 1099 Vendor Form Box Setup";
    begin
        IRS1099VendorFormBoxSetupPage.Run();
    end;

    local procedure GetVendorIRS1099FormBoxSetupAsOfWorkdate(var IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup"; VendNo: Code[20]): Boolean
    begin
        exit(GetVendorIRS1099FormBoxSetupAsOfDate(IRS1099VendorFormBoxSetup, VendNo, WorkDate()));
    end;

    local procedure GetVendorIRS1099FormBoxSetupAsOfDate(var IRS1099VendorFormBoxSetup: Record "IRS 1099 Vendor Form Box Setup"; VendNo: Code[20]; EntryDate: Date): Boolean
    var
        IRSReportingPeriod: Codeunit "IRS Reporting Period";
        CurrIRSReportingPeriodNo: Code[20];
    begin
        Clear(IRS1099VendorFormBoxSetup);
        CurrIRSReportingPeriodNo := IRSReportingPeriod.GetReportingPeriod(EntryDate);
        if CurrIRSReportingPeriodNo = '' then
            exit(false);
        exit(IRS1099VendorFormBoxSetup.Get(CurrIRSReportingPeriodNo, VendNo));
    end;

    procedure UpdatePurchDocFormBoxNoFromVendLedgEntry(VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        if VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Invoice then begin
            PurchInvHeader.SetLoadFields("IRS 1099 Form Box No.");
            if PurchInvHeader.Get(VendorLedgerEntry."Document No.") then begin
                PurchInvHeader."IRS 1099 Form Box No." := VendorLedgerEntry."IRS 1099 Form Box No.";
                PurchInvHeader.Modify(true);
            end;
        end;
        if VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::"Credit Memo" then begin
            PurchCrMemoHdr.SetLoadFields("IRS 1099 Form Box No.");
            if PurchCrMemoHdr.Get(VendorLedgerEntry."Document No.") then begin
                PurchCrMemoHdr."IRS 1099 Form Box No." := VendorLedgerEntry."IRS 1099 Form Box No.";
                PurchCrMemoHdr.Modify(true);
            end;
        end;
    end;

    local procedure ShowIfVendorHas1099CodePrevPeriodButNotCurrNotificationId(): Guid
    begin
        exit('4b87dd95-f7ba-4e72-909b-76ca6a1d8b6a');
    end;
}
