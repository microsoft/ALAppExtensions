// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10049 "IRS 1099 Form Doc Line Details"
{
    PageType = List;
    SourceTable = "IRS 1099 Form Doc. Line Detail";
    ApplicationArea = BasicUS;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Vendor Ledger Entry No."; Rec."Vendor Ledger Entry No.")
                {
                    Tooltip = 'Specifies the vendor ledger entry number.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    Tooltip = 'Specifies the document type of the vendor ledger entry.';
                }
                field("Document No."; Rec."Document No.")
                {
                    Tooltip = 'Specifies the document number of the vendor ledger entry.';
                }
                field(Description; Rec.Description)
                {
                    Tooltip = 'Specifies the description of the vendor ledger entry.';
                }
                field("IRS 1099 Reporting Amount"; Rec."IRS 1099 Reporting Amount")
                {
                    Tooltip = 'Specifies the amount for IRS 1099 reporting of the vendor ledger entry.';
                }
            }
        }
    }
}
