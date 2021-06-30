// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 137121 "Translation Test Table"
{
    LookupPageID = "Translation Test Page";

    fields
    {
        field(1; PK; Integer)
        {
        }
        field(2; TextField; Text[2048])
        {
            Editable = false;
        }
        field(3; SecondTextField; Text[2048])
        {
            Editable = false;
        }
    }

    keys
    {
        key(Key1; PK)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        Translation.Delete(Rec);
    end;

    var
        Translation: Codeunit Translation;
}

