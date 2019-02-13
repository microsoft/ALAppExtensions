// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 1855 ItemListForecastExtension extends "Item List"
{
    layout
    {
        addafter(ItemAttributesFactBox)
        {
            part(ItemForecast; "Sales Forecast")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = Field ("No.");
                Visible = "Has Sales Forecast";
            }
            part(ItemForecastNoChart; "Sales Forecast No Chart")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = Field ("No.");
                Visible = not "Has Sales Forecast";
            }
        }
    }
    actions
    {
        addafter(Display)
        {
            group(Forecast)
            {
                Caption = 'Forecast';
                action("Update Sales Forecast")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Update Sales Forecast';
                    Image = Campaign;

                    trigger OnAction();
                    var
                        Item: Record Item;
                        SalesForecastHandler: Codeunit "Sales Forecast Handler";
                    begin
                        CurrPage.SetSelectionFilter(Item);
                        SalesForecastHandler.UpdateSalesForecastItemList(Item);
                    end;
                }
            }
        }
    }
}

