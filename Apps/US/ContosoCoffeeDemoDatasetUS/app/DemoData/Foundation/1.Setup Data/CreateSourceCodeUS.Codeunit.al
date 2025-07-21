// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.Foundation.AuditCodes;
using Microsoft.DemoTool.Helpers;

codeunit 10550 "Create Source Code US"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SourceCodeSetup: Record "Source Code Setup";
        ContosoSourceCode: Codeunit "Contoso Source Code";
    begin
        ContosoSourceCode.InsertSourceCode(COMPRTAX(), DateCompressTaxEntriesLbl);
        ContosoSourceCode.InsertSourceCode(TAXSTMT(), CalculatePostTaxSettlementLbl);

        SourceCodeSetup.Get();
        SourceCodeSetup.Validate("VAT Settlement", TAXSTMT());
        SourceCodeSetup.Validate("Compress VAT Entries", COMPRTAX());
        SourceCodeSetup.Modify(true);
    end;

    procedure COMPRTAX(): Code[10]
    begin
        exit(COMPRTAXTok);
    end;

    procedure TAXSTMT(): Code[10]
    begin
        exit(TAXSTMTTok);
    end;

    var
        COMPRTAXTok: Label 'COMPRTAX', MaxLength = 10, Locked = true;
        DateCompressTaxEntriesLbl: Label 'Date Compress Tax Entries', MaxLength = 100;
        TAXSTMTTok: Label 'TAXSTMT', MaxLength = 10, Locked = true;
        CalculatePostTaxSettlementLbl: Label 'Calculate and Post Tax Settlement', MaxLength = 100;
}
