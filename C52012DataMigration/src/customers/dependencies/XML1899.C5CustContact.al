// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

xmlport 1899 "C5 CustContact"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'CustContactDocument';
            tableelement(C5CustContact; "C5 CustContact")
            {
                fieldelement(Account; C5CustContact.Account) { }
                fieldelement(PrimaryContact; C5CustContact.PrimaryContact) { }
                fieldelement(Name; C5CustContact.Name) { }
                fieldelement(Position; C5CustContact.Position) { }
                fieldelement(Address1; C5CustContact.Address1) { }
                fieldelement(Address2; C5CustContact.Address2) { }
                fieldelement(ZipCity; C5CustContact.ZipCity) { }
                fieldelement(Country; C5CustContact.Country) { }
                fieldelement(Email; C5CustContact.Email) { }
                fieldelement(Phone; C5CustContact.Phone) { }
                fieldelement(Fax; C5CustContact.Fax) { }
                fieldelement(LocalNumber; C5CustContact.LocalNumber) { }
                fieldelement(CellPhone; C5CustContact.CellPhone) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5CustContact.RecId := Counter;
                    Counter += 1;
                end;
            }
        }
    }

    var
        Counter: Integer;
}

