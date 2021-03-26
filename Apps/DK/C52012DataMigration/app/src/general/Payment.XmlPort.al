// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

xmlport 1875 "C5 Payment"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'PaymentDocument';
            tableelement(C5Payment; "C5 Payment")
            {
                fieldelement(Payment; C5Payment.Payment) { }
                fieldelement(Txt; C5Payment.Txt) { }
                fieldelement(Method; C5Payment.Method) { }
                fieldelement(Qty; C5Payment.Qty) { }
                fieldelement(UnitCode; C5Payment.UnitCode) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5Payment.RecId := Counter;
                    Counter += 1;
                end;
            }
        }
    }

    var
        Counter: Integer;
}

