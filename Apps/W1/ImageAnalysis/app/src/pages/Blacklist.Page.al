// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 2027 "Image Analysis Blacklist"
{
    PageType = List;
    SourceTable = "MS - Img. Analyzer Blacklist";
    Caption = 'Image Analyzer Blocked Attributes';
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(GroupName)
            {
                field(ItemCode; TagName)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Enabled = false;
                }
            }
        }
    }
}