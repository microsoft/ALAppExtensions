// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
            }
        }
    }

    actions
    {
    }

    var
        CaptionClassTest: Codeunit "Caption Class Test";
}

