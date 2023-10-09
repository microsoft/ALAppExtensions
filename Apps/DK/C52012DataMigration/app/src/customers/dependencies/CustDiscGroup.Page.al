// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

page 1883 "C5 CustDiscGroup"
{
    PageType = Card;
    SourceTable = "C5 CustDiscGroup";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Customer Discount Groups';
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
