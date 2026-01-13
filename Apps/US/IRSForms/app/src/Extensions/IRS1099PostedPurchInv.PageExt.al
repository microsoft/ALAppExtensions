// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.History;

pageextension 10055 "IRS 1099 Posted Purch. Inv." extends "Posted Purchase Invoice"
{
    layout
    {
        addafter(Control60)
        {
            field("IRS 1099 Reporting Period"; Rec."IRS 1099 Reporting Period")
            {
                ApplicationArea = BasicUS;
                Tooltip = 'Specifies the IRS reporting period for the document.';
            }
            field("IRS 1099 Form No."; Rec."IRS 1099 Form No.")
            {
                ApplicationArea = BasicUS;
                Tooltip = 'Specifies the IRS form number for the document.';
                Editable = false;
            }
            field("IRS 1099 Form Box No."; Rec."IRS 1099 Form Box No.")
            {
                ApplicationArea = BasicUS;
                Tooltip = 'Specifies the IRS form box number for the vendor ledger entry.';
                Editable = false;
            }
        }
    }
}