// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

page 4411 "SOA Activities"
{
    Caption = 'SOA Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    ShowFilter = false;
    Extensible = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(content)
        {
            cuegroup("Actions")
            {
                actions
                {
                    action(ItemAvailability)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Item Availability';
                        Image = TileBrickCustomer;
                        ToolTip = 'Open the item availability page to search for available items.';
                        RunObject = Page "SOA Multi Items Availability";
                        RunPageMode = Edit;
                    }
                }
            }
        }
    }
}
