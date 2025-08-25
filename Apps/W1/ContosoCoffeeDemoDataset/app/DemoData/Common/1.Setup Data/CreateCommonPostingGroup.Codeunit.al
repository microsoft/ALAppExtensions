// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Common;

using Microsoft.DemoTool;
using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Inventory;

codeunit 5134 "Create Common Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CommonGLAccount: Codeunit "Create Common GL Account";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" <> ContosoCoffeeDemoDataSetup."Company Type"::VAT then
            ContosoPostingGroup.InsertTaxGroup(NonTaxable(), NoTaxableLbl);

        ContosoPostingGroup.InsertInventoryPostingGroup(Resale(), ResaleLbl);
        ContosoPostingGroup.InsertInventoryPostingGroup(RawMaterial(), RawMaterialsLbl);

        ContosoPostingGroup.InsertCustomerPostingGroup(Domestic(), DomesticCustomerVendorLbl, CommonGLAccount.CustomerDomestic());

        ContosoPostingGroup.InsertVendorPostingGroup(Domestic(), DomesticCustomerVendorLbl, CommonGLAccount.VendorDomestic());
    end;


    var
        CreatePostingGroup: Codeunit "Create Posting Groups";
#if not CLEAN27
        CreateVATPostingGroup: Codeunit "Create VAT Posting Groups";
#endif
        DomesticCustomerVendorLbl: Label 'Domestic customers and vendors', MaxLength = 100;
        RawMaterialsLbl: Label 'Raw Materials', MaxLength = 100;
        ResaleLbl: Label 'Resale', MaxLength = 100;
        NoTaxableTok: Label 'NONTAXABLE', MaxLength = 20;
        NoTaxableLbl: Label 'Nontaxable', MaxLength = 100;

    procedure Service(): Code[20]
    begin
        exit(CreatePostingGroup.ServicesPostingGroup());
    end;

    procedure Resale(): Code[20]
    var
        CreateInventoryPostingGroup: Codeunit "Create Inventory Posting Group";
    begin
        exit(CreateInventoryPostingGroup.Resale());
    end;

    procedure RawMaterial(): Code[20]
    begin
        exit(CreatePostingGroup.RawMatPostingGroup());
    end;

    procedure Domestic(): Code[20]
    begin
        exit(CreatePostingGroup.DomesticPostingGroup());
    end;

#if not CLEAN27
    [Obsolete('procedure is moved to codeunit 5252 "Create Posting Groups"', '27.0')]
    procedure EU(): Code[20]
    begin
        exit(CreatePostingGroup.EUPostingGroup());
    end;

    [Obsolete('procedure is moved to codeunit 5252 "Create Posting Groups"', '27.0')]
    procedure Export(): Code[20]
    begin
        exit(CreatePostingGroup.ExportPostingGroup());
    end;

    [Obsolete('procedure is moved to codeunit 5473 "Create VAT Posting Groups"', '27.0')]
    procedure ZeroVAT(): Code[20]
    begin
        exit(CreateVATPostingGroup.NoVAT());
    end;

    [Obsolete('procedure is moved to codeunit 5473 "Create VAT Posting Groups"', '27.0')]
    procedure ReducedVAT(): Code[20]
    begin
        exit(CreateVATPostingGroup.Reduced());
    end;

    [Obsolete('procedure is moved to codeunit 5473 "Create VAT Posting Groups"', '27.0')]
    procedure StandardVAT(): Code[20]
    begin
        exit(CreateVATPostingGroup.Standard());
    end;
#endif

    procedure Retail(): Code[20]
    begin
        exit(CreatePostingGroup.RetailPostingGroup());
    end;

    procedure NonTaxable(): Code[20]
    begin
        exit(NoTaxableTok);
    end;
}
