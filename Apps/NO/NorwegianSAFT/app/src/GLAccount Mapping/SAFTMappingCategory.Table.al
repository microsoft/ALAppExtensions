// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

table 10671 "SAF-T Mapping Category"
{
    DataClassification = CustomerContent;
    Caption = 'SAF-T Mapping Category';

    fields
    {
        field(1; "Mapping Type"; Enum "SAF-T Mapping Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Mapping Type';
        }
        field(2; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
        }
        field(3; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(4; "Extended No."; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'Extended No.';

            trigger OnValidate()
            begin
                // Meets the current legal requirement of the SAFTLongTextType
                if StrLen("Extended No.") > 256 then
                    Error(ExtendedNoMaxLengthErr);
            end;
        }
    }

    keys
    {
        key(PK; "Mapping Type", "No.")
        {
            Clustered = true;
        }
        key(ExtendedNoIndex; "Mapping Type", "Extended No.")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description)
        {

        }
    }

    trigger OnDelete()
    var
        SAFTMapping: Record "SAF-T Mapping";
    begin
        SAFTMapping.SetRange("Mapping Type", "Mapping Type");
        SAFTMapping.SetRange("Category No.", "No.");
        SAFTMapping.DeleteAll(true);
    end;

    var
        ExtendedNoMaxLengthErr: Label 'The Extended No. field cannot exceed 256 characters as per the SAF-T specification.';
}
