// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;

codeunit 11548 "Create Data Exchange NL"
{
    trigger OnRun()
    var
        ContosoDataExchange: Codeunit "Contoso Data Exchange";
        FolderNameLbl: Label 'PostingExchangeDefinitions', MaxLength = 100, Locked = true;
    begin
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + SEPACAMTNL() + '.xml');
        ContosoDataExchange.ImportDataExchangeDefinition(FolderNameLbl + '/' + SEPACAMT05300108NL() + '.xml');
    end;

    procedure SEPACAMTNL(): Code[20]
    begin
        exit('SEPA CAMT-NL')
    end;

    procedure SEPACAMT05300108NL(): Code[20]
    begin
        exit('SEPA CAMT 053-08-NL')
    end;
}
