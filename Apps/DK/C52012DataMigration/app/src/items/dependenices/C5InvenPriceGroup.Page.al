// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

page 1868 "C5 InvenPriceGroup"
{
    PageType = Card;
    SourceTable = "C5 InvenPriceGroup";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Inventory Price Groups';
    layout
    {
        area(content)
        {
            group(General)
            {
#pragma warning disable AA0218
                field(Group; Rec.Group) { ApplicationArea = All; }
                field(GroupName; Rec.GroupName) { ApplicationArea = All; }
                field(InclVat; Rec.InclVat) { ApplicationArea = All; }
                field(Roundoff1; Rec.Roundoff1) { ApplicationArea = All; }
                field(Roundoff10; Rec.Roundoff10) { ApplicationArea = All; }
                field(Roundoff100; Rec.Roundoff100) { ApplicationArea = All; }
                field(Roundoff1000; Rec.Roundoff1000) { ApplicationArea = All; }
                field(Roundoff1000Plus; Rec.Roundoff1000Plus) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }
}
