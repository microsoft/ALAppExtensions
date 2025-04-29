// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 31191 "Create Posting Groups CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertGenBusinessPostingGroup();
        InsertGenProductPostingGroup();
    end;

    procedure InsertGenPostingSetupWithoutGLAccounts()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup CZ";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        ContosoPostingSetup.InsertGeneralPostingSetup('', Manufact());
        ContosoPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.MiscPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup('', NOVAT());
        ContosoPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RawMatPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.ServicesPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), Manufact());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), NOVAT());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RawMatPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), Manufact());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.MiscPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), NOVAT());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RawMatPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.ServicesPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), Manufact());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.MiscPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), NOVAT());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RawMatPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(IAssembly(), Manufact());
        ContosoPostingSetup.InsertGeneralPostingSetup(IAssembly(), CreatePostingGroups.MiscPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(IAssembly(), CreatePostingGroups.RawMatPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(IAssembly(), CreatePostingGroups.RetailPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(IAssembly(), CreatePostingGroups.ServicesPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(IDeficiency(), Manufact());
        ContosoPostingSetup.InsertGeneralPostingSetup(IDeficiency(), CreatePostingGroups.RawMatPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(IDeficiency(), CreatePostingGroups.RetailPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(IManufact(), Manufact());
        ContosoPostingSetup.InsertGeneralPostingSetup(IManufact(), CreatePostingGroups.MiscPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(IManufact(), CreatePostingGroups.RawMatPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(IManufact(), CreatePostingGroups.RetailPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(IManufact(), CreatePostingGroups.ServicesPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(ISurplus(), Manufact());
        ContosoPostingSetup.InsertGeneralPostingSetup(ISurplus(), CreatePostingGroups.RawMatPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(ISurplus(), CreatePostingGroups.RetailPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(ITransfer(), Manufact());
        ContosoPostingSetup.InsertGeneralPostingSetup(ITransfer(), CreatePostingGroups.RawMatPostingGroup());
        ContosoPostingSetup.InsertGeneralPostingSetup(ITransfer(), CreatePostingGroups.RetailPostingGroup());
    end;

    procedure DeleteGenProductPostingGroups()
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        GenProductPostingGroup.SetFilter(Code, '%1|%2', CreatePostingGroups.ZeroPostingGroup(), CreatePostingGroups.FreightPostingGroup());
        GenProductPostingGroup.DeleteAll(true);
    end;

    local procedure InsertGenBusinessPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertGenBusinessPostingGroup(IAssembly(), IAssemblyDescriptionLbl, '');
        ContosoPostingGroup.InsertGenBusinessPostingGroup(IDeficiency(), IDeficiencyDescriptionLbl, '');
        ContosoPostingGroup.InsertGenBusinessPostingGroup(IManufact(), IManufactDescriptionLbl, '');
        ContosoPostingGroup.InsertGenBusinessPostingGroup(ISurplus(), ISurplusDescriptionLbl, '');
        ContosoPostingGroup.InsertGenBusinessPostingGroup(ITransfer(), ITransferDescriptionLbl, '');
    end;

    local procedure InsertGenProductPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateVATPostingGroupsCZ: Codeunit "Create VAT Posting Groups CZ";
    begin
        ContosoPostingGroup.InsertGenProductPostingGroup(Manufact(), ManufactDescriptionLbl, CreateVATPostingGroupsCZ.VAT21S());
        ContosoPostingGroup.InsertGenProductPostingGroup(NOVAT(), NOVATDescriptionLbl, CreateVATPostingGroupsCZ.NOVAT());
    end;

    procedure UpdateGenPostingSetup()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertGeneralPostingSetup('', Manufact(), '', '', '', CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.OverheadAppliedCap(), CreateGLAccountCZ.PurchaseVarianceCap(), '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.MiscPostingGroup(), '', '', CreateGLAccountCZ.AcquisitionRetail(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.OverheadAppliedRetail(), CreateGLAccountCZ.PurchaseVarianceRetail(), '', '', '', '', CreateGLAccountCZ.COGSOthers(), CreateGLAccountCZ.COGSOthersInterim(), CreateGLAccountCZ.AcquisitionRetailInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup('', NOVAT(), '', '', CreateGLAccountCZ.AcquisitionRetail(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.OverheadAppliedRetail(), CreateGLAccountCZ.PurchaseVarianceRetail(), '', '', '', '', CreateGLAccountCZ.COGSOthers(), CreateGLAccountCZ.COGSOthersInterim(), CreateGLAccountCZ.AcquisitionRetailInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RawMatPostingGroup(), '', '', CreateGLAccountCZ.AcquisitionRawMaterial(), CreateGLAccountCZ.AcquisitionOfMaterial(), CreateGLAccountCZ.OverheadAppliedRetail(), CreateGLAccountCZ.PurchaseVarianceRawmat(), '', '', '', '', CreateGLAccountCZ.Costofmaterialsold(), CreateGLAccountCZ.CostofmaterialsoldInterim(), CreateGLAccountCZ.AcquisitionRawMaterialInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup(), '', '', CreateGLAccountCZ.AcquisitionRetail(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.OverheadAppliedRetail(), CreateGLAccountCZ.PurchaseVarianceRetail(), '', '', '', '', CreateGLAccountCZ.COGSRetail(), CreateGLAccountCZ.COGSRetailInterim(), CreateGLAccountCZ.AcquisitionRetailInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.ServicesPostingGroup(), '', '', CreateGLAccountCZ.AcquisitionRetail(), CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.OverheadAppliedCap(), CreateGLAccountCZ.PurchaseVarianceCap(), '', '', '', '', CreateGLAccountCZ.COGSOthers(), CreateGLAccountCZ.COGSOthersInterim(), CreateGLAccountCZ.AcquisitionRetailInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), Manufact(), CreateGLAccountCZ.SalesProductsDomestic(), CreateGLAccountCZ.AcquisitionRawMaterialDomestic(), '', CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.OverheadAppliedCap(), CreateGLAccountCZ.PurchaseVarianceCap(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.AcquisitionRawMaterialDomestic(), CreateGLAccountCZ.AcquisitionRawMaterialDomestic(), '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), CreateGLAccountCZ.SalesServicesDomestic(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionRetail(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.OverheadAppliedRetail(), CreateGLAccountCZ.PurchaseVarianceRetail(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.COGSOthers(), CreateGLAccountCZ.COGSOthersInterim(), CreateGLAccountCZ.AcquisitionRetailInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), NOVAT(), CreateGLAccountCZ.SalesServicesDomestic(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionRetail(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.OverheadAppliedRetail(), CreateGLAccountCZ.PurchaseVarianceRetail(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.COGSOthers(), CreateGLAccountCZ.COGSOthersInterim(), CreateGLAccountCZ.AcquisitionRetailInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), CreateGLAccountCZ.Salesmaterial(), CreateGLAccountCZ.AcquisitionRawMaterial(), CreateGLAccountCZ.AcquisitionRawMaterial(), CreateGLAccountCZ.AcquisitionOfMaterial(), CreateGLAccountCZ.OverheadAppliedRetail(), CreateGLAccountCZ.PurchaseVarianceRawmat(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.AcquisitionRawMaterial(), CreateGLAccountCZ.AcquisitionRawMaterial(), CreateGLAccountCZ.Costofmaterialsold(), CreateGLAccountCZ.CostofmaterialsoldInterim(), CreateGLAccountCZ.AcquisitionRawMaterialInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccountCZ.SalesGoodsDomestic(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionRetail(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.OverheadAppliedRetail(), CreateGLAccountCZ.PurchaseVarianceRetail(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.COGSRetail(), CreateGLAccountCZ.COGSRetailInterim(), CreateGLAccountCZ.AcquisitionRetailInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccountCZ.SalesServicesDomestic(), CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.AcquisitionRetail(), CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.OverheadAppliedCap(), CreateGLAccountCZ.PurchaseVarianceCap(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.COGSOthers(), CreateGLAccountCZ.COGSOthersInterim(), CreateGLAccountCZ.AcquisitionRetailInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), Manufact(), CreateGLAccountCZ.SalesProductsEU(), CreateGLAccountCZ.AcquisitionRawMaterialEU(), '', CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.OverheadAppliedCap(), CreateGLAccountCZ.PurchaseVarianceCap(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.AcquisitionRawMaterialEU(), CreateGLAccountCZ.AcquisitionRawMaterialEU(), '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.MiscPostingGroup(), CreateGLAccountCZ.SalesServicesEU(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionRetail(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.OverheadAppliedRetail(), CreateGLAccountCZ.PurchaseVarianceRetail(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.COGSOthers(), CreateGLAccountCZ.COGSOthersInterim(), CreateGLAccountCZ.AcquisitionRetailInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), NOVAT(), CreateGLAccountCZ.SalesServicesEU(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionRetail(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.OverheadAppliedRetail(), CreateGLAccountCZ.PurchaseVarianceRetail(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.COGSOthers(), CreateGLAccountCZ.COGSOthersInterim(), CreateGLAccountCZ.AcquisitionRetailInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), CreateGLAccountCZ.Salesmaterial(), CreateGLAccountCZ.AcquisitionRawMaterial(), CreateGLAccountCZ.AcquisitionRawMaterial(), CreateGLAccountCZ.AcquisitionOfMaterial(), CreateGLAccountCZ.OverheadAppliedRetail(), CreateGLAccountCZ.PurchaseVarianceRawmat(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.AcquisitionRawMaterial(), CreateGLAccountCZ.AcquisitionRawMaterial(), CreateGLAccountCZ.Costofmaterialsold(), CreateGLAccountCZ.CostofmaterialsoldInterim(), CreateGLAccountCZ.AcquisitionRawMaterialInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccountCZ.SalesGoodsEU(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionRetail(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.OverheadAppliedRetail(), CreateGLAccountCZ.PurchaseVarianceRetail(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.COGSRetail(), CreateGLAccountCZ.COGSRetailInterim(), CreateGLAccountCZ.AcquisitionRetailInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccountCZ.SalesServicesEU(), CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.AcquisitionRetail(), CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.OverheadAppliedCap(), CreateGLAccountCZ.PurchaseVarianceCap(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.COGSOthers(), CreateGLAccountCZ.COGSOthersInterim(), CreateGLAccountCZ.AcquisitionRetailInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), Manufact(), CreateGLAccountCZ.SalesProductsExport(), CreateGLAccountCZ.AcquisitionRawMaterialExport(), '', CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.OverheadAppliedCap(), CreateGLAccountCZ.PurchaseVarianceCap(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.AcquisitionRawMaterialExport(), CreateGLAccountCZ.AcquisitionRawMaterialExport(), '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.MiscPostingGroup(), CreateGLAccountCZ.SalesServicesExport(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionRetail(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.OverheadAppliedRetail(), CreateGLAccountCZ.PurchaseVarianceRetail(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.COGSOthers(), CreateGLAccountCZ.COGSOthersInterim(), CreateGLAccountCZ.AcquisitionRetailInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), NOVAT(), CreateGLAccountCZ.SalesServicesExport(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionRetail(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.OverheadAppliedRetail(), CreateGLAccountCZ.PurchaseVarianceRetail(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.COGSOthers(), CreateGLAccountCZ.COGSOthersInterim(), CreateGLAccountCZ.AcquisitionRetailInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), CreateGLAccountCZ.Salesmaterial(), CreateGLAccountCZ.AcquisitionRawMaterial(), CreateGLAccountCZ.AcquisitionRawMaterial(), CreateGLAccountCZ.AcquisitionOfMaterial(), CreateGLAccountCZ.OverheadAppliedRetail(), CreateGLAccountCZ.PurchaseVarianceRawmat(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.AcquisitionRawMaterial(), CreateGLAccountCZ.AcquisitionRawMaterial(), CreateGLAccountCZ.Costofmaterialsold(), CreateGLAccountCZ.CostofmaterialsoldInterim(), CreateGLAccountCZ.AcquisitionRawMaterialInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccountCZ.SalesGoodsExport(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionRetail(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.OverheadAppliedRetail(), CreateGLAccountCZ.PurchaseVarianceRetail(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.AcquisitionOfGoods(), CreateGLAccountCZ.COGSRetail(), CreateGLAccountCZ.COGSRetailInterim(), CreateGLAccountCZ.AcquisitionRetailInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccountCZ.SalesServicesExport(), CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.AcquisitionRetail(), CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.OverheadAppliedCap(), CreateGLAccountCZ.PurchaseVarianceCap(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.Discounts(), CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.OtherServices(), CreateGLAccountCZ.COGSOthers(), CreateGLAccountCZ.COGSOthersInterim(), CreateGLAccountCZ.AcquisitionRetailInterim());
        ContosoPostingSetup.InsertGeneralPostingSetup(IAssembly(), Manufact(), '', '', CreateGLAccountCZ.InternalSettlement(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(IAssembly(), CreatePostingGroups.MiscPostingGroup(), '', '', CreateGLAccountCZ.InternalSettlement(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(IAssembly(), CreatePostingGroups.RawMatPostingGroup(), '', '', CreateGLAccountCZ.InternalSettlement(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(IAssembly(), CreatePostingGroups.RetailPostingGroup(), '', '', CreateGLAccountCZ.InternalSettlement(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(IAssembly(), CreatePostingGroups.ServicesPostingGroup(), '', '', CreateGLAccountCZ.InternalSettlement(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(IDeficiency(), Manufact(), '', '', CreateGLAccountCZ.Shortagesanddamagefromoperact(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(IDeficiency(), CreatePostingGroups.RawMatPostingGroup(), '', '', CreateGLAccountCZ.Shortagesanddamagefromoperact(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(IDeficiency(), CreatePostingGroups.RetailPostingGroup(), '', '', CreateGLAccountCZ.Shortagesanddamagefromoperact(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(IManufact(), Manufact(), '', '', CreateGLAccountCZ.ChangeinWIP(), CreateGLAccountCZ.ChangeinWIP(), CreateGLAccountCZ.ChangeinWIP(), '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(IManufact(), CreatePostingGroups.MiscPostingGroup(), '', '', CreateGLAccountCZ.ChangeinWIP(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(IManufact(), CreatePostingGroups.RawMatPostingGroup(), '', '', CreateGLAccountCZ.ChangeinWIP(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(IManufact(), CreatePostingGroups.RetailPostingGroup(), '', '', CreateGLAccountCZ.ChangeinWIP(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(IManufact(), CreatePostingGroups.ServicesPostingGroup(), '', '', CreateGLAccountCZ.ChangeinWIP(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(ISurplus(), Manufact(), '', '', CreateGLAccountCZ.OtherOperatingIncome(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(ISurplus(), CreatePostingGroups.RawMatPostingGroup(), '', '', CreateGLAccountCZ.OtherOperatingIncome(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(ISurplus(), CreatePostingGroups.RetailPostingGroup(), '', '', CreateGLAccountCZ.OtherOperatingIncome(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(ITransfer(), Manufact(), '', '', CreateGLAccountCZ.InternalSettlement(), '', '', CreateGLAccountCZ.InternalSettlement(), '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(ITransfer(), CreatePostingGroups.RawMatPostingGroup(), '', '', CreateGLAccountCZ.InternalSettlement(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.InsertGeneralPostingSetup(ITransfer(), CreatePostingGroups.RetailPostingGroup(), '', '', CreateGLAccountCZ.InternalSettlement(), '', '', '', '', '', '', '', '', '', '');
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Product Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInserGenProductPostingGroup(var Rec: Record "Gen. Product Posting Group")
    var
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateVatPostingGroupsCZ: Codeunit "Create Vat Posting Groups CZ";
    begin
        case Rec.Code of
            CreatePostingGroups.RawMatPostingGroup():
                Rec."Def. VAT Prod. Posting Group" := CreateVatPostingGroupsCZ.VAT21S();
            CreatePostingGroups.MiscPostingGroup(),
            CreatePostingGroups.RetailPostingGroup(),
            CreatePostingGroups.ServicesPostingGroup():
                Rec."Def. VAT Prod. Posting Group" := CreateVatPostingGroupsCZ.VAT21I();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"General Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertGeneralPostingSetup(var Rec: Record "General Posting Setup")
    begin
        Rec."Invt. Rounding Adj. Acc. CZL" := Rec."Inventory Adjmt. Account";
    end;

    [EventSubscriber(ObjectType::Table, Database::"General Posting Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModifyGeneralPostingSetup(var Rec: Record "General Posting Setup")
    begin
        Rec."Invt. Rounding Adj. Acc. CZL" := Rec."Inventory Adjmt. Account";
    end;

    [EventSubscriber(ObjectType::Table, Database::"General Posting Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertGeneralPostingSetup(var Rec: Record "General Posting Setup")
    var
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        if Rec."Gen. Prod. Posting Group" in [CreatePostingGroups.ZeroPostingGroup(), CreatePostingGroups.FreightPostingGroup()] then
            Rec.Delete(true);
    end;

    procedure NOVAT(): Code[20]
    begin
        exit(NOVATTok);
    end;

    procedure Manufact(): Code[20]
    begin
        exit(ManufactTok);
    end;

    procedure ISurplus(): Code[20]
    begin
        exit(ISurplusTok);
    end;

    procedure IDeficiency(): Code[20]
    begin
        exit(IDeficiencyTok);
    end;

    procedure ITransfer(): Code[20]
    begin
        exit(ITransferTok);
    end;

    procedure IAssembly(): Code[20]
    begin
        exit(IAssemblyTok);
    end;

    procedure IManufact(): Code[20]
    begin
        exit(IManufactTok);
    end;

    var
        ISurplusTok: Label 'I_SURPLUS', MaxLength = 20;
        ISurplusDescriptionLbl: Label 'Physical Inventory Surplus', MaxLength = 100;
        IDeficiencyTok: Label 'I_DEFICIENCY', MaxLength = 20;
        IDeficiencyDescriptionLbl: Label 'Physical Inventory Deficiency', MaxLength = 100;
        ITransferTok: Label 'I_TRANSFER', MaxLength = 20;
        ITransferDescriptionLbl: Label 'Inventory Transfer', MaxLength = 100;
        IAssemblyTok: Label 'I_ASSEMBLY', MaxLength = 20;
        IAssemblyDescriptionLbl: Label 'Inventory Assembly', MaxLength = 100;
        IManufactTok: Label 'I_MANUFACT', MaxLength = 20;
        IManufactDescriptionLbl: Label 'Inventory Manufacture', MaxLength = 100;
        ManufactTok: Label 'MANUFACT', MaxLength = 20;
        ManufactDescriptionLbl: Label 'Capacities', MaxLength = 100;
        NOVATTok: Label 'NO VAT', MaxLength = 20;
        NOVATDescriptionLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
}
