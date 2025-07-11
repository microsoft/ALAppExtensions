// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

codeunit 31108 "Cash Desk Single Instance CZP"
{
    SingleInstance = true;

    var
        ShowAllBankAccountType: Boolean;

    procedure SetShowAllBankAccountType(NewShowAllBankAccountType: Boolean)
    begin
        ShowAllBankAccountType := NewShowAllBankAccountType;
    end;

    procedure GetShowAllBankAccountType(): Boolean
    begin
        exit(ShowAllBankAccountType);
    end;
}
