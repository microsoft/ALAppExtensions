// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

query 1850 "Sales Forecast Query"
{

    elements
    {
        dataitem(Vendor; Vendor)
        {
            column(VendorNo; "No.")
            {
            }
            dataitem(Item; Item)
            {
                DataItemLink = "Vendor No." = Vendor."No.";
                SqlJoinType = InnerJoin;
                column(ItemNo; "No.")
                {
                }
                column(ItemDescription; Description)
                {
                }
                column(Inventory; Inventory)
                {
                }
                dataitem(MS_Sales_Forecast; "MS - Sales Forecast")
                {
                    DataItemLink = "Item No." = Item."No.";
                    SqlJoinType = InnerJoin;
                    DataItemTableFilter = "Forecast Data" = Const (Result);
                    filter(Date; Date)
                    {
                    }
                    filter(Variance; "Variance %")
                    {
                    }
                    column(ExpectedSales; Quantity)
                    {
                        Method = Sum;
                    }
                }
            }
        }
    }
}

