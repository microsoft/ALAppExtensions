// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Text;

page 132577 "Caption Class Test Page"
{

    layout
    {
        area(content)
        {
            field("Test field"; '')
            {
                ApplicationArea = All;
                CaptionClass = CaptionClassTest.GetCaptionClass();
                ToolTip = 'Specifies a Test field';
            }
        }
    }

    actions
    {
    }

    var
        CaptionClassTest: Codeunit "Caption Class Test";
}

