// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Integration.Excel;

using System.TestLibraries.Integration.Excel;
page 132526 "Edit In Excel Json"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Edit In Excel Test Table";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field.';
                }
            }
        }
        area(Factboxes)
        {

        }
    }
}