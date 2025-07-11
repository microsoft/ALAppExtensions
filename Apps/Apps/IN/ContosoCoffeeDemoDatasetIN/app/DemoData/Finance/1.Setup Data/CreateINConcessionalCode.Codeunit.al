// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 19049 "Create IN Concessional Code"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
    begin
        ContosoINTaxSetup.InsertConcessionalCode(ConcessionalCodesA(), ConcessionalCodesALbl);
        ContosoINTaxSetup.InsertConcessionalCode(ConcessionalCodesB(), ConcessionalCodesBLbl);
        ContosoINTaxSetup.InsertConcessionalCode(ConcessionalCodesC(), ConcessionalCodesCLbl);
        ContosoINTaxSetup.InsertConcessionalCode(ConcessionalCodesR(), ConcessionalCodesRLbl);
        ContosoINTaxSetup.InsertConcessionalCode(ConcessionalCodesS(), ConcessionalCodesSLbl);
        ContosoINTaxSetup.InsertConcessionalCode(ConcessionalCodesT(), ConcessionalCodesTLbl);
        ContosoINTaxSetup.InsertConcessionalCode(ConcessionalCodesY(), ConcessionalCodesYLbl);
        ContosoINTaxSetup.InsertConcessionalCode(ConcessionalCodesZ(), ConcessionalCodesZLbl);
    end;

    procedure ConcessionalCodesA(): Code[10]
    begin
        exit(ConcessionalCodesATok);
    end;

    procedure ConcessionalCodesB(): Code[10]
    begin
        exit(ConcessionalCodesBTok);
    end;

    procedure ConcessionalCodesC(): Code[10]
    begin
        exit(ConcessionalCodesCTok);
    end;

    procedure ConcessionalCodesR(): Code[10]
    begin
        exit(ConcessionalCodesRTok);
    end;

    procedure ConcessionalCodesS(): Code[10]
    begin
        exit(ConcessionalCodesSTok);
    end;

    procedure ConcessionalCodesT(): Code[10]
    begin
        exit(ConcessionalCodesTTok);
    end;

    procedure ConcessionalCodesY(): Code[10]
    begin
        exit(ConcessionalCodesYTok);
    end;

    procedure ConcessionalCodesZ(): Code[10]
    begin
        exit(ConcessionalCodesZTok);
    end;

    var
        ConcessionalCodesATok: Label 'A', MaxLength = 10;
        ConcessionalCodesBTok: Label 'B', MaxLength = 10;
        ConcessionalCodesCTok: Label 'C', MaxLength = 10;
        ConcessionalCodesRTok: Label 'R', MaxLength = 10;
        ConcessionalCodesSTok: Label 'S', MaxLength = 10;
        ConcessionalCodesTTok: Label 'T', MaxLength = 10;
        ConcessionalCodesYTok: Label 'Y', MaxLength = 10;
        ConcessionalCodesZTok: Label 'Z', MaxLength = 10;
        ConcessionalCodesALbl: Label 'Lower/no deduction Sec 197', MaxLength = 30;
        ConcessionalCodesBLbl: Label 'No deduction Sec 197A', MaxLength = 30;
        ConcessionalCodesCLbl: Label 'Non-availability of PAN.', MaxLength = 30;
        ConcessionalCodesRLbl: Label 'Deduction Sec 194A.', MaxLength = 30;
        ConcessionalCodesSLbl: Label 'Software acquired Sec 194J.', MaxLength = 30;
        ConcessionalCodesTLbl: Label 'Transporter Transaction.', MaxLength = 30;
        ConcessionalCodesYLbl: Label 'Not exceeded threshold limit.', MaxLength = 30;
        ConcessionalCodesZLbl: Label 'Payment under Sec 197A (1F).', MaxLength = 30;
}
