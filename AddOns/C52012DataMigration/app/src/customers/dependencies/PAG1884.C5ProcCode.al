// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1884 "C5 ProcCode"
{
    PageType = Card;
    SourceTable = "C5 ProcCode";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Process Codes';
    layout
    {
        area(content)
        {
            group(General)
            {
                field(Type;Type) { ApplicationArea=All; }
                field(Code;Code) { ApplicationArea=All; }
                field(Name;Name) { ApplicationArea=All; }
                field(Int1;Int1) { ApplicationArea=All; }
                field(Int2;Int2) { ApplicationArea=All; }
                field(Int3;Int3) { ApplicationArea=All; }
                field(Int4;Int4) { ApplicationArea=All; }
                field(NoYes1;NoYes1) { ApplicationArea=All; }
            }
        }
    }
}