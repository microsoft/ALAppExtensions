// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Document;

pageextension 10059 "IRS 1099 Purch. Cr. Memo" extends "Purchase Credit Memo"
{
    layout
    {
        addafter("Invoice Details")
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
                Editable = NewFieldsAreEditable;
            }
            field("IRS 1099 Form Box No."; Rec."IRS 1099 Form Box No.")
            {
                ApplicationArea = BasicUS;
                Tooltip = 'Specifies the IRS form box number for the vendor ledger entry.';
                Editable = NewFieldsAreEditable;
            }
        }
    }

    var
        NewFieldsAreEditable: Boolean;

    trigger OnOpenPage()
    begin
        UpdateNewFieldsAreVisible();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateNewFieldsAreVisible();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateNewFieldsAreVisible();
    end;

    local procedure UpdateNewFieldsAreVisible()
    begin
        NewFieldsAreEditable := Rec."IRS 1099 Reporting Period" <> '';
    end;
}