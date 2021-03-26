// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

xmlport 1867 "C5 Employee"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'EmployeeDocument';
            tableelement(C5Employee; "C5 Employee")
            {
                fieldelement(Employee; C5Employee.Employee) { }
                fieldelement(Name; C5Employee.Name) { }
                fieldelement(Address1; C5Employee.Address1) { }
                fieldelement(Address2; C5Employee.Address2) { }
                fieldelement(ZipCity; C5Employee.ZipCity) { }
                fieldelement(User; C5Employee.User) { }
                fieldelement(Phone; C5Employee.Phone) { }
                fieldelement(LocalNumber; C5Employee.LocalNumber) { }
                fieldelement(Department; C5Employee.Department) { }
                fieldelement(ImageFile; C5Employee.ImageFile) { }
                fieldelement(EmployeeType; C5Employee.EmployeeType) { }
                fieldelement(Email; C5Employee.Email) { }
                fieldelement(Centre; C5Employee.Centre) { }
                fieldelement(Purpose; C5Employee.Purpose) { }
                fieldelement(KrakNumber; C5Employee.KrakNumber) { }
                fieldelement(Country; C5Employee.Country) { }
                fieldelement(Currency; C5Employee.Currency) { }
                fieldelement(Language_; C5Employee.Language_) { }
                fieldelement(CellPhone; C5Employee.CellPhone) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5Employee.RecId := Counter;
                    Counter += 1;
                end;
            }
        }
    }

    var
        Counter: Integer;
}

