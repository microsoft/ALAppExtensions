// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Foundation.AuditCodes;

table 5580 "Voucher Entry Source Code"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry Type"; Enum "Digital Voucher Entry Type")
        {
        }
        field(2; "Source Code"; Code[10])
        {
            TableRelation = "Source Code";
        }
    }

    keys
    {
        key(PK; "Entry Type", "Source Code")
        {
            Clustered = true;
        }
    }
}
