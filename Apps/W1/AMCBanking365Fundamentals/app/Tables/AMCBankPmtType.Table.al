#if not CLEANSCHEMA31
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

table 20102 "AMC Bank Pmt. Type"
{
    Caption = 'AMC Banking Payment types';
#if not CLEAN28
    LookupPageID = "AMC Bank Pmt. Types";
#endif
    ObsoleteReason = 'AMC Banking 365 Fundamental extension is discontinued';
#if not CLEAN28
    ObsoleteState = Pending;
    ObsoleteTag = '28.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '31.0';
#endif


    fields
    {
        field(20100; "Code"; Text[50])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(20101; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}
#endif
