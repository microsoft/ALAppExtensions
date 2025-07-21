// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

table 10541 "MTD Session Fraud Prev. Hdr"
{
    Caption = 'HMRC Session Fraud Prevention Header';

    fields
    {
        field(1; Header; Code[100])
        {
            Caption = 'Header';
            DataClassification = SystemMetadata;
        }
        field(2; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; Header)
        {
        }
    }

    internal procedure SafeInsert(NewHeader: Code[100]; NewValue: Text)
    begin
        Header := NewHeader;
        Value := CopyStr(NewValue, 1, MaxStrLen(Value));
        if Insert() then;
    end;

    internal procedure SafeInsertFromDefault(NewHeader: Code[100])
    var
        MTDDefaultFraudPrevHdr: Record "MTD Default Fraud Prev. Hdr";
    begin
        if MTDDefaultFraudPrevHdr.Get(NewHeader) then
            if MTDDefaultFraudPrevHdr.Value <> '' then
                SafeInsert(MTDDefaultFraudPrevHdr.Header, MTDDefaultFraudPrevHdr.Value);
    end;
}
