// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

xmlport 1877 "C5 Purpose"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'PurposeDocument';
            tableelement(C5Purpose; "C5 Purpose")
            {
                fieldelement(Purpose; C5Purpose.Purpose) { }
                fieldelement(Name; C5Purpose.Name) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5Purpose.RecId := Counter;
                    Counter += 1;
                end;
            }
        }
    }

    var
        Counter: Integer;
}

