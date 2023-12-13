// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using System.Security.AccessControl;
using System.Security.User;

codeunit 31348 "User Setup Adv. Management CZB"
{
    Permissions = tabledata "User Setup" = m;
    TableNo = "User Setup";

    trigger OnRun()
    begin
        Rec.Modify();
    end;

    var
        UserSetup: Record "User Setup";
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
        UserSetupLineTypeCZL: Enum "User Setup Line Type CZL";

    procedure CheckBankAccountNo(Type: Enum "User Setup Line Type CZL"; BankAccountNo: Code[20])
    var
        PaymentOrderDeniedErr: Label 'Access to payment orders of bank account %1 is not allowed in extended user check.', Comment = '%1 = bank account number';
        BankStatementDeniedErr: Label 'Access to bank statements of bank account %1 is not allowed in extended user check.', Comment = '%1 = bank account number';
    begin
        GetUserSetup();
        if not UserSetup."Check Payment Orders CZB" and not UserSetup."Check Bank Statements CZB" then
            exit;

        if not UserSetupAdvManagementCZL.CheckUserSetupLineCZL(UserSetup."User ID", Type, BankAccountNo) then
            case true of
                (Type = UserSetupLineTypeCZL::"Payment Order") and UserSetup."Check Payment Orders CZB":
                    Error(PaymentOrderDeniedErr, BankAccountNo);
                (Type = UserSetupLineTypeCZL::"Bank Statement") and UserSetup."Check Bank Statements CZB":
                    Error(BankStatementDeniedErr, BankAccountNo);
            end;
    end;

    local procedure GetUserSetup()
    var
        User: Record User;
    begin
        if UserSetup."User ID" <> CopyStr(UserId(), 1, MaxStrLen(User."User Name")) then
            if not UserSetup.Get(CopyStr(UserId(), 1, MaxStrLen(User."User Name"))) then
                Clear(UserSetup);
    end;
}
