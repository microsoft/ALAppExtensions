// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

xmlport 1901 "C5 VendContact"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'VendContactDocument';
            tableelement(C5VendContact; "C5 VendContact")
            {
                fieldelement(Account; C5VendContact.Account) { }
                fieldelement(PrimaryContact; C5VendContact.PrimaryContact) { }
                fieldelement(Name; C5VendContact.Name) { }
                fieldelement(Position; C5VendContact.Position) { }
                fieldelement(Address1; C5VendContact.Address1) { }
                fieldelement(Address2; C5VendContact.Address2) { }
                fieldelement(ZipCity; C5VendContact.ZipCity) { }
                fieldelement(Country; C5VendContact.Country) { }
                fieldelement(Email; C5VendContact.Email) { }
                fieldelement(Phone; C5VendContact.Phone) { }
                fieldelement(Fax; C5VendContact.Fax) { }
                fieldelement(LocalNumber; C5VendContact.LocalNumber) { }
                fieldelement(CellPhone; C5VendContact.CellPhone) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5VendContact.RecId := Counter;
                    Counter += 1;
                end;
            }
        }
    }

    var
        Counter: Integer;
}

