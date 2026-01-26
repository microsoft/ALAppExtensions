// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.eServices;

page 5296 "EService Demo Data Setup"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'EService Demo Data Setup';
    SourceTable = "EService Demo Data Setup";
    Extensible = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(InvoiceFileName; Rec."Invoice Field Name")
                {
                }
            }
        }
    }
}
