// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;

pageextension 11294 "SE Company Information" extends "Company Information"
{
    layout
    {
        addafter("Registration No.")
        {
            field("Registered Office Info"; Rec."Registered Office Info")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the company''s Registered Office.';
            }
        }

        addafter("Giro No.")
        {
            field("Plus Giro Number"; Rec."Plus Giro Number")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Plus Giro number used by the postal office for your Plus Giro account.';
            }
        }

        modify("EORI Number")
        {
            Visible = true;
        }
    }
}
