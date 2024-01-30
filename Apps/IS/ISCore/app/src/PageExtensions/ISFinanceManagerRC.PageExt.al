// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

using Microsoft.Finance.GeneralLedger.IRS;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.Finance;

pageextension 14605 "IS Finance Manager RC" extends "Finance Manager Role Center"
{
    actions
    {
        addafter("Day Book Vendor Ledger Entry")
        {
            action("IS VAT Reconciliation A")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VAT Reconciliation A';
                RunObject = report "IS VAT Reconciliation A";
            }
            action("IS VAT Reconciliation Report")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VAT Balancing Report';
                RunObject = report "IS VAT Balancing Report";
            }
        }

        addafter("Statement of Retained Earnings")
        {
            action("IRS Details Report")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'IRS Details Report';
                RunObject = report "IS IRS Details";
            }
            action("Trial Balance IRS Number")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Trial Balance - IRS Number';
                RunObject = report "IS Trial Balance - IRS Number";
            }
        }

        addafter("VAT Report Setup")
        {
            action("IS IRS Group")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'IRS Group';
                RunObject = page "IS IRS Groups";
            }
            action("IS IRS Type")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'IRS Type';
                RunObject = page "IS IRS Types";
            }
            action("IS IRS Number")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'IRS Number';
                RunObject = page "IS IRS Numbers";
            }
        }
    }
}
