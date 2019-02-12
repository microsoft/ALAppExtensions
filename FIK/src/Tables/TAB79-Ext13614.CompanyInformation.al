// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13614 CompanyInformation extends "Company Information"
{
    fields
    {
        field(13651; BankCreditorNo; Code[8])
        {
            Caption = 'Bank Creditor No.';
            trigger OnValidate();
            begin
                IF BankCreditorNo = '' THEN
                    EXIT;
                IF STRLEN(BankCreditorNo) <> MAXSTRLEN(BankCreditorNo) THEN
                    ERROR(STRSUBSTNO(BankCreditorNumberLengthErr, FIELDCAPTION(BankCreditorNo)));
            end;
        }
    }
    var
        BankCreditorNumberLengthErr: Label '%1 must be an 8-digit number.';
}