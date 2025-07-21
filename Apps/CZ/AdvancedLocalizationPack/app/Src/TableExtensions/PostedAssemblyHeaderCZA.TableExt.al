// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Assembly.History;

using Microsoft.Finance.GeneralLedger.Setup;

tableextension 31260 "Posted Assembly Header CZA" extends "Posted Assembly Header"
{
    fields
    {
#if not CLEANSCHEMA30
        field(31060; "Gen. Bus. Posting Group CZA"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;
#if not CLEAN27
            ObsoleteState = Pending;
            ObsoleteTag = '27.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '30.0';
#endif
            ObsoleteReason = 'Replaced by "Gen. Bus. Posting Group" field in Posted Assembly Header Name table.';
        }
#endif
    }
}
