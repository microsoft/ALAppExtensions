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
        }
        field(2; "Check Type"; Enum "Digital Voucher Check Type")
        {
        }
        field(3; "Generate Automatically"; Boolean)
        {
        }
        field(4; "Skip If Manually Added"; Boolean)
        {
            InitValue = true;
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
