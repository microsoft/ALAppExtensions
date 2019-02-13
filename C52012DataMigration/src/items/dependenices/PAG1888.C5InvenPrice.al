// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

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
                field(ItemNumber;ItemNumber) { ApplicationArea=All; }
                field(Price;Price) { ApplicationArea=All; }
                field(PriceUnit;PriceUnit) { ApplicationArea=All; }
                field(Currency;Currency) { ApplicationArea=All; }
                field(PriceGroup;PriceGroup) { ApplicationArea=All; }
                field(ContributionRatio;ContributionRatio) { ApplicationArea=All; }
                field(Date_;Date_) { ApplicationArea=All; }
                field(SalesVat;SalesVat) { ApplicationArea=All; }
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
                    ApplicationArea=All;
                    Caption = 'C5 InvenPriceGroup';
                    Image = Group;
                    Promoted=true;
                    PromotedIsBig=True;
                    RunObject=Page "C5 InvenPriceGroup";
                    RunPageLink=Group=field(PriceGroup);
                }
            }
        }
    }
}
