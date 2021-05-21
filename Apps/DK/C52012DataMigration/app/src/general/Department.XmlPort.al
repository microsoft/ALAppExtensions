// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

xmlport 1866 "C5 Department"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'DepartmentDocument';
            tableelement(C5Department; "C5 Department")
            {
                fieldelement(Department; C5Department.Department) { }
                fieldelement(Name; C5Department.Name) { }
                fieldelement(C4Department; C5Department.C4Department) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5Department.RecId := Counter;
                    Counter += 1;
                end;
            }
        }
    }

    var
        Counter: Integer;
}

