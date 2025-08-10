// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Shops (ID 30102).
/// </summary>
page 30102 "Shpfy Shops"
{
    ApplicationArea = All;
    Caption = 'Shopify Shops';
    CardPageId = "Shpfy Shop Card";
    PageType = List;
    SourceTable = "Shpfy Shop";
    UsageCategory = Administration;
    AdditionalSearchTerms = 'Shopify Setup';
    Editable = false;
    DeleteAllowed = true;
    InsertAllowed = true;
    AboutTitle = 'About Shops';
    AboutText = 'Set up the shops on Shopify that you want to connect to the *current* company in Business Central. These settings affect how the shops synchronize to and from Shopify.';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a code to identify this Shopify Shop.';
                }
                field(ShopifyURL; Rec."Shopify URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the URL of the Shopify Shop.';
                }
                field(LanguageCode; Rec."Language Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the language of the Shopify Shop.';
                }
            }
        }
    }
}