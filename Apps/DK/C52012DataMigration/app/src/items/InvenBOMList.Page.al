// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

page 1898 "C5 InvenBOM List"
{
    PageType = List;
    SourceTable = "C5 InvenBOM";
    Caption = 'Bill of Materials';

    layout
    {
        area(content)
        {
            repeater(General)
            {
#pragma warning disable AA0218
                field(BOMItemNumber; Rec.BOMItemNumber) { ApplicationArea = All; }
                field(ItemNumber; Rec.ItemNumber) { ApplicationArea = All; }
                field(Qty; Rec.Qty)
                {
                    Caption = 'Quantity';
                    ApplicationArea = All;
                }
                field(Position; Rec.Position) { ApplicationArea = All; }
                field(LeadTime; Rec.LeadTime) { ApplicationArea = All; }
                field(Resource; Rec.Resource) { ApplicationArea = All; }
                field(InvenLocation; Rec.InvenLocation) { ApplicationArea = All; }
                field(Comment; Rec.Comment) { ApplicationArea = All; }
                field(PriceGroup; Rec.PriceGroup) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }
}
