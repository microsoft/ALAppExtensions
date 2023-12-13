﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CRM.Contact;

pageextension 31223 "Contact List CZL" extends "Contact List"
{
    layout
    {
        addlast(Control1)
        {
            field("VAT Registration No."; Rec."VAT Registration No.")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the contact''s VAT registration number for contacts in EU countries/regions.';
            }
            field("Registration Number CZL"; Rec."Registration Number")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the registration number of contact.';
            }
#if not CLEAN23
            field("Registration No. CZL"; Rec."Registration No. CZL")
            {
                Caption = 'Registration No. (Obsolete)';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the registration number of contact.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '23.0';
                ObsoleteReason = 'Replaced by standard "Registration Number" field.';
            }
#endif
        }
    }
}
