// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Purchases.Payables;

pageextension 11768 "Vendor List CZL" extends "Vendor List"
{
    layout
    {
        addafter(Contact)
        {
            field("VAT Registration No."; Rec."VAT Registration No.")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the vendor''s VAT registration number for vendors in EU countries/regions.';
            }
            field("Registration Number CZL"; Rec."Registration Number")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the registration number of vendor.';
            }
#if not CLEAN23
            field("Registration No. CZL"; Rec."Registration No. CZL")
            {
                Caption = 'Registration No. (Obsolete)';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the registration number of vendor.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '23.0';
                ObsoleteReason = 'Replaced by standard "Registration Number" field.';
            }
#endif
        }
    }

    actions
    {
        addlast("Ven&dor")
        {
            action(UnreliabilityStatusCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Unreliability Status';
                Image = CustomerRating;
                ToolTip = 'View the VAT payer unreliable entries.';

                trigger OnAction()
                begin
                    Rec.ShowUnreliableEntriesCZL();
                end;
            }
        }
        addafter("Vendor - Detail Trial Balance")
        {
            action("Open Vend. Entries to Date CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open Vendor Entries to Date';
                Image = Report;
                RunObject = report "Open Vend. Entries to Date CZL";
                ToolTip = 'View, print, or send a report that shows Open Vendor Entries to Date';
            }
            action("All Payments on Hold CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'All Payments on Hold';
                Image = Report;
                RunObject = report "All Payments on Hold CZL";
                ToolTip = 'View a list of all vendor ledger entries on which the On Hold field is marked. ';
            }
        }
        addlast(reporting)
        {
            action("Balance Reconciliation CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Balance Reconciliation';
                Image = Balance;
                RunObject = report "Vendor-Bal. Reconciliation CZL";
                ToolTip = 'Open the report for vendor''s balance reconciliation.';
            }
        }
        addlast(Category_Report)
        {
            actionref("Balance Reconciliation CZL_Promoted"; "Balance Reconciliation CZL")
            {
            }
        }
    }
}
