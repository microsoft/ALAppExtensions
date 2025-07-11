// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using Microsoft.Finance.TaxEngine.TaxTypeHandler;

table 18814 "TCS Setup"
{
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "ID"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Tax Type"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Tax Type";
        }
    }

    keys
    {
        key(PK; "ID")
        {
            Clustered = true;
        }
    }
}
