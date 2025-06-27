// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Finance.VAT.Setup;
using Microsoft.Finance.VAT.Clause;
using Microsoft.Foundation.Enums;

codeunit 31219 "Contoso Posting Setup CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "VAT Posting Setup" = rim,
        tabledata "VAT Clause" = rim;

    var
        VATSetupDescTok: Label 'Setup for %1 / %2', MaxLength = 100, Comment = '%1 is the VAT Bus. Posting Group Code, %2 is the VAT Prod. Posting Group Code';
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertGeneralPostingSetup(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20])
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
    begin
        ContosoPostingSetup.InsertGeneralPostingSetup(GenBusPostingGroup, GenProdPostingGroup, '', '', '', '', '', '', '', '', '', '', '', '', '');
    end;

    procedure InsertVATPostingSetup(VATBusinessGroupCode: Code[20]; VATProductGroupCode: Code[20]; VATIdentifier: Code[20]; VATPercentage: Decimal; VATCalculationType: Enum "Tax Calculation Type"; VATClauseCode: Code[20]; EUService: Boolean; VATRate: Enum "VAT Rate CZL")
    begin
        InsertVATPostingSetup(VATBusinessGroupCode, VATProductGroupCode, '', '', VATIdentifier, VATPercentage, VATCalculationType, '', VATClauseCode, EUService, VATRate);
    end;

    procedure InsertVATPostingSetup(VATBusinessGroupCode: Code[20]; VATProductGroupCode: Code[20]; SalesVATAccountNo: Code[20]; PurchaseVATAccountNo: Code[20]; VATIdentifier: Code[20]; VATPercentage: Decimal; VATCalculationType: Enum "Tax Calculation Type"; ReverseChargeVATUnrealAcc: Code[20]; VATClauseCode: Code[20]; EUService: Boolean; VATRate: Enum "VAT Rate CZL")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Exists: Boolean;
    begin
        if VATPostingSetup.Get(VATBusinessGroupCode, VATProductGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATPostingSetup.Validate("VAT Bus. Posting Group", VATBusinessGroupCode);
        VATPostingSetup.Validate("VAT Prod. Posting Group", VATProductGroupCode);
        if (VATBusinessGroupCode <> '') or (VATProductGroupCode <> '') then
            VATPostingSetup.Validate(Description, StrSubstNo(VATSetupDescTok, VATBusinessGroupCode, VATProductGroupCode));

        // Need to check if we are changing the VAT Calculation Type before we validate it
        // The validation tries to find VAT Entry no matter we are changing the VAT Calculation Type or not
        if Exists then begin
            if VATPostingSetup."VAT Calculation Type" <> VATCalculationType then
                VATPostingSetup.Validate("VAT Calculation Type", VATCalculationType);
        end else
            VATPostingSetup.Validate("VAT Calculation Type", VATCalculationType);

        if not (VATPostingSetup."VAT Calculation Type" = Enum::"Tax Calculation Type"::"Sales Tax") then begin
            VATPostingSetup.Validate("Sales VAT Account", SalesVATAccountNo);
            VATPostingSetup.Validate("Purchase VAT Account", PurchaseVATAccountNo);
            VATPostingSetup.Validate("VAT Identifier", VATIdentifier);
            VATPostingSetup.Validate("VAT %", VATPercentage);
        end;
        if VATPostingSetup."VAT Calculation Type" = VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT" then
            VATPostingSetup.Validate("Reverse Chrg. VAT Acc.", ReverseChargeVATUnrealAcc);

        VATPostingSetup.Validate("VAT Rate CZL", VATRate);
        VATPostingSetup.Validate("VAT Clause Code", VATClauseCode);
        VATPostingSetup.Validate("EU Service", EUService);

        if Exists then
            VATPostingSetup.Modify(true)
        else
            VATPostingSetup.Insert(true);
    end;

    procedure UpdateVATPostingSetup(VATBusinessGroupCode: Code[20]; VATProductGroupCode: Code[20]; SalesVATAccountNo: Code[20]; PurchaseVATAccountNo: Code[20]; ReverseChargeVATUnrealAcc: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not VATPostingSetup.Get(VATBusinessGroupCode, VATProductGroupCode) then
            exit;

        SetOverwriteData(true);
        InsertVATPostingSetup(VATBusinessGroupCode, VATProductGroupCode, SalesVATAccountNo, PurchaseVATAccountNo,
            VATPostingSetup."VAT Identifier", VATPostingSetup."VAT %", VATPostingSetup."VAT Calculation Type",
            ReverseChargeVATUnrealAcc, VATPostingSetup."VAT Clause Code",
            VATPostingSetup."EU Service", VATPostingSetup."VAT Rate CZL");
        SetOverwriteData(false);
    end;

    procedure InsertVATClause(Code: Code[20]; Description: Text[250]; Description2: Text[250])
    var
        VATClause: Record "VAT Clause";
        Exists: Boolean;
    begin
        if VATClause.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATClause.Validate(Code, Code);
        VATClause.Validate(Description, Description);
        VATClause.Validate("Description 2", Description2);

        if Exists then
            VATClause.Modify(true)
        else
            VATClause.Insert(true);
    end;
}
