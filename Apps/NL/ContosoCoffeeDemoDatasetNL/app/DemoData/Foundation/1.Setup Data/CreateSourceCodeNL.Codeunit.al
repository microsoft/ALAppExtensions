// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;

codeunit 11543 "Create Source Code NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        ContosoSourceCode: Codeunit "Contoso Source Code";
    begin
        ContosoSourceCode.InsertSourceCode(ABNBankJnl(), ABNBankJnlDescLbl);
        ContosoSourceCode.InsertSourceCode(GiroJnl(), GiroJnlDescLbl);
        ContosoSourceCode.InsertSourceCode(PaymtProc(), PaymtProcDescLbl);
        ContosoSourceCode.InsertSourceCode(RecptsProc(), RecptsProcDescLbl);
    end;

    procedure ABNBankJnl(): Code[10]
    begin
        exit(ABNBankJnlTok)
    end;

    procedure GiroJnl(): Code[10]
    begin
        exit(GiroJnlTok)
    end;

    procedure PaymtProc(): Code[10]
    begin
        exit(PaymtProcTok)
    end;

    procedure RecptsProc(): Code[10]
    begin
        exit(RecptsProcTok)
    end;

    var
        ABNBankJnlTok: Label 'ABNBANKJNL', MaxLength = 10, Locked = true;
        ABNBankJnlDescLbl: Label 'ABN Bank Journal', MaxLength = 100;
        GiroJnlTok: Label 'GIROJNL', MaxLength = 10, Locked = true;
        GiroJnlDescLbl: Label 'Giro Journal', MaxLength = 100;
        PaymtProcTok: Label 'PAYMTPROC', MaxLength = 10, Locked = true;
        PaymtProcDescLbl: Label 'Payments in Process', MaxLength = 100;
        RecptsProcTok: Label 'RECPTSPROC', MaxLength = 10, Locked = true;
        RecptsProcDescLbl: Label 'Receipts in Process', MaxLength = 100;
}
