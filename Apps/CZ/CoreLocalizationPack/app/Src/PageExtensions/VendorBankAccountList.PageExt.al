// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

pageextension 11706 "Vendor Bank Account List CZL" extends "Vendor Bank Account List"
{
    layout
    {
        addlast(Control1)
        {
            field(PublicBankAccountCZL; Rec.IsPublicBankAccountCZL())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Public Bank Account';
                Editable = false;
                ToolTip = 'Specifies if the Vendor''s Bank Account is public.';
            }
            field(ThirdPartyBankAccountCZL; Rec."Third Party Bank Account CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Third Party Bank Account';
                ToolTip = 'Specifies if the account is third party bank account.';
            }
        }
    }
}
