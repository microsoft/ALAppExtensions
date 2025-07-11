// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;

tableextension 20104 "AMC Bank Paym. Method Ext" extends "Payment Method"
{
    fields
    {
        field(20100; "AMC Bank Pmt. Type"; Text[50])
        {
            Caption = 'Bank Pmt. Type';
            TableRelation = "AMC Bank Pmt. Type";
            DataClassification = CustomerContent;
        }
    }

}

