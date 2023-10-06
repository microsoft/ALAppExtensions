// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ReceivablesPayables;

tableextension 18245 "GST Invoice Posting Buffer" extends "Invoice Posting Buffer"
{
    fields
    {
        field(18244; "FA Non-Availment"; Boolean)
        {
            Caption = 'FA Non-Availment';
            DataClassification = CustomerContent;
        }
        field(18245; "FA Non-Availment Amount"; Decimal)
        {
            Caption = 'FA Non-Availment Amount';
            DataClassification = CustomerContent;
        }
        field(18246; "FA Availment"; Boolean)
        {
            Caption = 'FA Availment';
            DataClassification = CustomerContent;
        }
        field(18247; "FA Custom Duty Amount"; Decimal)
        {
            Caption = 'FA Custom Duty Amount';
            DataClassification = CustomerContent;
        }
    }

}
