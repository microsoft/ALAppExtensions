// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 1856 PurchaseOrderForecastExtension extends "Purchase Order"
{
    layout
    {
        addafter(WorkflowStatus)
        {
            part(ItemForecast; "Sales Forecast")
            {
                ApplicationArea = Suite;
                Provider = PurchLines;
                SubPageLink = "No." = Field ("No.");
                UpdatePropagation = Both;
            }
        }
    }
}

