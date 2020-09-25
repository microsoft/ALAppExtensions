// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 1854 ItemCardForecastExtension extends "Item Card"
{
    layout
    {
        addafter(ItemAttributesFactbox)
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
        addafter(Functions)
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
                        TimeSeriesManagement: Codeunit "Time Series Management";
                        SalesForecastHandler: Codeunit "Sales Forecast Handler";
                    begin
                        if not SalesForecastHandler.CalculateForecast(Rec, TimeSeriesManagement) then
                            SalesForecastHandler.ThrowStatusError();
                    end;
                }

            }
        }
    }
}

