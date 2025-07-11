// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

codeunit 31115 "EET Cash Register Default CZL" implements "EET Cash Register CZL"
{
    procedure GetCashRegisterName(CashRegisterNo: Code[20]): Text[100]
    var
        DefaultCashRegisterNameTxt: Label 'Default cash register for simple registration';
    begin
        exit(DefaultCashRegisterNameTxt);
    end;

    procedure LookupCashRegisterNo(var CashRegisterNo: Code[20]): Boolean
    begin
        CashRegisterNo := '';
        exit(false);
    end;

    procedure ShowDocument(CashRegisterNo: Code[20]; DocumentNo: Code[20])
    var
        NotSupportedErr: Label 'The action is not supported.';
    begin
        Error(NotSupportedErr);
    end;
}
