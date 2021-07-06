codeunit 18195 "Library GST Sales"
{
    var
        Assert: Codeunit Assert;
        LibraryGST: Codeunit "Library GST";
        ComponentPerArray: array[10] of Decimal;
        GSTLEVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
        CGSTLbl: Label 'CGST', Locked = true;
        SGSTLbl: Label 'SGST', Locked = true;
        IGSTLbl: Label 'IGST', Locked = true;

    procedure VerifyGSTEntries(DocumentNo: Code[20]; TableID: Integer; ComponentArray: array[10] of Decimal)
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        ComponentList: List of [Code[30]];
    begin
        CopyArray(ComponentPerArray, ComponentArray, 1, 10);

        case TableID of
            Database::"Sales Invoice Header":
                begin
                    SalesInvoiceLine.SetRange("Document No.", DocumentNo);
                    SalesInvoiceLine.SetFilter("No.", '<>%1', '');
                    SalesInvoiceLine.FindSet();
                    FillComponentList(SalesInvoiceLine."GST Jurisdiction Type", ComponentList, SalesInvoiceLine."GST Group Code");
                    VerifyGSTEntriesForSalesInvoice(SalesInvoiceLine, DocumentNo, ComponentList);
                    repeat
                        FillComponentList(SalesInvoiceLine."GST Jurisdiction Type", ComponentList, SalesInvoiceLine."GST Group Code");
                        VerifyDetailedGSTEntriesForSalesInvoice(SalesInvoiceLine, DocumentNo, ComponentList);
                    until SalesInvoiceLine.Next() = 0;
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoLine.SetRange("Document No.", DocumentNo);
                    SalesCrMemoLine.SetFilter("No.", '<>%1', '');
                    SalesCrMemoLine.FindSet();

                    FillComponentList(SalesCrMemoLine."GST Jurisdiction Type", ComponentList, SalesCrMemoLine."GST Group Code");
                    VerifyGSTEntriesForSalesCrMemo(SalesCrMemoLine, DocumentNo, ComponentList);
                    repeat
                        FillComponentList(SalesCrMemoLine."GST Jurisdiction Type", ComponentList, SalesCrMemoLine."GST Group Code");
                        VerifyDetailedGSTEntriesForSalesCrMemo(SalesCrMemoLine, DocumentNo, ComponentList);
                    until SalesCrMemoLine.Next() = 0;
                end;
        end;
    end;

    local procedure FillComponentList(
        GSTJurisdictionType: Enum "GST Jurisdiction Type";
        var ComponentList: List of [Code[30]];
        GSTGroupCode: Code[20])
    var
        GSTGroup: Record "GST Group";
    begin
        GSTGroup.Get(GSTGroupCode);
        Clear(ComponentList);
        if GSTJurisdictionType = GSTJurisdictionType::Intrastate then begin
            ComponentList.Add(CGSTLbl);
            ComponentList.Add(SGSTLbl);
        end else
            ComponentList.Add(IGSTLbl);
    end;

    local procedure VerifyGSTEntriesForSalesInvoice(
        SalesInvoiceLine: Record "Sales Invoice Line";
        DocumentNo: Code[20];
        ComponentList: List of [Code[30]])
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GSTSalesInvoiceLine: Record "Sales Invoice Line";
        SourceCodeSetup: Record "Source Code Setup";
        GSTGroup: Record "GST Group";
        GSTBaseAmount, GSTAmount : Decimal;
        TotalGSTAmount: Decimal;
        CurrencyFactor: Decimal;
        ComponentCode: Code[30];
        TransactionNo: Integer;
        DocumentType: Enum "Gen. Journal Document Type";
    begin
        SalesInvoiceHeader.Get(DocumentNo);

        CurrencyFactor := SalesInvoiceHeader."Currency Factor";
        if CurrencyFactor = 0 then
            CurrencyFactor := 1;

        GSTGroup.Get(SalesInvoiceLine."GST Group Code");
        SourceCodeSetup.Get();

        TransactionNo := GetTransactionNo(DocumentNo, SalesInvoiceHeader."Posting Date", DocumentType::Invoice);

        foreach ComponentCode in ComponentList do begin
            GSTLedgerEntry.Reset();
            GSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            GSTLedgerEntry.SetRange("Document No.", DocumentNo);
            GSTLedgerEntry.SetRange("Posting Date", SalesInvoiceHeader."Posting Date");
            GSTLedgerEntry.SetRange("Document Type", GSTLedgerEntry."Document Type"::Invoice);
            GSTLedgerEntry.FindFirst();

            GSTSalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
            GSTSalesInvoiceLine.SetFilter("No.", '<>%1', '');
            Clear(TotalGSTAmount);
            if GSTSalesInvoiceLine.FindSet() then
                repeat
                    GetGSTAmountsForSalesInvoice(GSTSalesInvoiceLine, GSTBaseAmount, GSTAmount);
                    TotalGSTAmount += GSTAmount;
                until GSTSalesInvoiceLine.Next() = 0;

            Assert.AreEqual(SalesInvoiceLine."Gen. Bus. Posting Group", GSTLedgerEntry."Gen. Bus. Posting Group",
               StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldName("Gen. Bus. Posting Group"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceLine."Gen. Prod. Posting Group", GSTLedgerEntry."Gen. Prod. Posting Group",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Gen. Prod. Posting Group"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceHeader."Posting Date", GSTLedgerEntry."Posting Date",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Posting Date"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Document Type"::Invoice, GSTLedgerEntry."Document Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Document Type"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Transaction Type"::Sales, GSTLedgerEntry."Transaction Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction Type"), GSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(GSTBaseAmount / CurrencyFactor, GSTLedgerEntry."GST Base Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Base Amount"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Source Type"::Customer, GSTLedgerEntry."Source Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Type"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceHeader."Sell-to Customer No.", GSTLedgerEntry."Source No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source No."), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(UserId, GSTLedgerEntry."User ID",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("User ID"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(SourceCodeSetup.Sales, GSTLedgerEntry."Source Code",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Code"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransactionNo, GSTLedgerEntry."Transaction No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction No."), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceHeader."External Document No.", GSTLedgerEntry."External Document No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("External Document No."), GSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(TotalGSTAmount, GSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Amount"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Entry Type"::"Initial Entry", GSTLedgerEntry."Entry Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Entry Type"), GSTLedgerEntry.TableCaption));
        end;
    end;

    local procedure VerifyDetailedGSTEntriesForSalesInvoice(
        SalesInvoiceLine: Record "Sales Invoice Line";
        DocumentNo: Code[20];
        ComponentList: List of [Code[30]])
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SourceCodeSetup: Record "Source Code Setup";
        Customer: Record Customer;
        Item: Record Item;
        GSTGroup: Record "GST Group";
        ProductType: Enum "Product Type";
        GSTBaseAmount, GSTAmount, CurrencyFactor : Decimal;
        ComponentCode: Code[30];
        TransactionNo: Integer;
        DocumentType: Enum "Gen. Journal Document Type";
    begin
        SalesInvoiceHeader.Get(DocumentNo);

        CurrencyFactor := SalesInvoiceHeader."Currency Factor";
        if CurrencyFactor = 0 then
            CurrencyFactor := 1;

        Customer.Get(SalesInvoiceHeader."Sell-to Customer No.");
        SourceCodeSetup.Get();

        TransactionNo := GetTransactionNo(DocumentNo, SalesInvoiceHeader."Posting Date", DocumentType::Invoice);

        foreach ComponentCode in ComponentList do begin
            DetailedGSTLedgerEntry.Reset();
            DetailedGSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Document Line No.", SalesInvoiceLine."Line No.");
            DetailedGSTLedgerEntry.SetRange("Posting Date", SalesInvoiceHeader."Posting Date");
            DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
            DetailedGSTLedgerEntry.FindFirst();

            DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.");

            GSTGroup.Get(SalesInvoiceLine."GST Group Code");

            GetGSTAmountsForSalesInvoice(SalesInvoiceLine, GSTBaseAmount, GSTAmount);

            Assert.AreEqual(DetailedGSTLedgerEntry."Entry Type"::"Initial Entry", DetailedGSTLedgerEntry."Entry Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Entry Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Transaction Type"::Sales, DetailedGSTLedgerEntry."Transaction Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Document Type"::Invoice, DetailedGSTLedgerEntry."Document Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Document Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceHeader."Posting Date", DetailedGSTLedgerEntry."Posting Date",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Posting Date"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(ComponentCode, DetailedGSTLedgerEntry."GST Component Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Component Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceLine.Type, DetailedGSTLedgerEntry.Type,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption(Type), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceLine."No.", DetailedGSTLedgerEntry."No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("No."), DetailedGSTLedgerEntry.TableCaption));

            if DetailedGSTLedgerEntry.Type in [Type::Item, Type::"Fixed Asset"] then
                if Item.Get(DetailedGSTLedgerEntry."No.") then
                    ProductType := "Product Type"::Item
                else
                    ProductType := "Product Type"::"Capital Goods"
            else
                if DetailedGSTLedgerEntry.Type = DetailedGSTLedgerEntry.Type::"Charge (Item)" then
                    ProductType := ProductType::Item
                else
                    ProductType := "Product Type"::" ";

            Assert.AreEqual(ProductType, DetailedGSTLedgerEntry."Product Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Product Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Source Type"::Customer, DetailedGSTLedgerEntry."Source Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceHeader."Sell-to Customer No.", DetailedGSTLedgerEntry."Source No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceLine."HSN/SAC Code", DetailedGSTLedgerEntry."HSN/SAC Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("HSN/SAC Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceLine."GST Group Code", DetailedGSTLedgerEntry."GST Group Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Group Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(GSTAmount, DetailedGSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Amount"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceLine."GST Jurisdiction Type", DetailedGSTLedgerEntry."GST Jurisdiction Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Jurisdiction Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(GSTBaseAmount / CurrencyFactor, DetailedGSTLedgerEntry."GST Base Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Base Amount"), DetailedGSTLedgerEntry.TableCaption));

            if SalesInvoiceHeader."GST Customer Type" in [SalesInvoiceHeader."GST Customer Type"::Registered,
                SalesInvoiceHeader."GST Customer Type"::Unregistered,
                SalesInvoiceHeader."GST Customer Type"::Export,
                SalesInvoiceHeader."GST Customer Type"::"SEZ Unit"] then
                if DetailedGSTLedgerEntry."GST Jurisdiction Type" = DetailedGSTLedgerEntry."GST Jurisdiction Type"::Interstate then
                    if SalesInvoiceLine.Exempted then
                        Assert.AreEqual(0, DetailedGSTLedgerEntry."GST %",
                            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
                    else
                        Assert.AreEqual(ComponentPerArray[4], DetailedGSTLedgerEntry."GST %",
                            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
                else
                    Assert.AreEqual(ComponentPerArray[1], DetailedGSTLedgerEntry."GST %",
                        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceHeader."External Document No.", DetailedGSTLedgerEntry."External Document No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("External Document No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(-SalesInvoiceLine.Quantity, DetailedGSTLedgerEntry.Quantity,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName(Quantity), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(UserId, DetailedGSTLedgerEntryInfo."User ID",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("User ID"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(SalesInvoiceLine."Line No.", DetailedGSTLedgerEntry."Document Line No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Reverse Charge"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceHeader."Nature of Supply", DetailedGSTLedgerEntryInfo."Nature of Supply",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Nature of Supply"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(SalesInvoiceHeader."Location State Code", DetailedGSTLedgerEntryInfo."Location State Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Location State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(Customer."State Code", DetailedGSTLedgerEntryInfo."Buyer/Seller State Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Buyer/Seller State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(SalesInvoiceHeader."Location GST Reg. No.", DetailedGSTLedgerEntry."Location  Reg. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Location  Reg. No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceHeader."Customer GST Reg. No.", DetailedGSTLedgerEntry."Buyer/Seller Reg. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Buyer/Seller Reg. No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceLine."GST Group Type", DetailedGSTLedgerEntry."GST Group Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Group Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(0, DetailedGSTLedgerEntry."GST Credit",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Credit"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransactionNo, DetailedGSTLedgerEntry."Transaction No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntryInfo."Original Doc. Type"::Invoice, DetailedGSTLedgerEntryInfo."Original Doc. Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. Type"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(DocumentNo, DetailedGSTLedgerEntryInfo."Original Doc. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. No."), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(SalesInvoiceHeader."Location Code", DetailedGSTLedgerEntry."Location Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Location Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceHeader."GST Customer Type", DetailedGSTLedgerEntry."GST Customer Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Customer Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesInvoiceLine."Gen. Bus. Posting Group", DetailedGSTLedgerEntryInfo."Gen. Bus. Posting Group",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldName("Gen. Bus. Posting Group"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(SalesInvoiceLine."Gen. Prod. Posting Group", DetailedGSTLedgerEntryInfo."Gen. Prod. Posting Group",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Gen. Prod. Posting Group"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(SalesInvoiceLine."Unit of Measure Code", DetailedGSTLedgerEntryInfo.UOM,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(UOM), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(0, DetailedGSTLedgerEntry."Eligibility for ITC",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Eligibility for ITC"), DetailedGSTLedgerEntry.TableCaption));
        end;
    end;

    local procedure VerifyGSTEntriesForSalesCrMemo(
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        DocumentNo: Code[20];
        ComponentList: List of [Code[30]])
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SourceCodeSetup: Record "Source Code Setup";
        GSTGroup: Record "GST Group";
        GSTBaseAmount, GSTAmount, CurrencyFactor : Decimal;
        ComponentCode: Code[30];
        TransactionNo: Integer;
        DocumentType: Enum "Gen. Journal Document Type";
    begin
        SalesCrMemoHeader.Get(DocumentNo);

        CurrencyFactor := SalesCrMemoHeader."Currency Factor";
        if CurrencyFactor = 0 then
            CurrencyFactor := 1;

        GSTGroup.Get(SalesCrMemoLine."GST Group Code");
        SourceCodeSetup.Get();
        TransactionNo := GetTransactionNo(DocumentNo, SalesCrMemoHeader."Posting Date", DocumentType::"Credit Memo");

        foreach ComponentCode in ComponentList do begin
            GSTLedgerEntry.Reset();
            GSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            GSTLedgerEntry.SetRange("Document No.", DocumentNo);
            GSTLedgerEntry.SetRange("Posting Date", SalesCrMemoHeader."Posting Date");
            GSTLedgerEntry.SetRange("Document Type", GSTLedgerEntry."Document Type"::"Credit Memo");
            GSTLedgerEntry.FindFirst();

            GetGSTAmountsForSalesCrMemo(SalesCrMemoLine, GSTBaseAmount, GSTAmount);

            Assert.AreEqual(SalesCrMemoLine."Gen. Bus. Posting Group", GSTLedgerEntry."Gen. Bus. Posting Group",
               StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldName("Gen. Bus. Posting Group"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoLine."Gen. Prod. Posting Group", GSTLedgerEntry."Gen. Prod. Posting Group",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Gen. Prod. Posting Group"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoHeader."Posting Date", GSTLedgerEntry."Posting Date",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Posting Date"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Document Type"::"Credit Memo", GSTLedgerEntry."Document Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Document Type"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Transaction Type"::Sales, GSTLedgerEntry."Transaction Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction Type"), GSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(-GSTBaseAmount / CurrencyFactor, GSTLedgerEntry."GST Base Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Base Amount"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Source Type"::Customer, GSTLedgerEntry."Source Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Type"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoHeader."Sell-to Customer No.", GSTLedgerEntry."Source No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source No."), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(UserId, GSTLedgerEntry."User ID",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("User ID"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(SourceCodeSetup.Sales, GSTLedgerEntry."Source Code",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Code"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransactionNo, GSTLedgerEntry."Transaction No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction No."), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoHeader."External Document No.", GSTLedgerEntry."External Document No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("External Document No."), GSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(-GSTAmount, GSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Amount"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Entry Type"::"Initial Entry", GSTLedgerEntry."Entry Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Entry Type"), GSTLedgerEntry.TableCaption));
        end;
    end;

    local procedure VerifyDetailedGSTEntriesForSalesCrMemo(
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        DocumentNo: Code[20];
        ComponentList: List of [Code[30]])
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SourceCodeSetup: Record "Source Code Setup";
        Customer: Record Customer;
        Item: Record Item;
        GSTGroup: Record "GST Group";
        ProductType: Enum "Product Type";
        GSTBaseAmount, GSTAmount, CurrencyFactor : Decimal;
        ComponentCode: Code[30];
        TransactionNo: Integer;
        DocumentType: Enum "Gen. Journal Document Type";
    begin
        SalesCrMemoHeader.Get(DocumentNo);

        CurrencyFactor := SalesCrMemoHeader."Currency Factor";
        if CurrencyFactor = 0 then
            CurrencyFactor := 1;

        Customer.Get(SalesCrMemoHeader."Sell-to Customer No.");
        SourceCodeSetup.Get();

        TransactionNo := GetTransactionNo(DocumentNo, SalesCrMemoHeader."Posting Date", DocumentType::"Credit Memo");

        GSTGroup.Get(SalesCrMemoLine."GST Group Code");

        foreach ComponentCode in ComponentList do begin
            DetailedGSTLedgerEntry.Reset();
            DetailedGSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Posting Date", SalesCrMemoHeader."Posting Date");
            DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::"Credit Memo");
            DetailedGSTLedgerEntry.SetRange("Document Line No.", SalesCrMemoLine."Line No.");
            DetailedGSTLedgerEntry.FindFirst();

            DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.");

            GetGSTAmountsForSalesCrMemo(SalesCrMemoLine, GSTBaseAmount, GSTAmount);

            Assert.AreEqual(DetailedGSTLedgerEntry."Entry Type"::"Initial Entry", DetailedGSTLedgerEntry."Entry Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Entry Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Transaction Type"::Sales, DetailedGSTLedgerEntry."Transaction Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Document Type"::"Credit Memo", DetailedGSTLedgerEntry."Document Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Document Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoHeader."Posting Date", DetailedGSTLedgerEntry."Posting Date",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Posting Date"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(ComponentCode, DetailedGSTLedgerEntry."GST Component Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Component Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoLine.Type, DetailedGSTLedgerEntry.Type,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption(Type), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoLine."No.", DetailedGSTLedgerEntry."No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("No."), DetailedGSTLedgerEntry.TableCaption));

            if DetailedGSTLedgerEntry.Type in [Type::Item, Type::"Fixed Asset"] then
                if Item.Get(DetailedGSTLedgerEntry."No.") then
                    ProductType := "Product Type"::Item
                else
                    ProductType := "Product Type"::"Capital Goods"
            else
                ProductType := "Product Type"::" ";

            Assert.AreEqual(ProductType, DetailedGSTLedgerEntry."Product Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Product Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Source Type"::Customer, DetailedGSTLedgerEntry."Source Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoHeader."Sell-to Customer No.", DetailedGSTLedgerEntry."Source No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoLine."HSN/SAC Code", DetailedGSTLedgerEntry."HSN/SAC Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("HSN/SAC Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoLine."GST Group Code", DetailedGSTLedgerEntry."GST Group Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Group Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoLine."GST Jurisdiction Type", DetailedGSTLedgerEntry."GST Jurisdiction Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Jurisdiction Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(-GSTBaseAmount / CurrencyFactor, DetailedGSTLedgerEntry."GST Base Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Base Amount"), DetailedGSTLedgerEntry.TableCaption));

            if SalesCrMemoHeader."GST Customer Type" in [SalesCrMemoHeader."GST Customer Type"::Registered,
                SalesCrMemoHeader."GST Customer Type"::Unregistered,
                SalesCrMemoHeader."GST Customer Type"::Export,
                SalesCrMemoHeader."GST Customer Type"::"SEZ Unit"] then
                if DetailedGSTLedgerEntry."GST Jurisdiction Type" = DetailedGSTLedgerEntry."GST Jurisdiction Type"::Interstate then
                    Assert.AreEqual(ComponentPerArray[4], DetailedGSTLedgerEntry."GST %",
                        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
                else
                    Assert.AreEqual(ComponentPerArray[1], DetailedGSTLedgerEntry."GST %",
                        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
            else
                if SalesCrMemoHeader."GST Customer Type" = SalesCrMemoHeader."GST Customer Type"::Exempted then
                    Assert.AreEqual(0.0, DetailedGSTLedgerEntry."GST %",
                        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(-GSTAmount, DetailedGSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Amount"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoHeader."External Document No.", DetailedGSTLedgerEntry."External Document No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("External Document No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoLine.Quantity, DetailedGSTLedgerEntry.Quantity,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName(Quantity), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(UserId, DetailedGSTLedgerEntryInfo."User ID",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("User ID"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(SalesCrMemoLine."Line No.", DetailedGSTLedgerEntry."Document Line No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Reverse Charge"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoHeader."Nature of Supply", DetailedGSTLedgerEntryInfo."Nature of Supply",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Nature of Supply"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(SalesCrMemoHeader."Location State Code", DetailedGSTLedgerEntryInfo."Location State Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Location State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(Customer."State Code", DetailedGSTLedgerEntryInfo."Buyer/Seller State Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Buyer/Seller State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(SalesCrMemoHeader."Location GST Reg. No.", DetailedGSTLedgerEntry."Location  Reg. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Location  Reg. No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoHeader."Customer GST Reg. No.", DetailedGSTLedgerEntry."Buyer/Seller Reg. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Buyer/Seller Reg. No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoLine."GST Group Type", DetailedGSTLedgerEntry."GST Group Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Group Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(0, DetailedGSTLedgerEntry."GST Credit",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Credit"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransactionNo, DetailedGSTLedgerEntry."Transaction No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntryInfo."Original Doc. Type"::"Credit Memo", DetailedGSTLedgerEntryInfo."Original Doc. Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. Type"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(DocumentNo, DetailedGSTLedgerEntryInfo."Original Doc. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. No."), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(SalesCrMemoHeader."Location Code", DetailedGSTLedgerEntry."Location Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Location Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoHeader."GST Customer Type", DetailedGSTLedgerEntry."GST Customer Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Customer Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(SalesCrMemoLine."Gen. Bus. Posting Group", DetailedGSTLedgerEntryInfo."Gen. Bus. Posting Group",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldName("Gen. Bus. Posting Group"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(SalesCrMemoLine."Gen. Prod. Posting Group", DetailedGSTLedgerEntryInfo."Gen. Prod. Posting Group",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Gen. Prod. Posting Group"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(SalesCrMemoLine."Unit of Measure Code", DetailedGSTLedgerEntryInfo.UOM,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(UOM), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(0, DetailedGSTLedgerEntry."Eligibility for ITC",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Eligibility for ITC"), DetailedGSTLedgerEntry.TableCaption));
        end;
    end;

    local procedure GetGSTAmountsForSalesInvoice(SalesInvoiceLine: Record "Sales Invoice Line"; var GSTBaseAmount: Decimal; var GSTAmount: Decimal)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");

        case SalesInvoiceHeader."GST Customer Type" of
            SalesInvoiceHeader."GST Customer Type"::Registered, SalesInvoiceHeader."GST Customer Type"::Unregistered:
                if SalesInvoiceLine."Unit Price Incl. of Tax" <> 0 then begin
                    if SalesInvoiceLine."GST Jurisdiction Type" = SalesInvoiceLine."GST Jurisdiction Type"::Interstate then
                        GSTBaseAmount := ((SalesInvoiceLine."Unit Price Incl. of Tax" * SalesInvoiceLine.Quantity) * ComponentPerArray[4]) / (100 + ComponentPerArray[4])
                    else
                        GSTBaseAmount := ((SalesInvoiceLine."Unit Price Incl. of Tax" * SalesInvoiceLine.Quantity) * (2 * ComponentPerArray[1])) / (100 + (2 * ComponentPerArray[1]));
                end else
                    GSTBaseAmount := SalesInvoiceLine.Amount;

            SalesInvoiceHeader."GST Customer Type"::Exempted:
                begin
                    GSTAmount := 0.00;
                    GSTBaseAmount := SalesInvoiceLine.Amount;
                end;
        end;

        GSTBaseAmount := GSTBaseAmount - (SalesInvoiceLine."Unit Price Incl. of Tax" * SalesInvoiceLine.Quantity);

        if SalesInvoiceLine."GST Jurisdiction Type" = SalesInvoiceLine."GST Jurisdiction Type"::Interstate then
            GSTAmount := (GSTBaseAmount * ComponentPerArray[4]) / 100
        else
            GSTAmount := (GSTBaseAmount * ComponentPerArray[1]) / 100;

        if SalesInvoiceLine.Exempted then
            GSTAmount := 0.00;

        if SalesInvoiceHeader."Currency Code" <> '' then
            GSTAmount := GSTAmount / SalesInvoiceHeader."Currency Factor";
    end;

    local procedure GetGSTAmountsForSalesCrMemo(SalesCrMemoLine: Record "Sales Cr.Memo Line"; var GSTBaseAmount: Decimal; var GSTAmount: Decimal)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHeader.Get(SalesCrMemoLine."Document No.");

        case SalesCrMemoHeader."GST Customer Type" of
            SalesCrMemoHeader."GST Customer Type"::Registered, SalesCrMemoHeader."GST Customer Type"::Unregistered:
                if SalesCrMemoLine."Unit Price Incl. of Tax" <> 0 then begin
                    if SalesCrMemoLine."GST Jurisdiction Type" = SalesCrMemoLine."GST Jurisdiction Type"::Interstate then
                        GSTBaseAmount := ((SalesCrMemoLine."Unit Price Incl. of Tax" * SalesCrMemoLine.Quantity) * ComponentPerArray[4]) / (100 + ComponentPerArray[4])
                    else
                        GSTBaseAmount := ((SalesCrMemoLine."Unit Price Incl. of Tax" * SalesCrMemoLine.Quantity) * (2 * ComponentPerArray[1])) / (100 + (2 * ComponentPerArray[1]));
                end else
                    GSTBaseAmount := SalesCrMemoLine.Amount;

            SalesCrMemoHeader."GST Customer Type"::Exempted:
                begin
                    GSTAmount := 0.00;
                    GSTBaseAmount := SalesCrMemoLine.Amount;
                end;
        end;

        GSTBaseAmount := GSTBaseAmount - (SalesCrMemoLine."Unit Price Incl. of Tax" * SalesCrMemoLine.Quantity);

        if SalesCrMemoLine."GST Jurisdiction Type" = SalesCrMemoLine."GST Jurisdiction Type"::Interstate then
            GSTAmount := (GSTBaseAmount * ComponentPerArray[4]) / 100
        else
            GSTAmount := (GSTBaseAmount * ComponentPerArray[1]) / 100;

        if (SalesCrMemoLine.Exempted) then
            GSTAmount := 0.00;

        if SalesCrMemoHeader."Currency Code" <> '' then
            GSTAmount := GSTAmount / SalesCrMemoHeader."Currency Factor";
    end;

    procedure GetTransactionNo(DocumentNo: Code[20]; PostingDate: Date; DocumentType: Enum "Gen. Journal Document Type"): Integer
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("Posting Date", PostingDate);
        GLEntry.SetRange("Document Type", DocumentType);
        GLEntry.FindFirst();

        exit(GLEntry."Transaction No.");
    end;
}