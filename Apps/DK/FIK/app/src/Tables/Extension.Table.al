// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

table 13624 FIKExtension
{
    DataPerCompany = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'Using per company table instead, table 13625 FIKUplift';
    ObsoleteTag = '18.0';
    ReplicateData = false;

    fields
    {
        field(1; Code; Code[10])
        {
        }
        field(2; IsUpgraded; Boolean)
        {
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

}
