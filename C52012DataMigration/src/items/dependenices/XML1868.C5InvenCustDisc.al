// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

xmlport 1868 "C5 InvenCustDisc"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'InvenCustDiscDocument';
            tableelement(C5InvenCustDisc; "C5 InvenCustDisc")
            {
                fieldelement(ItemCode; C5InvenCustDisc.ItemCode) { }
                fieldelement(AccountCode; C5InvenCustDisc.AccountCode) { }
                fieldelement(ItemRelation; C5InvenCustDisc.ItemRelation) { }
                fieldelement(RESERVED1; C5InvenCustDisc.RESERVED1) { }
                fieldelement(AccountRelation; C5InvenCustDisc.AccountRelation) { }
                fieldelement(RESERVED2; C5InvenCustDisc.RESERVED2) { }
                fieldelement(Type; C5InvenCustDisc.Type) { }
                fieldelement(Qty; C5InvenCustDisc.Qty) { }
                textelement(FromDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(FromDateText, CopyStr(DateFormatStringTxt, 1, 20), C5InvenCustDisc.FromDate);
                    end;
                }

                textelement(ToDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(ToDateText, CopyStr(DateFormatStringTxt, 1, 20), C5InvenCustDisc.ToDate);
                    end;
                }

                fieldelement(Rate_; C5InvenCustDisc.Rate_) { }
                fieldelement(SearchAgain; C5InvenCustDisc.SearchAgain) { }
                fieldelement(SearchSimilar; C5InvenCustDisc.SearchSimilar) { }
                fieldelement(Currency; C5InvenCustDisc.Currency) { }
                fieldelement(PriceUnit; C5InvenCustDisc.PriceUnit) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5InvenCustDisc.RecId := Counter;
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

