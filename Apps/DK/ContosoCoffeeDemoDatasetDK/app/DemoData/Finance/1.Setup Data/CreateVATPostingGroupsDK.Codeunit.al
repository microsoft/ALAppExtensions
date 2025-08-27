// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.Enums;

codeunit 13713 "Create Vat Posting Groups DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
    end;

    local procedure InsertVATProductPostingGroup()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        FinanceModuleSetup.Get();

        if FinanceModuleSetup."VAT Prod. Post Grp. Reduced" = '' then begin
            ContosoPostingGroup.InsertVATProductPostingGroup(Vat25Serv(), '');
            FinanceModuleSetup.Validate("VAT Prod. Post Grp. Reduced", Vat25Serv());
        end;

        FinanceModuleSetup.Modify(true);
    end;

    procedure UpdateVATPostingSetup()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateGLAccDK: Codeunit "Create GL Acc. DK";
    begin
        FinanceModuleSetup.Get();

        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);

        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 25, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 25, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 25, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccDK.Euacquisitiontax(), '', true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 25, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccDK.Euacquisitiontax(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), FinanceModuleSetup."VAT Prod. Post Grp. Reduced", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), FinanceModuleSetup."VAT Prod. Post Grp. Standard", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', FinanceModuleSetup."VAT Prod. Post Grp. NO VAT", false);
    end;

    procedure Vat25Serv(): Code[20]
    begin
        exit(Vat25ServTok);
    end;

    var
        Vat25ServTok: Label 'VAT25SERV', Locked = true;
}
