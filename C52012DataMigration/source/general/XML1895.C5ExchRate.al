// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

xmlport 1895 "C5 Exch. Rate"
{
    Direction=Import;
    Format=VariableText;
    FormatEvaluate=XML;


    schema
    {
        textelement(root)
        {
            MinOccurs=Zero;
            XmlName='ExchRateDocument';
            tableelement(C5ExchRate; "C5 ExchRate")
            {
                fieldelement(Currency; C5ExchRate.Currency) { }
                fieldelement(ExchRate; C5ExchRate.ExchRate) { }
                textelement(FromDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(FromDateText, CopyStr(DateFormatString, 1, 20), C5ExchRate.FromDate);
                    end;
                }

                fieldelement(Comment; C5ExchRate.Comment) { }
                fieldelement(Triangulation; C5ExchRate.Triangulation) { }
           }
       }
    }

    var
        C5HelperFunctions: Codeunit "C5 Helper Functions";
        DateFormatString: label 'yyyy/MM/dd', locked=true;
}

