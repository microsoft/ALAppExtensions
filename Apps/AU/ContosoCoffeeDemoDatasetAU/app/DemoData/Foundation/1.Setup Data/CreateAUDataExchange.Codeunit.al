// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using System.IO;
using Microsoft.DemoTool.Helpers;

codeunit 17172 "Create AU Data Exchange"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoDataExchange: Codeunit "Contoso Data Exchange";
        FolderNameLbl: Label 'PostingExchangeDefinitions', MaxLength = 100, Locked = true;
    begin
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + OCRInvoiceAU() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + OCRCreditMemoAU() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + PeppolCreditMemoAU() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + PeppolInvoiceAU() + '.xml');

        DeleteW1DataExchanges();
    end;

    local procedure DeleteW1DataExchanges()
    var
        DataExchangeDef: Record "Data Exch. Def";
        DataExchangeType: Record "Data Exchange Type";
        CreateDataExchange: Codeunit "Create Data Exchange";
    begin
        DataExchangeDef.Get(CreateDataExchange.OCRInvoice());
        DataExchangeDef.Delete(true);

        DataExchangeDef.Get(CreateDataExchange.OCRCreditMemo());
        DataExchangeDef.Delete(true);

        DataExchangeDef.Get(CreateDataExchange.PeppolCreditMemo());
        DataExchangeDef.Delete(true);

        DataExchangeDef.Get(CreateDataExchange.PeppolInvoice());
        DataExchangeDef.Delete(true);

        DataExchangeType.DeleteAll();
    end;

    procedure OCRInvoiceAU(): Code[20]
    begin
        exit('OCRINVOICE-AU');
    end;

    procedure OCRCreditMemoAU(): Code[20]
    begin
        exit('OCRCREDITMEMO-AU');
    end;

    procedure PeppolCreditMemoAU(): Code[20]
    begin
        exit('PEPPOLCREDITMEMO-AU');
    end;

    procedure PeppolInvoiceAU(): Code[20]
    begin
        exit('PEPPOLINVOICE-AU');
    end;
}
