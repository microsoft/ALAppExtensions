// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

page 1864 "C5 CN8Code"
{
    PageType = Card;
    SourceTable = "C5 CN8Code";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Item CN8 Codes';
    layout
    {
        area(content)
        {
            group(General)
            {
#pragma warning disable AA0218
                field(CN8Code; Rec.CN8Code) { ApplicationArea = All; }
                field(Txt; Rec.Txt) { ApplicationArea = All; }
                field(SupplementaryUnits; Rec.SupplementaryUnits) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }
}
