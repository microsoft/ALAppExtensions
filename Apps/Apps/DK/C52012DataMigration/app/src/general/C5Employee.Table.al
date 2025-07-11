// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

table 1874 "C5 Employee"
{
    ReplicateData = false;

    fields
    {
        field(1; RecId; Integer)
        {
            Caption = 'Row number';
        }
        field(2; LastChanged; Date)
        {
            Caption = 'Last changed';
        }
        field(3; Employee; Code[10])
        {
            Caption = 'Employee';
        }
        field(4; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(5; Address1; Text[50])
        {
            Caption = 'Address';
        }
        field(6; Address2; Text[50])
        {
            Caption = 'Address';
        }
        field(7; ZipCity; Text[50])
        {
            Caption = 'Zip code/City';
        }
        field(8; User; Integer)
        {
            Caption = 'User';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(9; Phone; Text[20])
        {
            Caption = 'Phone';
        }
        field(10; LocalNumber; Text[20])
        {
            Caption = 'Extension';
        }
        field(11; Department; Text[10])
        {
            Caption = 'Department';
        }
        field(12; ImageFile; Text[250])
        {
            Caption = 'Image';
        }
        field(13; EmployeeType; Option)
        {
            Caption = 'Employee type';
            OptionMembers = Internal,External,"Sales rep.","Order taker",Purchaser;
        }
        field(14; Email; Text[80])
        {
            Caption = 'Email';
        }
        field(15; Centre; Code[10])
        {
            Caption = 'Cost centre';
        }
        field(16; Purpose; Code[10])
        {
            Caption = 'Purpose';
        }
        field(17; KrakNumber; Text[15])
        {
            Caption = 'Krak no.';
        }
        field(18; Country; Text[30])
        {
            Caption = 'Country/region';
        }
        field(19; Currency; Code[3])
        {
            Caption = 'Currency code';
        }
        field(20; Language_; Option)
        {
            Caption = 'Language';
            OptionMembers = Default,Danish,English,German,French,Italian,Dutch,Icelandic;
        }
        field(21; CellPhone; Text[20])
        {
            Caption = 'Cell phone';
        }
    }

    keys
    {
        key(PK; RecId)
        {
            Clustered = true;
        }
    }
}

