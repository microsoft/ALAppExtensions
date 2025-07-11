// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

table 31300 "Statistic Indication CZ"
{
    Caption = 'Statistic Indication';
    LookupPageID = "Statistic Indications CZ";

    fields
    {
        field(1; "Tariff No."; Code[20])
        {
            Caption = 'Tariff No.';
            NotBlank = true;
            TableRelation = "Tariff Number";
            DataClassification = CustomerContent;
        }
        field(2; Code; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Description EN"; Text[100])
        {
            Caption = 'Description EN';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Tariff No.", Code)
        {
            Clustered = true;
        }
    }
}