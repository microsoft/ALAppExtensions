// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 10046 "IRS 1099 Email Queue"
{
    Access = Internal;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Editable = false;
            AutoIncrement = true;
        }
        field(10; "Document ID"; Integer)
        {
            Editable = false;
        }
        field(11; "Report Type"; Enum "IRS 1099 Form Report Type")
        {
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
}
