// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 10037 "IRS 1099 Calc. Params"
{
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Period No."; Code[20])
        {
        }
        field(2; "Vendor No."; Code[20])
        {
        }
        field(3; "Form No."; Code[20])
        {
        }
        field(10; Replace; Boolean)
        {
        }
    }

    keys
    {
        key(PK; "Period No.", "Vendor No.", "Form No.")
        {
            Clustered = true;
        }
    }
}
