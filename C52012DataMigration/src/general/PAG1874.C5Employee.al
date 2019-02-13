// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1874 "C5 Employee"
{
    PageType = Card;
    SourceTable = "C5 Employee";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Employee';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Employee; Employee) { ApplicationArea = All; }
                field(Name; Name) { ApplicationArea = All; }
                field(Address1; Address1) { ApplicationArea = All; }
                field(Address2; Address2) { ApplicationArea = All; }
                field(ZipCity; ZipCity) { ApplicationArea = All; }
                field(User; User) { ApplicationArea = All; }
                field(Phone; Phone) { ApplicationArea = All; }
                field(LocalNumber; LocalNumber) { ApplicationArea = All; }
                field(Department; Department) { ApplicationArea = All; }
                field(ImageFile; ImageFile) { ApplicationArea = All; }
                field(EmployeeType; EmployeeType) { ApplicationArea = All; }
                field(Email; Email) { ApplicationArea = All; }
                field(Centre; Centre) { ApplicationArea = All; }
                field(Purpose; Purpose) { ApplicationArea = All; }
                field(KrakNumber; KrakNumber) { ApplicationArea = All; }
                field(Country; Country) { ApplicationArea = All; }
                field(Currency; Currency) { ApplicationArea = All; }
                field(Language_; Language_) { ApplicationArea = All; }
                field(CellPhone; CellPhone) { ApplicationArea = All; }

            }
        }
    }
}