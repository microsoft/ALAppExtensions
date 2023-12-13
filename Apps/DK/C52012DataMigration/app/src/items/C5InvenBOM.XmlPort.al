// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

xmlport 1898 "C5 InvenBOM"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;

    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'InvenBOMDocument';
            tableelement(C5InvenBOM; "C5 InvenBOM")
            {
                fieldelement(BOMItemNumber; C5InvenBOM.BOMItemNumber) { }
                fieldelement(LineNumber; C5InvenBOM.LineNumber) { }
                fieldelement(ItemNumber; C5InvenBOM.ItemNumber) { }
                fieldelement(Qty; C5InvenBOM.Qty) { }
                fieldelement(Position; C5InvenBOM.Position) { }
                fieldelement(LeadTime; C5InvenBOM.LeadTime) { }
                fieldelement(Resource; C5InvenBOM.Resource) { }
                fieldelement(InvenLocation; C5InvenBOM.InvenLocation) { }
                fieldelement(Comment; C5InvenBOM.Comment) { }
                fieldelement(PriceGroup; C5InvenBOM.PriceGroup) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5InvenBOM.RecId := Counter;
                    Counter += 1;
                end;
            }
        }
    }

    var
        Counter: Integer;
}

