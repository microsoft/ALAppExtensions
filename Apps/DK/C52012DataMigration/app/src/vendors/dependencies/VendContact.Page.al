// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1905 "C5 VendContact"
{
    PageType = List;
    SourceTable = "C5 VendContact";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Vendor Contact Persons';
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Account;Account) { ApplicationArea=All; }
                field(Name;Name) { ApplicationArea=All; }
                field(Position;Position) { ApplicationArea=All; }
                field(Address1;Address1) { ApplicationArea=All; }
                field(Address2;Address2) { ApplicationArea=All; }
                field(ZipCity;ZipCity) { ApplicationArea=All; }
                field(Country;Country) { ApplicationArea=All; }
                field(Email;Email) { ApplicationArea=All; }
                field(Phone;Phone) { ApplicationArea=All; }
                field(Fax;Fax) { ApplicationArea=All; }
                field(LocalNumber;LocalNumber) { ApplicationArea=All; }
                field(CellPhone;CellPhone) { ApplicationArea=All; }
                field(PrimaryContact;PrimaryContact) { ApplicationArea=All; }
            }
        }
    }
}