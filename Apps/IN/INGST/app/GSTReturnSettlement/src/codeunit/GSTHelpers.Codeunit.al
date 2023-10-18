// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

codeunit 18317 "GST Helpers"
{
    procedure GetGSTPayableAccountNo(StateCode: Code[10]; GSTComponentCode: Code[30]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
    begin
        GSTPostingSetup.Get(StateCode, GetComponentID(GSTComponentCode));
        GSTPostingSetup.TestField("Payable Account");
        exit(GSTPostingSetup."Payable Account");
    end;

    procedure GetGSTReceivableDistAccountNo(StateCode: Code[10]; GSTComponentCode: Code[30]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
    begin
        GSTPostingSetup.Get(StateCode, GetComponentID(GSTComponentCode));
        GSTPostingSetup.TestField("Receivable Acc. (Dist)");
        exit(GSTPostingSetup."Receivable Acc. (Dist)");
    end;

    procedure GetGSTReceivableAccountNo(StateCode: Code[10]; GSTComponentCode: Code[30]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
    begin
        GSTPostingSetup.Get(StateCode, GetComponentID(GSTComponentCode));
        GSTPostingSetup.TestField("Receivable Account");
        exit(GSTPostingSetup."Receivable Account");
    end;

    procedure GetGSTExpenseAccountNo(StateCode: Code[10]; GSTComponentCode: Code[30]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
    begin
        GSTPostingSetup.Get(StateCode, GetComponentID(GSTComponentCode));
        GSTPostingSetup.TestField("Expense Account");
        exit(GSTPostingSetup."Expense Account");
    end;

    procedure GetGSTMismatchAccountNo(StateCode: Code[10]; GSTComponentCode: Code[30]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
    begin
        GSTPostingSetup.Get(StateCode, GetComponentID(GSTComponentCode));
        GSTPostingSetup.TestField("GST Credit Mismatch Account");
        exit(GSTPostingSetup."GST Credit Mismatch Account");
    end;

    procedure GetGSTRcvblInterimAccountNo(StateCode: Code[10]; GSTComponentCode: Code[30]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
    begin
        GSTPostingSetup.Get(StateCode, GetComponentID(GSTComponentCode));
        GSTPostingSetup.TestField("Receivable Account (Interim)");
        exit(GSTPostingSetup."Receivable Account (Interim)");
    end;

    procedure GetGSTPayableInterimAccountNo(StateCode: Code[10]; GSTComponentCode: Code[30]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
    begin
        GSTPostingSetup.Get(StateCode, GetComponentID(GSTComponentCode));
        GSTPostingSetup.TestField("Payables Account (Interim)");
        exit(GSTPostingSetup."Payables Account (Interim)");
    end;

    local procedure GetComponentID(ComponentName: Code[30]): Decimal
    var
        GSTSetup: Record "GST Setup";
        TaxComponent: Record "Tax Component";
    begin
        if not GSTSetup.Get() then
            exit;
        GSTSetup.TestField("GST Tax Type");

        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(Name, ComponentName);
        if TaxComponent.FindFirst() then
            exit(TaxComponent.Id);
    end;
}
