// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

xmlport 1878 "C5 UnitCode"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'UnitCodeDocument';
            tableelement(C5UnitCode; "C5 UnitCode")
            {
                fieldelement(UnitCode; C5UnitCode.UnitCode) { }
                fieldelement(Txt; C5UnitCode.Txt) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5UnitCode.RecId := Counter;
                    Counter += 1;
                end;
            }
        }
    }

    var
        Counter: Integer;
}

