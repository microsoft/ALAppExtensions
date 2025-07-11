// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

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
#pragma warning disable AA0218
                field(Payment; Rec.Payment) { ApplicationArea = All; }
                field(Txt; Rec.Txt) { ApplicationArea = All; }
                field(Method; Rec.Method) { ApplicationArea = All; }
                field(Qty; Rec.Qty) { ApplicationArea = All; }
                field(UnitCode; Rec.UnitCode) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }
}
