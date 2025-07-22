// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Main Contact Factbox (ID 30158).
/// </summary>
page 30158 "Shpfy Main Contact Factbox"
{
    Caption = 'Shopify Main Contact';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "Shpfy Customer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = All;
                    Caption = 'First Name';
                    ToolTip = 'Specifies the first name of the customer.';
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = All;
                    Caption = 'Last Name';
                    ToolTip = 'Specifies the last name of the customer.';
                }
            }
        }
    }
}