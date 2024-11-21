codeunit 11528 "Create Elec Tax Declaration NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertElecTaxDeclarationSetup();
        InsertElecTaxDeclVATCategory();
    end;

    local procedure InsertElecTaxDeclarationSetup()
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        ContosoBankNL: Codeunit "Contoso Bank NL";
        CreateNoSeriesNL: Codeunit "Create No. Series NL";
        CreateSalespersonPurchaser: Codeunit "Create Salesperson/Purchaser";
    begin
        SalespersonPurchaser.Get(CreateSalespersonPurchaser.OtisFalls());
        ContosoBankNL.InsertElecTaxDeclarationSetup(CreateNoSeriesNL.ElVATDecl(), CreateNoSeriesNL.ElICLDecl(), CopyStr(SalespersonPurchaser.Name, 1, 35), '6549-3216-7415');
        InsertElecTaxDeclVATCategory();
    end;

    local procedure InsertElecTaxDeclVATCategory()
    var
        ContosoBankNL: Codeunit "Contoso Bank NL";
        Category: Option " ",,,"1. By Us (Domestic)",,,"2. To Us (Domestic)",,,"3. By Us (Foreign)",,,"4. To Us (Foreign)",,,,,,"5. Calculation";
        ByUsDomestic: Option " ",,,"1a. Sales Amount (High Rate)",,,"1a. Tax Amount (High Rate)",,,"1b. Sales Amount (Low Rate)",,,"1b. Tax Amount (Low Rate)",,,"1c. Sales Amount (Other Non-Zero Rates)",,,"1c. Tax Amount (Other Non-Zero Rates)",,,"1d. Sales Amount (Private Use)",,,"1d. Tax Amount (Private Use)",,,"1e. Sales Amount (Non-Taxed)";
        ToUsDomestic: Option " ",,,"2a. Sales Amount (Tax Withheld)",,,"2a. Tax Amount (Tax Withheld)";
        ByUsForeign: Option " ",,,"3a. Sales Amount (Non-EU)",,,"3b. Sales Amount (EU)",,,"3c. Sales Amount (Installation)";
        ToUsForeign: Option " ",,,"4a. Purchase Amount (Non-EU)",,,"4a. Tax Amount (Non-EU)",,,"4b. Purchase Amount (EU)",,,"4b. Tax Amount (EU)";
        Calculation: Option " ",,,"5a. Tax Amount Due (Subtotal)",,,"5b. Tax Amount (Paid in Advance)",,,"5d. Small Entrepeneurs",,,"5e. Estimate (Previous Declaration)",,,"5f. Estimate (This Declaration)",,,"5g. Tax Amount To Pay/Claim";
    begin
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory1A1(), Category::"1. By Us (Domestic)", ByUsDomestic::"1a. Sales Amount (High Rate)", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::" ", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory1A2(), Category::"1. By Us (Domestic)", ByUsDomestic::"1a. Tax Amount (High Rate)", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::" ", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory1B1(), Category::"1. By Us (Domestic)", ByUsDomestic::"1b. Sales Amount (Low Rate)", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::" ", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory1B2(), Category::"1. By Us (Domestic)", ByUsDomestic::"1b. Tax Amount (Low Rate)", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::" ", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory1C1(), Category::"1. By Us (Domestic)", ByUsDomestic::"1c. Sales Amount (Other Non-Zero Rates)", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::" ", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory1C2(), Category::"1. By Us (Domestic)", ByUsDomestic::"1c. Tax Amount (Other Non-Zero Rates)", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::" ", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory1D1(), Category::"1. By Us (Domestic)", ByUsDomestic::"1d. Sales Amount (Private Use)", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::" ", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory1D2(), Category::"1. By Us (Domestic)", ByUsDomestic::"1d. Tax Amount (Private Use)", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::" ", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory1E(), Category::"1. By Us (Domestic)", ByUsDomestic::"1e. Sales Amount (Non-Taxed)", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::" ", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory2A1(), Category::"2. To Us (Domestic)", ByUsDomestic::" ", ToUsDomestic::"2a. Sales Amount (Tax Withheld)", ByUsForeign::" ", ToUsForeign::" ", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory2A2(), Category::"2. To Us (Domestic)", ByUsDomestic::" ", ToUsDomestic::"2a. Tax Amount (Tax Withheld)", ByUsForeign::" ", ToUsForeign::" ", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory3A(), Category::"3. By Us (Foreign)", ByUsDomestic::" ", ToUsDomestic::" ", ByUsForeign::"3a. Sales Amount (Non-EU)", ToUsForeign::" ", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory3B(), Category::"3. By Us (Foreign)", ByUsDomestic::" ", ToUsDomestic::" ", ByUsForeign::"3b. Sales Amount (EU)", ToUsForeign::" ", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory3C(), Category::"3. By Us (Foreign)", ByUsDomestic::" ", ToUsDomestic::" ", ByUsForeign::"3c. Sales Amount (Installation)", ToUsForeign::" ", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory4A1(), Category::"4. To Us (Foreign)", ByUsDomestic::" ", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::"4a. Purchase Amount (Non-EU)", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory4A2(), Category::"4. To Us (Foreign)", ByUsDomestic::" ", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::"4a. Tax Amount (Non-EU)", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory4B1(), Category::"4. To Us (Foreign)", ByUsDomestic::" ", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::"4b. Purchase Amount (EU)", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory4B2(), Category::"4. To Us (Foreign)", ByUsDomestic::" ", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::"4b. Tax Amount (EU)", Calculation::" ", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory5A(), Category::"5. Calculation", ByUsDomestic::" ", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::" ", Calculation::"5a. Tax Amount Due (Subtotal)", false);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory5B(), Category::"5. Calculation", ByUsDomestic::" ", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::" ", Calculation::"5b. Tax Amount (Paid in Advance)", false);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory5D(), Category::"5. Calculation", ByUsDomestic::" ", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::" ", Calculation::"5d. Small Entrepeneurs", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory5E(), Category::"5. Calculation", ByUsDomestic::" ", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::" ", Calculation::"5e. Estimate (Previous Declaration)", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory5F(), Category::"5. Calculation", ByUsDomestic::" ", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::" ", Calculation::"5f. Estimate (This Declaration)", true);
        ContosoBankNL.InsertElecTaxDeclVATCategory(ElecVatCategory5G(), Category::"5. Calculation", ByUsDomestic::" ", ToUsDomestic::" ", ByUsForeign::" ", ToUsForeign::" ", Calculation::"5g. Tax Amount To Pay/Claim", false);
    end;

    procedure ElecVatCategory1A1(): Code[10]
    begin
        exit(ElecVatCategory1A1Tok);
    end;

    procedure ElecVatCategory1A2(): Code[10]
    begin
        exit(ElecVatCategory1A2Tok);
    end;

    procedure ElecVatCategory1B1(): Code[10]
    begin
        exit(ElecVatCategory1B1Tok);
    end;

    procedure ElecVatCategory1B2(): Code[10]
    begin
        exit(ElecVatCategory1B2Tok);
    end;

    procedure ElecVatCategory1C1(): Code[10]
    begin
        exit(ElecVatCategory1C1Tok);
    end;

    procedure ElecVatCategory1C2(): Code[10]
    begin
        exit(ElecVatCategory1C2Tok);
    end;

    procedure ElecVatCategory1D1(): Code[10]
    begin
        exit(ElecVatCategory1D1Tok);
    end;

    procedure ElecVatCategory1D2(): Code[10]
    begin
        exit(ElecVatCategory1D2Tok);
    end;

    procedure ElecVatCategory1E(): Code[10]
    begin
        exit(ElecVatCategory1ETok);
    end;

    procedure ElecVatCategory2A1(): Code[10]
    begin
        exit(ElecVatCategory2A1Tok);
    end;

    procedure ElecVatCategory2A2(): Code[10]
    begin
        exit(ElecVatCategory2A2Tok);
    end;

    procedure ElecVatCategory3A(): Code[10]
    begin
        exit(ElecVatCategory3ATok);
    end;

    procedure ElecVatCategory3B(): Code[10]
    begin
        exit(ElecVatCategory3BTok);
    end;

    procedure ElecVatCategory3C(): Code[10]
    begin
        exit(ElecVatCategory3CTok);
    end;

    procedure ElecVatCategory4A1(): Code[10]
    begin
        exit(ElecVatCategory4A1Tok);
    end;

    procedure ElecVatCategory4A2(): Code[10]
    begin
        exit(ElecVatCategory4A2Tok);
    end;

    procedure ElecVatCategory4B1(): Code[10]
    begin
        exit(ElecVatCategory4B1Tok);
    end;

    procedure ElecVatCategory4B2(): Code[10]
    begin
        exit(ElecVatCategory4B2Tok);
    end;

    procedure ElecVatCategory5A(): Code[10]
    begin
        exit(ElecVatCategory5ATok);
    end;

    procedure ElecVatCategory5B(): Code[10]
    begin
        exit(ElecVatCategory5BTok);
    end;

    procedure ElecVatCategory5D(): Code[10]
    begin
        exit(ElecVatCategory5DTok);
    end;

    procedure ElecVatCategory5E(): Code[10]
    begin
        exit(ElecVatCategory5ETok);
    end;

    procedure ElecVatCategory5F(): Code[10]
    begin
        exit(ElecVatCategory5FTok);
    end;

    procedure ElecVatCategory5G(): Code[10]
    begin
        exit(ElecVatCategory5GTok);
    end;

    var
        ElecVatCategory1A1Tok: Label '1A-1';
        ElecVatCategory1A2Tok: Label '1A-2';
        ElecVatCategory1B1Tok: Label '1B-1';
        ElecVatCategory1B2Tok: Label '1B-2';
        ElecVatCategory1C1Tok: Label '1C-1';
        ElecVatCategory1C2Tok: Label '1C-2';
        ElecVatCategory1D1Tok: Label '1D-1';
        ElecVatCategory1D2Tok: Label '1D-2';
        ElecVatCategory1ETok: Label '1E';
        ElecVatCategory2A1Tok: Label '2A-1';
        ElecVatCategory2A2Tok: Label '2A-2';
        ElecVatCategory3ATok: Label '3A';
        ElecVatCategory3BTok: Label '3B';
        ElecVatCategory3CTok: Label '3C';
        ElecVatCategory4A1Tok: Label '4A-1';
        ElecVatCategory4A2Tok: Label '4A-2';
        ElecVatCategory4B1Tok: Label '4B-1';
        ElecVatCategory4B2Tok: Label '4B-2';
        ElecVatCategory5ATok: Label '5A';
        ElecVatCategory5BTok: Label '5B';
        ElecVatCategory5DTok: Label '5D';
        ElecVatCategory5ETok: Label '5E';
        ElecVatCategory5FTok: Label '5F';
        ElecVatCategory5GTok: Label '5G';
}