#if not CLEANSCHEMA31
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;

tableextension 20103 "AMC Bank Bank Account ext." extends "Bank Account"
{

    fields
    {
        field(20100; "AMC Bank Name"; Text[50])
        {
            Caption = 'Bank Name';
            TableRelation = "AMC Bank Banks" WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            ValidateTableRelation = false;
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

        field(20101; "AMC Bank File Name"; Text[250])
        {
            Caption = 'Bank file Name';
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

}
#endif
