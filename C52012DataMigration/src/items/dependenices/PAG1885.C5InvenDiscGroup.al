// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1885 "C5 InvenDiscGroup"
{
    PageType = Card;
    SourceTable = "C5 InvenDiscGroup";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Inventory Discount';
    layout
    {
        area(content)
        {
            group(General)
            {
                field(DiscGroup;DiscGroup) { ApplicationArea=All; }
                field(Comment;Comment) { ApplicationArea=All; }
            }
        }
    }
}