// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 130452 "Select Tests By Range"
{
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(Control1)
            {
                ShowCaption = false;
                field("Selection Filter"; SelectionFilter)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the selection filter.';
                    Caption = 'Selection Filter';
                }
            }
        }
    }

    actions
    {
    }

    var
        SelectionFilter: Text;

    procedure GetRange(): Text
    begin
        exit(SelectionFilter);
    end;
}

