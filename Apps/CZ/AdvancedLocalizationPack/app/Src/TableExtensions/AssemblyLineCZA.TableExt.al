// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Assembly.Document;

using Microsoft.Finance.GeneralLedger.Setup;

tableextension 31259 "Assembly Line CZA" extends "Assembly Line"
{
    fields
    {
#if not CLEANSCHEMA29
        field(31060; "Gen. Bus. Posting Group CZA"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;
#if not CLEAN26
            ObsoleteState = Pending;
            ObsoleteTag = '26.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
            ObsoleteReason = 'Replaced by "Gen. Bus. Posting Group" field in Assembly Line Name table.';
        }
#endif
    }
}
