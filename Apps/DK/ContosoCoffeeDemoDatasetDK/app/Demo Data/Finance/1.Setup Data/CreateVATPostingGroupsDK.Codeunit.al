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
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertVATProductPostingGroup(Vat25Serv(), '');
    end;

    procedure UpdateVATPostingSetup()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateGLAccDK: Codeunit "Create GL Acc. DK";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);

        ContosoPostingSetup.InsertVATPostingSetup('', Vat25Serv(), CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), Vat25Serv(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroups.Standard(), CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), CreateVATPostingGroups.Standard(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroups.Zero(), CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', CreateVATPostingGroups.Zero(), false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), Vat25Serv(), CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), Vat25Serv(), 25, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), CreateVATPostingGroups.Standard(), 25, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', CreateVATPostingGroups.Zero(), false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), Vat25Serv(), CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), Vat25Serv(), 25, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccDK.Euacquisitiontax(), '', true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), CreateVATPostingGroups.Standard(), 25, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccDK.Euacquisitiontax(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.Zero(), CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', CreateVATPostingGroups.Zero(), false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), Vat25Serv(), CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), Vat25Serv(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroups.Standard(), CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), CreateVATPostingGroups.Standard(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroups.Zero(), CreateGLAccDK.SalestaxpayableSalesTax(), CreateGLAccDK.SalestaxreceivableInputTax(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', CreateVATPostingGroups.Zero(), false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Posting Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertVatPostingSetup(var Rec: Record "VAT Posting Setup")
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        Rec.SetRange("VAT Prod. Posting Group", CreateVATPostingGroups.Reduced());
        if Rec.FindSet() then
            Rec.Delete(true);
    end;

    procedure Vat25Serv(): Code[20]
    begin
        exit(Vat25ServTok);
    end;

    var
        Vat25ServTok: Label 'VAT25SERV', Locked = true;
}