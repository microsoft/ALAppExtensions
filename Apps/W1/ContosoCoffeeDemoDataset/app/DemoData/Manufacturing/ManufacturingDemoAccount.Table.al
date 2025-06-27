#pragma warning disable AA0247
#if not CLEANSCHEMA26
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Manufacturing;

table 4761 "Manufacturing Demo Account"
{
    TableType = Temporary;
    ObsoleteReason = 'This table will be replaced by "Contoso GL Account".';
    ObsoleteState = Removed;
    ObsoleteTag = '26.0';
    ReplicateData = false;

    fields
    {
        field(1; "Account Key"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Account Value"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Account Description"; text[50])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Account Key")
        {
            Clustered = true;
        }
    }
}
#endif
