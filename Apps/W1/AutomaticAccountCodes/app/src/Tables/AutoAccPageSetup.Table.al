#if not CLEANSCHEMA25
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

table 4857 "Auto. Acc. Page Setup"
{
    DataClassification = SystemMetadata;
    ObsoleteReason = 'Automatic Acc.functionality will be moved to a new app.';
    ObsoleteState = Removed;
    ObsoleteTag = '25.0';

    fields
    {
#pragma warning disable AS0105
        field(1; Id; Enum "AAC Page Setup Key")
        {
            DataClassification = SystemMetadata;
#if CLEAN26
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#else
            ObsoleteState = Pending;
            ObsoleteTag = '26.0';
#endif
            ObsoleteReason = 'Automatic Acc.functionality will be moved to a new app.';
        }
#pragma warning restore AS0105
        field(2; ObjectId; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }
}
#endif