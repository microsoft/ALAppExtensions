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
#if not CLEAN25
#pragma warning disable AL0432
        modify("IRS 1099 Code")
        {
            Visible = not IsNewFeatureEnabled;
        }
#pragma warning restore AL0432
#endif
        addafter("Invoice Details")
        {
            field("IRS 1099 Reporting Period"; Rec."IRS 1099 Reporting Period")
            {
                ApplicationArea = BasicUS;
                Tooltip = 'Specifies the IRS reporting period for the document.';
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
#endif
            }
            field("IRS 1099 Form No."; Rec."IRS 1099 Form No.")
            {
                ApplicationArea = BasicUS;
                Tooltip = 'Specifies the IRS form number for the document.';
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
                Editable = NewFieldsAreEditable;
#endif
            }
            field("IRS 1099 Form Box No."; Rec."IRS 1099 Form Box No.")
            {
                ApplicationArea = BasicUS;
                Tooltip = 'Specifies the IRS form box number for the vendor ledger entry.';
#if not CLEAN25
                Visible = IsNewFeatureEnabled;
                Editable = NewFieldsAreEditable;
#endif
            }
        }
    }

#if not CLEAN25
    var
        IsNewFeatureEnabled: Boolean;
        NewFieldsAreEditable: Boolean;
#endif

#if not CLEAN25
    trigger OnOpenPage()
    var
        IRSFormsFeature: Codeunit "IRS Forms Feature";
    begin
        IsNewFeatureEnabled := IRSFormsFeature.IsEnabled();
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
        NewFieldsAreEditable := IsNewFeatureEnabled and (Rec."IRS 1099 Reporting Period" <> '');
    end;
#endif
}
