// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Tag Factbox (ID 30103).
/// </summary>
page 30103 "Shpfy Tag Factbox"
{
    Caption = 'Shopify Tags';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "Shpfy Tag";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Tag; Rec.Tag)
                {
                    ApplicationArea = All;
                    Caption = 'Tag';
                    ToolTip = 'Specifies the tags of a product that are used for filtering and search.';
                }
            }
        }
    }
}