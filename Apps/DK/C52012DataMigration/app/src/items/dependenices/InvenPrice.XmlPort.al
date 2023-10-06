// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

xmlport 1872 "C5 InvenPrice"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'InvenPriceDocument';
            tableelement(C5InvenPrice; "C5 InvenPrice")
            {
                fieldelement(ItemNumber; C5InvenPrice.ItemNumber) { }
                fieldelement(Price; C5InvenPrice.Price) { }
                fieldelement(PriceUnit; C5InvenPrice.PriceUnit) { }
                fieldelement(Currency; C5InvenPrice.Currency) { }
                fieldelement(PriceGroup; C5InvenPrice.PriceGroup) { }
                fieldelement(ContributionRatio; C5InvenPrice.ContributionRatio) { }
                textelement(Date_Text)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(Date_Text, CopyStr(DateFormatStringTxt, 1, 20), C5InvenPrice.Date_);
                    end;
                }

                fieldelement(SalesVat; C5InvenPrice.SalesVat) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5InvenPrice.RecId := Counter;
                    Counter += 1;
                end;
            }
        }
    }

    var
        C5HelperFunctions: Codeunit "C5 Helper Functions";
        DateFormatStringTxt: label 'yyyy/MM/dd', locked = true;
        Counter: Integer;
}

