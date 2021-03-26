// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

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
                field(BOMItemNumber; BOMItemNumber) { ApplicationArea = All; }
                field(ItemNumber; ItemNumber) { ApplicationArea = All; }
                field(Qty; Qty)
                {
                    Caption = 'Quantity';
                    ApplicationArea = All;
                }
                field(Position; Position) { ApplicationArea = All; }
                field(LeadTime; LeadTime) { ApplicationArea = All; }
                field(Resource; Resource) { ApplicationArea = All; }
                field(InvenLocation; InvenLocation) { ApplicationArea = All; }
                field(Comment; Comment) { ApplicationArea = All; }
                field(PriceGroup; PriceGroup) { ApplicationArea = All; }
            }
        }
    }
}