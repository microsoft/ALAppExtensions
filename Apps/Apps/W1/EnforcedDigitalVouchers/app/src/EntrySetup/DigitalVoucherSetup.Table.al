// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

table 5581 "Digital Voucher Setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Boolean)
        {
        }
        field(2; Enabled; Boolean)
        {
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure InitSetup()
    begin
        if not Rec.Get() then
            Rec.Insert(true);
    end;
}
