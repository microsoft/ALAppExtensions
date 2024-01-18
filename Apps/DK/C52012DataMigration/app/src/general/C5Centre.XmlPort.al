// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

xmlport 1861 "C5 Centre"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'CentreDocument';
            tableelement(C5Centre; "C5 Centre")
            {
                fieldelement(Centre; C5Centre.Centre) { }
                fieldelement(Name; C5Centre.Name) { }

                trigger OnBeforeInsertRecord();
                begin
                    Counter += 1;
                    C5Centre.RecId := Counter;
                end;
            }
        }
    }

    var
        Counter: Integer;
}

