// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Displays a list of field content buffers.
/// </summary>
page 1753 "Field Content Buffer"
{
    Extensible = false;
    Caption = 'Field Contents';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Field Content Buffer";
    ContextSensitiveHelpPage = 'admin-classifying-data-sensitivity';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Value; Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the field value.';
                }
            }
        }
    }

    actions
    {
    }
}

