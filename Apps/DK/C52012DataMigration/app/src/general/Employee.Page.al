// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

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
#pragma warning disable AA0218
                field(Employee; Rec.Employee) { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field(Address1; Rec.Address1) { ApplicationArea = All; }
                field(Address2; Rec.Address2) { ApplicationArea = All; }
                field(ZipCity; Rec.ZipCity) { ApplicationArea = All; }
                field(User; Rec.User) { ApplicationArea = All; }
                field(Phone; Rec.Phone) { ApplicationArea = All; }
                field(LocalNumber; Rec.LocalNumber) { ApplicationArea = All; }
                field(Department; Rec.Department) { ApplicationArea = All; }
                field(ImageFile; Rec.ImageFile) { ApplicationArea = All; }
                field(EmployeeType; Rec.EmployeeType) { ApplicationArea = All; }
                field(Email; Rec.Email) { ApplicationArea = All; }
                field(Centre; Rec.Centre) { ApplicationArea = All; }
                field(Purpose; Rec.Purpose) { ApplicationArea = All; }
                field(KrakNumber; Rec.KrakNumber) { ApplicationArea = All; }
                field(Country; Rec.Country) { ApplicationArea = All; }
                field(Currency; Rec.Currency) { ApplicationArea = All; }
                field(Language_; Rec.Language_) { ApplicationArea = All; }
                field(CellPhone; Rec.CellPhone) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }
}
