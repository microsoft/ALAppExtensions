#if not CLEANSCHEMA31
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using System.IO;

tableextension 20107 "AMC Bank Credit Trs. Reg. Ext" extends "Credit Transfer Register"
{
    fields
    {
        field(20100; "Data Exch. Entry No."; Integer)
        {
            Caption = 'Data Exch. Entry No.';
            Editable = false;
            TableRelation = "Data Exch.";
            DataClassification = CustomerContent;
            ObsoleteReason = 'AMC Banking 365 Fundamental extension is discontinued';
#if not CLEAN28
            ObsoleteState = Pending;
            ObsoleteTag = '28.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '31.0';
#endif
        }
        field(20101; "AMC Bank XTL Journal"; Text[250])
        {
            Caption = 'XTL Journal';
            DataClassification = CustomerContent;
            ObsoleteReason = 'AMC Banking 365 Fundamental extension is discontinued';
#if not CLEAN28
            ObsoleteState = Pending;
            ObsoleteTag = '28.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '31.0';
#endif
        }
    }

    keys
    {
#if not CLEAN28
        key(AMCKey1; "Data Exch. Entry No.")
        {
        }
#endif
    }


}
#endif
