// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

xmlport 1862 "C5 CN8Code"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'CN8CodeDocument';
            tableelement(C5CN8Code; "C5 CN8Code")
            {
                fieldelement(CN8Code; C5CN8Code.CN8Code) { }
                fieldelement(Txt; C5CN8Code.Txt) { }
                fieldelement(SupplementaryUnits; C5CN8Code.SupplementaryUnits) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5CN8Code.RecId := Counter;
                    Counter += 1;
                end;
            }
        }
    }

    var
        Counter: Integer;
}

