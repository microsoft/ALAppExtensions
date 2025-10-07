#if not CLEANSCHEMA31
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.Currency;

tableextension 20108 "AMC Bank Paym. Exp. Data Ext" extends "Payment Export Data"
{
    fields
    {
        field(20100; "AMC Recip. Bank Acc. Currency"; Code[10])
        {
            Caption = 'Recipient Bank Account Currency';
            TableRelation = Currency;
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
