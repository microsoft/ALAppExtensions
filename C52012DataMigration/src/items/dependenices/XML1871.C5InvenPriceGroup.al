// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

xmlport 1871 "C5 InvenPrcGroup"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'InvenPriceGroupDocument';
            tableelement(C5InvenPriceGroup; "C5 InvenPriceGroup")
            {
                fieldelement(Group; C5InvenPriceGroup.Group) { }
                fieldelement(GroupName; C5InvenPriceGroup.GroupName) { }
                fieldelement(InclVat; C5InvenPriceGroup.InclVat) { }
                fieldelement(Roundoff1; C5InvenPriceGroup.Roundoff1) { }
                fieldelement(Roundoff10; C5InvenPriceGroup.Roundoff10) { }
                fieldelement(Roundoff100; C5InvenPriceGroup.Roundoff100) { }
                fieldelement(Roundoff1000; C5InvenPriceGroup.Roundoff1000) { }
                fieldelement(Roundoff1000Plus; C5InvenPriceGroup.Roundoff1000Plus) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5InvenPriceGroup.RecId := Counter;
                    Counter += 1;
                end;
            }
        }
    }

    var
        Counter: Integer;
}

