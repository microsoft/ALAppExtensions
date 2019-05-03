// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1869 "C5 Payment"
{
    PageType = Card;
    SourceTable = "C5 Payment";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Payment';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Payment; Payment) { ApplicationArea = All; }
                field(Txt; Txt) { ApplicationArea = All; }
                field(Method; Method) { ApplicationArea = All; }
                field(Qty; Qty) { ApplicationArea = All; }
                field(UnitCode; UnitCode) { ApplicationArea = All; }
            }
        }
    }
}