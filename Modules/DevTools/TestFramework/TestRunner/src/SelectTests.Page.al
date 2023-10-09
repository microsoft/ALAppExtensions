// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestTools.TestRunner;

using System.Reflection;

page 130453 "Select Tests"
{
    Editable = false;
    PageType = List;
    SourceTable = AllObjWithCaption;
    SourceTableView = where("Object Type" = const(Codeunit),
                            "Object Subtype" = const('Test'));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Object ID';
                }
                field("Object Name"; Rec."Object Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Object Name';
                }
            }
        }
    }

    actions
    {
    }
}

