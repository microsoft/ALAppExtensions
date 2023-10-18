// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

page 1885 "C5 InvenDiscGroup"
{
    PageType = Card;
    SourceTable = "C5 InvenDiscGroup";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Inventory Discount';
    layout
    {
        area(content)
        {
            group(General)
            {
#pragma warning disable AA0218
                field(DiscGroup; Rec.DiscGroup) { ApplicationArea = All; }
                field(Comment; Rec.Comment) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }
}
