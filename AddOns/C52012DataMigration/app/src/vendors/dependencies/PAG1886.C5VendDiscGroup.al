// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1886 "C5 VendDiscGroup"
{
    PageType = Card;
    SourceTable = "C5 VendDiscGroup";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Vendor Discount Groups';

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