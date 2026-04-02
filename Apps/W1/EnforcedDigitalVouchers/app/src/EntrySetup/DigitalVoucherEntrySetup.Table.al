// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

table 5579 "Digital Voucher Entry Setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry Type"; Enum "Digital Voucher Entry Type")
        {
            NotBlank = true;

            trigger OnValidate()
            begin
                "Consider Blank Doc. Type" := false;
            end;
        }
        field(2; "Check Type"; Enum "Digital Voucher Check Type")
        {
            trigger OnValidate()
            var
                CheckTypeEDocErr: Label '%1 %2 is available only for %3 %4 or %5.', Comment = '%1 - Check type field caption, %2 - Check type value, %3 - Entry type field caption, %4 - Entry type value, %5 - Entry type value';
            begin
                if "Check Type" = "Check Type"::"E-Document" then begin
                    if not ("Entry Type" in ["Entry Type"::"Sales Document", "Entry Type"::"Purchase Document"]) then
                        Error(CheckTypeEDocErr, FieldCaption("Check Type"), "Check Type"::"E-Document", FieldCaption("Entry Type"), "Entry Type"::"Sales Document", "Entry Type"::"Purchase Document");
                    "Generate Automatically" := true;
                end;
            end;
        }
        field(3; "Generate Automatically"; Boolean)
        {
            trigger OnValidate()
            var
                GenerateAutoMustBeEnabledErr: Label 'Generate Automatically must be enabled when %1 is %2.', Comment = '%1 - Check type field caption, %2 - Check type value';
            begin
                if ("Check Type" = "Check Type"::"E-Document") and (not "Generate Automatically") then
                    Error(GenerateAutoMustBeEnabledErr, FieldCaption("Check Type"), "Check Type"::"E-Document");
            end;
        }
        field(4; "Skip If Manually Added"; Boolean)
        {
            InitValue = true;
        }
        field(5; "Consider Blank Doc. Type"; Boolean)
        {
            trigger OnValidate()
            begin
                if "Consider Blank Doc. Type" then
                    if not ("Entry Type" in ["Entry Type"::"General Journal", "Entry Type"::"Sales Journal", "Entry Type"::"Purchase Journal"]) then
                        FieldError("Entry Type");
            end;
        }
    }

    keys
    {
        key(PK; "Entry Type")
        {
            Clustered = true;
        }
    }
}
