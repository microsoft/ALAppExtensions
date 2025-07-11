// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

table 10540 "MTD Default Fraud Prev. Hdr"
{
    Caption = 'HMRC Default Fraud Prevention Header';

    fields
    {
        field(1; Header; Code[100])
        {
            Caption = 'Header';
            DataClassification = SystemMetadata;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(3; Value; Text[250])
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

    internal procedure SafeInsert(NewHeader: Code[100]; NewDescription: Text; NewValue: Text)
    begin
        if not Get(NewHeader) then begin
            Header := NewHeader;
            Description := CopyStr(NewDescription, 1, MaxStrLen(Description));
            Value := CopyStr(NewValue, 1, MaxStrLen(Value));
            Insert();
        end;
    end;

    internal procedure FromSessionHeader(MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr")
    begin
        Header := MTDSessionFraudPrevHdr.Header;
        Value := MTDSessionFraudPrevHdr.Value;
        if Insert() then;
    end;
}
