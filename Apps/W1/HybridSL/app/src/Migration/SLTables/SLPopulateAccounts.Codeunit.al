// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

codeunit 47019 "SL Populate Accounts"
{
    Access = Internal;
    internal procedure PopulateSLAccounts()
    var
        SLAccount: Record "SL Account";
        SLAccountStaging: Record "SL Account Staging";
        SLCompanyID: Text;
    begin
        if not SLAccount.FindSet() then
            exit;

        SLCompanyID := CompanyName.Trim();
        SLAccountStaging.DeleteAll();
        repeat
            Clear(SLAccountStaging);

            SLAccountStaging.AcctNum := SLAccount.Acct;
            SLAccountStaging.AccountCategory := ConvertAccountCategoryFromAcctType(SLAccount.AcctType);
            if SLAccount.Active = 0 then
                SLAccountStaging.Active := false
            else
                SLAccountStaging.Active := true;
            SLAccountStaging.Name := SLAccount.Descr;
            SLAccountStaging.SearchName := SLAccount.Descr;
            SLAccountStaging.DebitCredit := 0;
            SLAccountStaging.IncomeBalance := ConvertIncomeBalanceTypeFromAccountType(SLAccount.AcctType);

            SLAccountStaging.Insert();
        until SLAccount.Next() = 0;
    end;

    internal procedure ConvertAccountCategoryFromAcctType(SLAccountType: Text[2]): Integer
    begin
        case (SLAccountType.Trim().Substring(2, 1)) of
            'A':
                exit(1);
            'L':
                exit(2);
            'I':
                exit(4);
            'E':
                exit(6);
        end;
    end;

    internal procedure ConvertIncomeBalanceTypeFromAccountType(SLAccountType: Text[2]): Boolean
    begin
        case (SLAccountType.Trim().Substring(2, 1)) of
            'A':
                exit(true);
            'L':
                exit(true);
            'I':
                exit(false);
            'E':
                exit(false);
        end;
    end;
}