codeunit 12201 "Create No. Series IT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(CustomerBillListJnl(), CustomerBillListLbl, 'DEC000001', 'DEC100000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(CustBills(), FinalCustomerBillNoLbl, 'BILLC00001', 'BILLC10000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(InvCrMemoVATNoforEUVend(), InvCrMemoVATNoforEUVendLbl, 'V010001', 'V020000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(InvCrMemoVATNoforEUCust(), InvCrMemoVATNoforEUCustLbl, 'C010001', 'C020000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(InvCrMemoVATNoforExtraEUVendors(), InvCrMemoVATNoforEUVendorLbl, 'FX010001', 'FX020000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(InvCrMemoVATNoforExtraEUCustomers(), InvCrMemoVATNoforExtraEUCustomersLbl, 'CX010001', 'CX020000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(FatturaPA(), FatturaPALbl, '1001', '2999', '2995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(InvCrMemoVATNoforItalianVend(), InvCrMemoVATNoforItalianVendLbl, '108001', '109001', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(InvCrMemoVATNoforItalianCust(), InvCrMemoVATNoforItalianCustLbl, '102001', '103000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(TemporaryCustomerBillNo(), TemporaryCustomerBillNoLbl, 'TEC00001', 'TEC10000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(TemporaryCustBillListNo(), TemporaryCustBillListNoLbl, 'TEC000001', 'TEC100000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(VendorBillsBRListNo(), VendorBillsBRListNoLbl, 'TDF00001', 'TDF10000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(VendorBillsBRList(), VendorBillsBRListLbl, 'DEF00001', 'DEF10000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(VendorBillsBRNo(), VendorBillsBRNoLbl, 'BILL000001', 'BILL100000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);

        NoSeriesLineSale();
        NoSeriesLinePurchase();
    end;

    [EventSubscriber(ObjectType::Table, Database::"No. Series", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertNoSeries(var Rec: Record "No. Series")
    var
        CreateNoSeries: Codeunit "Create No. Series";
        CreateFANoSeries: Codeunit "Create FA No Series";
    begin
        case Rec.Code of
            InvCrMemoVATNoforEUCust():
                ValidateRecordFields(Rec, Enum::"No. Series Type"::Sales, true, EuSalesLbl);
            InvCrMemoVATNoforExtraEUCustomers():
                ValidateRecordFields(Rec, Enum::"No. Series Type"::Sales, true, ExtSalesLbl);
            InvCrMemoVATNoforItalianCust():
                ValidateRecordFields(Rec, Enum::"No. Series Type"::Sales, true, NatSalesLbl);
            InvCrMemoVATNoforItalianVend():
                ValidateRecordFields(Rec, Enum::"No. Series Type"::Purchase, true, NatPurchLbl);
            InvCrMemoVATNoforExtraEUVendors():
                ValidateRecordFields(Rec, Enum::"No. Series Type"::Purchase, true, ExtPurchLbl);
            InvCrMemoVATNoforEUVend():
                ValidateRecordFields(Rec, Enum::"No. Series Type"::Purchase, true, EuPurchLbl);
            CreateFANoSeries.FixedAsset():
                Rec.Validate("Date Order", true);
            CreateFANoSeries.Insurance():
                Rec.Validate("Date Order", true);
            CreateNoSeries.PostedPurchaseInvoice():
                Rec.Validate("Date Order", true);
            CreateNoSeries.PostedSalesCreditMemo():
                Rec.Validate("Date Order", true);
            CreateNoSeries.PostedSalesInvoice():
                Rec.Validate("Date Order", true);
            CreateNoSeries.SalesShipment():
                Rec.Validate("Date Order", true);
            CreateNoSeries.AssemblyBlanketOrders():
                Rec.Validate(Description, BlanketAssemblyOrdersLbl);
        end;
    end;

    local procedure NoSeriesLineSale()
    var
        ContosoNoSeriesIT: Codeunit "Contoso No. Series IT";
    begin
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforExtraEUCustomers(), GetNextLineNo(InvCrMemoVATNoforExtraEUCustomers()), '22-CX010001', DMY2Date(1, 1, 2022));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforExtraEUCustomers(), GetNextLineNo(InvCrMemoVATNoforExtraEUCustomers()), '23-CX010001', DMY2Date(1, 1, 2023));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforExtraEUCustomers(), GetNextLineNo(InvCrMemoVATNoforExtraEUCustomers()), '24-CX010001', DMY2Date(1, 1, 2024));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforExtraEUCustomers(), GetNextLineNo(InvCrMemoVATNoforExtraEUCustomers()), '25-CX010001', DMY2Date(1, 1, 2025));

        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforEUCust(), GetNextLineNo(InvCrMemoVATNoforEUCust()), '22-C010001', DMY2Date(1, 1, 2022));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforEUCust(), GetNextLineNo(InvCrMemoVATNoforEUCust()), '23-C010001', DMY2Date(1, 1, 2023));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforEUCust(), GetNextLineNo(InvCrMemoVATNoforEUCust()), '24-C010001', DMY2Date(1, 1, 2024));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforEUCust(), GetNextLineNo(InvCrMemoVATNoforEUCust()), '25-C010001', DMY2Date(1, 1, 2025));

        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforItalianCust(), GetNextLineNo(InvCrMemoVATNoforItalianCust()), '22-102001', DMY2Date(1, 1, 2022));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforItalianCust(), GetNextLineNo(InvCrMemoVATNoforItalianCust()), '23-102001', DMY2Date(1, 1, 2023));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforItalianCust(), GetNextLineNo(InvCrMemoVATNoforItalianCust()), '24-102001', DMY2Date(1, 1, 2024));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforItalianCust(), GetNextLineNo(InvCrMemoVATNoforItalianCust()), '25-102001', DMY2Date(1, 1, 2025));
    end;

    local procedure NoSeriesLinePurchase()
    var
        ContosoNoSeriesIT: Codeunit "Contoso No. Series IT";
    begin
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforEUVend(), GetNextLineNo(InvCrMemoVATNoforEUVend()), '22-V010001', DMY2Date(1, 1, 2022));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforEUVend(), GetNextLineNo(InvCrMemoVATNoforEUVend()), '23-V010001', DMY2Date(1, 1, 2023));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforEUVend(), GetNextLineNo(InvCrMemoVATNoforEUVend()), '24-V010001', DMY2Date(1, 1, 2024));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforEUVend(), GetNextLineNo(InvCrMemoVATNoforEUVend()), '25-V010001', DMY2Date(1, 1, 2025));

        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforExtraEUVendors(), GetNextLineNo(InvCrMemoVATNoforExtraEUVendors()), '22-FX010001', DMY2Date(1, 1, 2022));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforExtraEUVendors(), GetNextLineNo(InvCrMemoVATNoforExtraEUVendors()), '23-FX010001', DMY2Date(1, 1, 2023));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforExtraEUVendors(), GetNextLineNo(InvCrMemoVATNoforExtraEUVendors()), '24-FX010001', DMY2Date(1, 1, 2024));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforExtraEUVendors(), GetNextLineNo(InvCrMemoVATNoforExtraEUVendors()), '25-FX010001', DMY2Date(1, 1, 2025));

        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforItalianVend(), GetNextLineNo(InvCrMemoVATNoforItalianVend()), '22-108001', DMY2Date(1, 1, 2022));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforItalianVend(), GetNextLineNo(InvCrMemoVATNoforItalianVend()), '23-108001', DMY2Date(1, 1, 2023));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforItalianVend(), GetNextLineNo(InvCrMemoVATNoforItalianVend()), '24-108001', DMY2Date(1, 1, 2024));
        ContosoNoSeriesIT.InsertNoSeriesSalesPurchase(InvCrMemoVATNoforItalianVend(), GetNextLineNo(InvCrMemoVATNoforItalianVend()), '25-108001', DMY2Date(1, 1, 2025));
    end;

    local procedure ValidateRecordFields(var NoSeries: Record "No. Series"; NoSeriesType: Enum "No. Series Type"; DateOrder: Boolean; VATRegister: Code[10])
    begin
        NoSeries.Validate("No. Series Type", NoSeriesType);
        NoSeries.Validate("Date Order", DateOrder);
        NoSeries."VAT Register" := VATRegister;
    end;

    procedure CustomerBillListJnl(): Code[20]
    begin
        exit('CUSBILLIST');
    end;

    procedure CustBills(): Code[20]
    begin
        exit('CUSTBILLS');
    end;

    procedure InvCrMemoVATNoforEUVend(): Code[20]
    begin
        exit('EU-VN-PUR');
    end;

    procedure InvCrMemoVATNoforEUCust(): Code[20]
    begin
        exit('EU-VN-SLS');
    end;

    procedure InvCrMemoVATNoforExtraEUVendors(): Code[20]
    begin
        exit('EXT-VN-PUR');
    end;

    procedure InvCrMemoVATNoforExtraEUCustomers(): Code[20]
    begin
        exit('EXT-VN-SLS');
    end;

    procedure FatturaPA(): Code[20]
    begin
        exit('FATPA');
    end;

    procedure InvCrMemoVATNoforItalianVend(): Code[20]
    begin
        exit('IT-VN-PUR');
    end;

    procedure InvCrMemoVATNoforItalianCust(): Code[20]
    begin
        exit('IT-VN-SLS');
    end;

    procedure TemporaryCustomerBillNo(): Code[20]
    begin
        exit('TMCUSTBILL');
    end;

    procedure TemporaryCustBillListNo(): Code[20]
    begin
        exit('TMDCUS');
    end;

    procedure VendorBillsBRListNo(): Code[20]
    begin
        exit('TMDVEN');
    end;

    procedure VendorBillsBRList(): Code[20]
    begin
        exit('VNBILLIST');
    end;

    procedure VendorBillsBRNo(): Code[20]
    begin
        exit('VNBILLS');
    end;

    local procedure GetNextLineNo(NoSeriesCode: Code[20]): Integer
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeriesLine.SetRange("Series Code", NoSeriesCode);
        if NoSeriesLine.FindLast() then
            exit(NoSeriesLine."Line No." + 10000)
        else
            exit(10000);
    end;

    var
        NatSalesLbl: Label 'NATSALES', MaxLength = 10;
        NatPurchLbl: Label 'NATPURCH', MaxLength = 10;
        EuPurchLbl: Label 'EUPURCH', MaxLength = 10;
        ExtPurchLbl: Label 'EXTPURCH', MaxLength = 10;
        EuSalesLbl: Label 'EUSALES', MaxLength = 10;
        ExtSalesLbl: Label 'EXTSALES', MaxLength = 10;
        BlanketAssemblyOrdersLbl: Label 'Blanket Assembly Orders', MaxLength = 100;
        CustomerBillListLbl: Label 'Customer Bill List', MaxLength = 100;
        FinalCustomerBillNoLbl: Label 'Final Customer Bill No.', MaxLength = 100;
        InvCrMemoVATNoforEUVendLbl: Label 'Inv./Cr. Memo VAT No. for EU Vend.', MaxLength = 100;
        InvCrMemoVATNoforEUCustLbl: Label 'Inv./Cr. Memo VAT No. for EU Cust.', MaxLength = 100;
        InvCrMemoVATNoforEUVendorLbl: Label 'Inv./Cr. Memo VAT No. for ExtraEU Vendors', MaxLength = 100;
        InvCrMemoVATNoforExtraEUCustomersLbl: Label 'Inv./Cr. Memo VAT No. for ExtraEU Customers', MaxLength = 100;
        InvCrMemoVATNoforItalianVendLbl: Label 'Inv./Cr. Memo VAT No. for Italian Vend.', MaxLength = 100;
        InvCrMemoVATNoforItalianCustLbl: Label 'Inv./Cr. Memo VAT No. for Italian Cust.', MaxLength = 100;
        FatturaPALbl: Label 'FatturaPA', MaxLength = 100;
        TemporaryCustomerBillNoLbl: Label 'Temporary Customer Bill No.', MaxLength = 100;
        TemporaryCustBillListNoLbl: Label 'Temporary Cust. Bill List No.', MaxLength = 100;
        VendorBillsBRListNoLbl: Label 'Vendor Bills/BR List No.', MaxLength = 100;
        VendorBillsBRListLbl: Label 'Vendor Bills/BR List', MaxLength = 100;
        VendorBillsBRNoLbl: Label 'Vendor Bills/BR No.', MaxLength = 100;
}