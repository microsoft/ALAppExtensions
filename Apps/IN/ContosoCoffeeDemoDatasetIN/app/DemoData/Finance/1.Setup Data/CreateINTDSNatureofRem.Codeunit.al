// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 19040 "Create IN TDS Nature of Rem."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
    begin
        ContosoINTaxSetup.InsertTDSNatureOfRemittance(NatureofRemittance16(), NatureofRemittance16DescLbl);
        ContosoINTaxSetup.InsertTDSNatureOfRemittance(NatureofRemittance21(), NatureofRemittance21DescLbl);
        ContosoINTaxSetup.InsertTDSNatureOfRemittance(NatureofRemittance27(), NatureofRemittance27DescLbl);
        ContosoINTaxSetup.InsertTDSNatureOfRemittance(NatureofRemittance28(), NatureofRemittance28DescLbl);
        ContosoINTaxSetup.InsertTDSNatureOfRemittance(NatureofRemittance31(), NatureofRemittance31DescLbl);
        ContosoINTaxSetup.InsertTDSNatureOfRemittance(NatureofRemittance49(), NatureofRemittance49DescLbl);
        ContosoINTaxSetup.InsertTDSNatureOfRemittance(NatureofRemittance52(), NatureofRemittance52DescLbl);
        ContosoINTaxSetup.InsertTDSNatureOfRemittance(NatureofRemittance99(), NatureofRemittance99DescLbl);

    end;

    procedure NatureofRemittance16(): Code[10]
    begin
        exit(NatureofRemittance16Tok);
    end;

    procedure NatureofRemittance21(): Code[10]
    begin
        exit(NatureofRemittance21Tok);
    end;

    procedure NatureofRemittance27(): Code[10]
    begin
        exit(NatureofRemittance27Tok);
    end;

    procedure NatureofRemittance28(): Code[10]
    begin
        exit(NatureofRemittance28Tok);
    end;

    procedure NatureofRemittance31(): Code[10]
    begin
        exit(NatureofRemittance31Tok);
    end;

    procedure NatureofRemittance49(): Code[10]
    begin
        exit(NatureofRemittance49Tok);
    end;

    procedure NatureofRemittance52(): Code[10]
    begin
        exit(NatureofRemittance52Tok);
    end;

    procedure NatureofRemittance99(): Code[10]
    begin
        exit(NatureofRemittance99Tok);
    end;

    var
        NatureofRemittance16Tok: Label '16', MaxLength = 10;
        NatureofRemittance21Tok: Label '21', MaxLength = 10;
        NatureofRemittance27Tok: Label '27', MaxLength = 10;
        NatureofRemittance28Tok: Label '28', MaxLength = 10;
        NatureofRemittance31Tok: Label '31', MaxLength = 10;
        NatureofRemittance49Tok: Label '49', MaxLength = 10;
        NatureofRemittance52Tok: Label '52', MaxLength = 10;
        NatureofRemittance99Tok: Label '99', MaxLength = 10;
        NatureofRemittance16DescLbl: Label 'DIVIDEND', MaxLength = 50;
        NatureofRemittance21DescLbl: Label 'FEES FOR TECHNICAL SERVICES/ FEES FOR INCLUDED SER', MaxLength = 50;
        NatureofRemittance27DescLbl: Label 'INTEREST PAYMENT', MaxLength = 50;
        NatureofRemittance28DescLbl: Label 'INVESTMENT INCOME ', MaxLength = 50;
        NatureofRemittance31DescLbl: Label 'LONG TERM CAPITAL GAINS ', MaxLength = 50;
        NatureofRemittance49DescLbl: Label 'ROYALTY', MaxLength = 50;
        NatureofRemittance52DescLbl: Label 'SHORT TERM CAPITAL GAINS ', MaxLength = 50;
        NatureofRemittance99DescLbl: Label 'OTHER INCOME / OTHER (NOT IN THE NATURE OF INCOME)', MaxLength = 50;

}
