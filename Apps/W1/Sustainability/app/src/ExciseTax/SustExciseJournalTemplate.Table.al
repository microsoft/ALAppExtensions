// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

table 6238 "Sust. Excise Journal Template"
{
    Caption = 'Excise Journal Template';
    DataClassification = CustomerContent;
    DataPerCompany = true;
    Extensible = true;

    fields
    {
        field(1; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(2; Description; Text[80])
        {
            Caption = 'Description';
        }
    }
    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch";
    begin
        SustainabilityExciseJnlBatch.SetRange("Journal Template Name", Name);
        SustainabilityExciseJnlBatch.DeleteAll(true);
    end;
}