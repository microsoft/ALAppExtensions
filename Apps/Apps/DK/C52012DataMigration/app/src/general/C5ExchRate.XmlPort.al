// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

xmlport 1895 "C5 Exch. Rate"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'ExchRateDocument';
            tableelement(C5ExchRate; "C5 ExchRate")
            {
                fieldelement(Currency; C5ExchRate.Currency) { }
                fieldelement(ExchRate; C5ExchRate.ExchRate) { }
                textelement(FromDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(FromDateText, CopyStr(DateFormatStringTxt, 1, 20), C5ExchRate.FromDate);
                    end;
                }

                fieldelement(Comment; C5ExchRate.Comment) { }
                fieldelement(Triangulation; C5ExchRate.Triangulation) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5ExchRate.RecId := Counter;
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

