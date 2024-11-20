codeunit 12219 "Create VAT Identifier IT"
{
    trigger OnRun()
    var
        CreateVATPostingGroupsIT: Codeunit "Create VAT Posting Groups IT";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        ContosoVATIdentifier: Codeunit "Contoso VAT Identifier";
    begin
        ContosoVATIdentifier.InsertVATIdentifier(CreateVATPostingGroupsIT.E13(), TaxExemptArt13Lbl);
        ContosoVATIdentifier.InsertVATIdentifier(CreateVATPostingGroupsIT.IND50(), Vat2050NondeductibleLbl);
        ContosoVATIdentifier.InsertVATIdentifier(CreateVATPostingGroupsIT.IND100(), Vat20100NondeductibleLbl);
        ContosoVATIdentifier.InsertVATIdentifier(CreateVATPostingGroupsIT.NI8(), NonTaxableArt81Lbl);
        ContosoVATIdentifier.InsertVATIdentifier(NI9(), NonTaxableArt9Lbl);
        ContosoVATIdentifier.InsertVATIdentifier(NI41(), NIArt41DL33193Lbl);
        ContosoVATIdentifier.InsertVATIdentifier(FCI2(), FCIArt2Lbl);
        ContosoVATIdentifier.InsertVATIdentifier(E10(), TaxExemptArt10Lbl);
        ContosoVATIdentifier.InsertVATIdentifier(CreateVATPostingGroups.Reduced(), VAT10Lbl);
        ContosoVATIdentifier.InsertVATIdentifier(CreateVATPostingGroups.Standard(), VAT20Lbl);
        ContosoVATIdentifier.InsertVATIdentifier(CreateVATPostingGroups.Zero(), NonTaxableLbl);
    end;

    procedure E10(): Code[20]
    begin
        exit(E10Tok);
    end;

    procedure FCI2(): Code[20]
    begin
        exit(FCI2Tok);
    end;

    procedure NI41(): Code[20]
    begin
        exit(NI41Tok);
    end;

    procedure NI9(): Code[20]
    begin
        exit(NI9Tok);
    end;

    var
        E10Tok: Label 'E10', MaxLength = 20;
        FCI2Tok: Label 'FCI2', MaxLength = 20;
        NI41Tok: Label 'NI41', MaxLength = 20;
        NI9Tok: Label 'NI9', MaxLength = 20;
        TaxExemptArt13Lbl: Label 'Tax exempt - art. 13', MaxLength = 50;
        Vat20100NondeductibleLbl: Label 'VAT 20% - 100% Nondeductible', MaxLength = 50;
        Vat2050NondeductibleLbl: Label 'VAT 20% - 50% Nondeductible', MaxLength = 50;
        NonTaxableArt81Lbl: Label 'Non Taxable - Art. 8/1', MaxLength = 50;
        VAT10Lbl: Label 'VAT 10%', MaxLength = 50;
        VAT20Lbl: Label 'VAT 20%', MaxLength = 50;
        NonTaxableLbl: Label 'Non taxable', MaxLength = 50;
        NonTaxableArt9Lbl: Label 'Non Taxable - Art. 9', MaxLength = 50;
        NIArt41DL33193Lbl: Label 'N.I. Art. 41  DL 331/93', MaxLength = 50;
        FCIArt2Lbl: Label 'F.C.I. Art.2', MaxLength = 50;
        TaxExemptArt10Lbl: Label 'Tax exempt - art. 10', MaxLength = 50;
}