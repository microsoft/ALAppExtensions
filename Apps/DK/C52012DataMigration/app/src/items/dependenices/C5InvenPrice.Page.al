// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

page 1888 "C5 InvenPrice"
{
    PageType = Card;
    SourceTable = "C5 InvenPrice";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Inventory Prices';
    layout
    {
        area(content)
        {
            group(General)
            {
#pragma warning disable AA0218
                field(ItemNumber; Rec.ItemNumber) { ApplicationArea = All; }
                field(Price; Rec.Price) { ApplicationArea = All; }
                field(PriceUnit; Rec.PriceUnit) { ApplicationArea = All; }
                field(Currency; Rec.Currency) { ApplicationArea = All; }
                field(PriceGroup; Rec.PriceGroup) { ApplicationArea = All; }
                field(ContributionRatio; Rec.ContributionRatio) { ApplicationArea = All; }
                field(Date_; Rec.Date_) { ApplicationArea = All; }
                field(SalesVat; Rec.SalesVat) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(RelatedEntities)
            {
                Caption = 'Related entities';

                action(C5InvenPriceGroup)
                {
                    ApplicationArea = All;
                    Caption = 'C5 InvenPriceGroup';
                    Image = Group;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedIsBig = True;
                    RunObject = Page "C5 InvenPriceGroup";
                    RunPageLink = Group = field(PriceGroup);
                    ToolTip = 'Open the C5 Inventory Price Groups page.';
                }
            }
        }
    }
}

