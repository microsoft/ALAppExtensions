// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

pageextension 11707 "Vendor Bank Account Card CZL" extends "Vendor Bank Account Card"
{
    layout
    {
        addlast(General)
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
