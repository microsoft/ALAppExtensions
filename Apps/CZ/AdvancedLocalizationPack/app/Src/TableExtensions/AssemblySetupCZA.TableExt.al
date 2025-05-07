// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Assembly.Setup;

using Microsoft.Finance.GeneralLedger.Setup;

tableextension 31257 "Assembly Setup CZA" extends "Assembly Setup"
{
    fields
    {
#if not CLEANSCHEMA29
        field(31060; "Default Gen.Bus.Post. Grp. CZA"; Code[20])
        {
            Caption = 'Default Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;
#if not CLEAN26
            ObsoleteState = Pending;
            ObsoleteTag = '26.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
            ObsoleteReason = 'Replaced by "Default Gen. Bus. Post. Group" field in Assembly Setup Name table.';
        }
#endif
    }
}
