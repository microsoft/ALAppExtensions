// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 19006 "Create IN Act Applicable"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
    begin
        ContosoINTaxSetup.InsertActApplicable(IncomeTaxAct(), IncomeTaxActLbl);
        ContosoINTaxSetup.InsertActApplicable(DTAA(), DTAALbl);
    end;

    procedure IncomeTaxAct(): Code[10]
    begin
        exit(IncomeTaxActTok);
    end;

    procedure DTAA(): Code[10]
    begin
        exit(DTAATok);
    end;

    var
        IncomeTaxActTok: Label 'A', MaxLength = 10, Locked = true;
        DTAATok: Label 'B', MaxLength = 10, Locked = true;
        IncomeTaxActLbl: Label 'TDS rate as per Income Tax Act', MaxLength = 50;
        DTAALbl: Label 'TDS rate as per DTAA', MaxLength = 50;
}
