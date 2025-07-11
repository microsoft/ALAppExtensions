// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

table 10539 "MTD Missing Fraud Prev. Hdr"
{
    Caption = 'HMRC Missing Fraud Prevention Header';

    fields
    {
        field(1; Header; Code[100])
        {
            Caption = 'Header';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Header)
        {
        }
    }

    internal procedure SafeInsert(HeaderValue: Code[100])
    begin
        Header := HeaderValue;
        if Insert() then;
    end;
}
