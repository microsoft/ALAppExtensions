// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 2506 "Extension Logo Part"
{
    Extensible = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;
    PopulateAllFields = true;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "NAV App";

    layout
    {
        area(content)
        {
            group(Control4)
            {
                ShowCaption = false;
                group(Control3)
                {
                    ShowCaption = false;
                    field(Logo; Logo)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the logo of the extension, such as the logo of the service provider.';
                    }
                }
            }
        }
    }

    actions
    {
    }
}

