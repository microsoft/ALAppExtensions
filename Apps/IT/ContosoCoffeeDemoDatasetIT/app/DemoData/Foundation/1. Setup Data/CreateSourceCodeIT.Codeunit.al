// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;

codeunit 12227 "Create Source Code IT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoSourceCode: Codeunit "Contoso Source Code";
    begin
        ContosoSourceCode.InsertSourceCode(BankTransf(), BankTransfersLbl);
        ContosoSourceCode.InsertSourceCode(Start(), OpeningEntriesLbl);
        ContosoSourceCode.InsertSourceCode(RIBA(), BankReceiptsLbl);
    end;

    procedure BankTransf(): Code[10]
    begin
        exit(BankTransfTok);
    end;

    procedure RIBA(): Code[10]
    begin
        exit(RIBATok);
    end;

    procedure Start(): Code[10]
    begin
        exit(StartTok);
    end;

    var
        RIBATok: Label 'RIBA', MaxLength = 10;
        BankTransfTok: Label 'BANKTRANSF', MaxLength = 10;
        StartTok: Label 'START', MaxLength = 10;
        BankTransfersLbl: Label 'Bank Transfers', MaxLength = 100;
        OpeningEntriesLbl: Label 'Opening Entries', MaxLength = 100;
        BankReceiptsLbl: Label 'Bank Receipts', MaxLength = 100;
}
