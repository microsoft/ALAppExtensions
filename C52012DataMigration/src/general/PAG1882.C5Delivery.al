// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1882 "C5 Delivery"
{
    PageType = Card;
    SourceTable = "C5 Delivery";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Delivery';
    layout
    {
        area(content)
        {
            group(General)
            {
                field(Delivery; Delivery) { ApplicationArea = All; }
                field(Name; Name) { ApplicationArea = All; }
            }
        }
    }
}