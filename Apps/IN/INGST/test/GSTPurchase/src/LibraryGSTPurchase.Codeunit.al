codeunit 18140 "Library - GST Purchase"
{
    var
        Assert: Codeunit Assert;
        LibraryGST: Codeunit "Library GST";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        ComponentPerArray: array[10] of Decimal;
        Storage: Dictionary of [Text[20], Text[20]];
        StorageBoolean: Dictionary of [Text[20], Boolean];
        GSTLEVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
        CessLbl: Label 'CESS', Locked = true;
        CGSTLbl: Label 'CGST', Locked = true;
        SGSTLbl: Label 'SGST', Locked = true;
        IGSTLbl: Label 'IGST', Locked = true;
        InputCreditAvailmentLbl: Label 'InputCreditAvailment', Locked = true;
        ExemptedLbl: Label 'Exempted', Locked = true;
        LineDiscountLbl: Label 'LineDiscount', Locked = true;
        PostedDocumentNoLbl: Label 'PostedDocumentNo', Locked = true;
        GSTGroupCodeLbl: Label 'GSTGroupCode', Locked = true;
        HSNSACCodeLbl: Label 'HSNSACCode', Locked = true;

    procedure VerifyGSTEntries(DocumentNo: Code[20]; TableID: Integer; ComponentArray: array[10] of Decimal)
    var
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        ComponentList: List of [Code[30]];
    begin
        CopyArray(ComponentPerArray, ComponentArray, 1, 10);

        case TableID of
            Database::"Purch. Inv. Header":
                begin
                    PurchInvLine.SetRange("Document No.", DocumentNo);
                    PurchInvLine.SetFilter("No.", '<>%1', '');
                    PurchInvLine.FindSet();
                    FillComponentList(PurchInvLine."GST Jurisdiction Type", ComponentList, PurchInvLine."GST Group Code");
                    VerifyGSTEntriesForPurchInvoice(PurchInvLine, DocumentNo, ComponentList);
                    repeat
                        FillComponentList(PurchInvLine."GST Jurisdiction Type", ComponentList, PurchInvLine."GST Group Code");
                        VerifyDetailedGSTEntriesForPurchInvoice(PurchInvLine, DocumentNo, ComponentList);
                    until PurchInvLine.Next() = 0;
                end;
            Database::"Purch. Cr. Memo Hdr.":
                begin
                    PurchCrMemoLine.SetRange("Document No.", DocumentNo);
                    PurchCrMemoLine.SetFilter("No.", '<>%1', '');
                    PurchCrMemoLine.FindSet();

                    FillComponentList(PurchCrMemoLine."GST Jurisdiction Type", ComponentList, PurchCrMemoLine."GST Group Code");
                    VerifyGSTEntriesForPurchCrMemo(PurchCrMemoLine, DocumentNo, ComponentList);
                    repeat
                        FillComponentList(PurchCrMemoLine."GST Jurisdiction Type", ComponentList, PurchCrMemoLine."GST Group Code");
                        VerifyDetailedGSTEntriesForPurchCrMemo(PurchCrMemoLine, DocumentNo, ComponentList);
                    until PurchCrMemoLine.Next() = 0;
                end;
        end;
    end;

    procedure VerifyValueEntries(DocumentNo: Code[20]; TableID: Integer; ComponentArray: array[10] of Decimal)
    begin
        CopyArray(ComponentPerArray, ComponentArray, 1, 10);

        case TableID of
            Database::"Purch. Inv. Header":
                VerifyValueEntryPurchInvoice(DocumentNo);

            Database::"Purch. Cr. Memo Hdr.":
                VerifyValueEntryPurchCrMemo(DocumentNo);
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

        if GSTGroup."Component Calc. Type" <> GSTGroup."Component Calc. Type"::General then
            ComponentList.Add(CessLbl);
    end;

    local procedure VerifyValueEntryPurchInvoice(DocumentNo: Code[20])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        ValueEntry: Record "Value Entry";
        GSTGroup: Record "GST Group";
        TaxComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        GSTBaseAmount, GSTAmount, TotalGSTAmount : Decimal;
        CessAmount, CessPercent, CostAmount : Decimal;
    begin
        PurchInvHeader.Get(DocumentNo);

        PurchInvLine.SetRange("Document No.", DocumentNo);
        PurchInvLine.SetFilter(Type, '%1|%2', PurchInvLine.Type::"Charge (Item)", PurchInvLine.Type::Item);
        PurchInvLine.SetRange("GST Credit", PurchInvLine."GST Credit"::"Non-Availment");
        if PurchInvLine.FindSet() then
            repeat
                GSTGroup.Get(PurchInvLine."GST Group Code");

                GETGSTAmountsForPurchInvoice(PurchInvLine, GSTBaseAmount, GSTAmount);
                if GSTGroup."Component Calc. Type" <> GSTGroup."Component Calc. Type"::General then
                    GetCessAmountForPurchInvoice(PurchInvLine, GSTBaseAmount, CessAmount, CessPercent);

                if PurchInvLine."GST Jurisdiction Type" = PurchInvLine."GST Jurisdiction Type"::Interstate then
                    GSTAmount := GSTAmount + CessAmount
                else
                    GSTAmount := (GSTAmount * 2) + CessAmount;

                if PurchInvHeader."Currency Code" <> '' then
                    TotalGSTAmount += PurchInvLine.Amount + (GSTAmount * PurchInvHeader."Currency Factor")
                else
                    TotalGSTAmount += PurchInvLine.Amount + GSTAmount;

                if PurchInvHeader."GST Vendor Type" in [PurchInvHeader."GST Vendor Type"::Import, PurchInvHeader."GST Vendor Type"::SEZ] then
                    TotalGSTAmount += PurchInvLine."Custom Duty Amount";
            until PurchInvLine.Next() = 0;

        if not GSTSetup.Get() then
            exit;

        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        if PurchInvLine."GST Jurisdiction Type" = PurchInvLine."GST Jurisdiction Type"::Interstate then
            TaxComponent.SetRange(Name, IGSTLbl)
        else
            TaxComponent.SetRange(Name, CGSTLbl);
        TaxComponent.FindFirst();

        ValueEntry.SetRange("Document No.", DocumentNo);
        ValueEntry.SetRange("Posting Date", PurchInvHeader."Posting Date");
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Purchase);
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Purchase Invoice");
        if ValueEntry.FindSet() then
            repeat
                CostAmount += ValueEntry."Cost Amount (Actual)";
            until ValueEntry.Next() = 0;

        Assert.AreNearlyEqual(TotalGSTAmount, CostAmount, TaxComponent."Rounding Precision",
            StrSubstNo(GSTLEVerifyErr, ValueEntry.FieldName("Cost Amount (Actual)"), ValueEntry.TableCaption));
    end;

    local procedure VerifyValueEntryPurchCrMemo(DocumentNo: Code[20])
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        ValueEntry: Record "Value Entry";
        GSTGroup: Record "GST Group";
        TaxComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        GSTBaseAmount, GSTAmount, TotalGSTAmount : Decimal;
        CessAmount, CessPercent, CostAmount : Decimal;
    begin
        PurchCrMemoHdr.Get(DocumentNo);

        PurchCrMemoLine.SetRange("Document No.", DocumentNo);
        PurchCrMemoLine.SetFilter(Type, '%1|%2', PurchCrMemoLine.Type::"Charge (Item)", PurchCrMemoLine.Type::Item);
        PurchCrMemoLine.SetRange("GST Credit", PurchCrMemoLine."GST Credit"::"Non-Availment");
        if PurchCrMemoLine.FindSet() then
            repeat
                GSTGroup.Get(PurchCrMemoLine."GST Group Code");

                GETGSTAmountsForPurchCrMemo(PurchCrMemoLine, GSTBaseAmount, GSTAmount);
                if GSTGroup."Component Calc. Type" <> GSTGroup."Component Calc. Type"::General then
                    GetCessAmountForPurchCrMemo(PurchCrMemoLine, GSTBaseAmount, CessAmount, CessPercent);

                if PurchCrMemoLine."GST Jurisdiction Type" = PurchCrMemoLine."GST Jurisdiction Type"::Interstate then
                    GSTAmount := GSTAmount + CessAmount
                else
                    GSTAmount := (GSTAmount * 2) + CessAmount;

                if PurchCrMemoHdr."Currency Code" <> '' then
                    TotalGSTAmount += PurchCrMemoLine.Amount + (GSTAmount * PurchCrMemoHdr."Currency Factor")
                else
                    TotalGSTAmount += PurchCrMemoLine.Amount + GSTAmount;
            until PurchCrMemoLine.Next() = 0;

        if not GSTSetup.Get() then
            exit;

        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        if PurchCrMemoLine."GST Jurisdiction Type" = PurchCrMemoLine."GST Jurisdiction Type"::Interstate then
            TaxComponent.SetRange(Name, IGSTLbl)
        else
            TaxComponent.SetRange(Name, CGSTLbl);
        TaxComponent.FindFirst();

        ValueEntry.SetRange("Document No.", DocumentNo);
        ValueEntry.SetRange("Posting Date", PurchCrMemoHdr."Posting Date");
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Purchase);
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Purchase Credit Memo");
        if ValueEntry.FindSet() then
            repeat
                CostAmount += ValueEntry."Cost Amount (Actual)";
            until ValueEntry.Next() = 0;

        Assert.AreNearlyEqual(-TotalGSTAmount, CostAmount, TaxComponent."Rounding Precision",
            StrSubstNo(GSTLEVerifyErr, ValueEntry.FieldName("Cost Amount (Actual)"), ValueEntry.TableCaption));
    end;

    local procedure VerifyGSTEntriesForPurchInvoice(
        PurchInvLine: Record "Purch. Inv. Line";
        DocumentNo: Code[20];
        ComponentList: List of [Code[30]])
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        GSTPurchInvLine: Record "Purch. Inv. Line";
        SourceCodeSetup: Record "Source Code Setup";
        GSTGroup: Record "GST Group";
        GSTBaseAmount, GSTAmount : Decimal;
        CessAmount, CessPercent : Decimal;
        TotalGSTAmount, TotalCessAmount : Decimal;
        CurrencyFactor: Decimal;
        ComponentCode: Code[30];
        TransactionNo: Integer;
        DocumentType: Enum "Gen. Journal Document Type";
    begin
        PurchInvHeader.Get(DocumentNo);

        CurrencyFactor := PurchInvHeader."Currency Factor";
        if CurrencyFactor = 0 then
            CurrencyFactor := 1;

        GSTGroup.Get(PurchInvLine."GST Group Code");
        SourceCodeSetup.Get();
        TransactionNo := GetTransactionNo(DocumentNo, PurchInvHeader."Posting Date", DocumentType::Invoice);

        foreach ComponentCode in ComponentList do begin
            GSTLedgerEntry.Reset();
            GSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            GSTLedgerEntry.SetRange("Document No.", DocumentNo);
            GSTLedgerEntry.SetRange("Posting Date", PurchInvHeader."Posting Date");
            GSTLedgerEntry.SetRange("Document Type", GSTLedgerEntry."Document Type"::Invoice);
            GSTLedgerEntry.FindFirst();

            GSTPurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
            GSTPurchInvLine.SetFilter("No.", '<>%1', '');
            Clear(TotalCessAmount);
            Clear(TotalGSTAmount);
            if GSTPurchInvLine.FindSet() then
                repeat
                    GETGSTAmountsForPurchInvoice(GSTPurchInvLine, GSTBaseAmount, GSTAmount);
                    TotalGSTAmount += GSTAmount;
                    if GSTGroup."Component Calc. Type" <> GSTGroup."Component Calc. Type"::General then begin
                        GetCessAmountForPurchInvoice(GSTPurchInvLine, GSTBaseAmount, CessAmount, CessPercent);
                        TotalCessAmount += CessAmount;
                    end;
                until GSTPurchInvLine.Next() = 0;

            Assert.AreEqual(PurchInvLine."Gen. Bus. Posting Group", GSTLedgerEntry."Gen. Bus. Posting Group",
               StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldName("Gen. Bus. Posting Group"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvLine."Gen. Prod. Posting Group", GSTLedgerEntry."Gen. Prod. Posting Group",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Gen. Prod. Posting Group"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvHeader."Posting Date", GSTLedgerEntry."Posting Date",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Posting Date"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Document Type"::Invoice, GSTLedgerEntry."Document Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Document Type"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Transaction Type"::Purchase, GSTLedgerEntry."Transaction Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction Type"), GSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(GSTBaseAmount / CurrencyFactor, GSTLedgerEntry."GST Base Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Base Amount"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Source Type"::Vendor, GSTLedgerEntry."Source Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Type"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvHeader."Pay-to Vendor No.", GSTLedgerEntry."Source No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source No."), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(UserId, GSTLedgerEntry."User ID",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("User ID"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(SourceCodeSetup.Purchases, GSTLedgerEntry."Source Code",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Code"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransactionNo, GSTLedgerEntry."Transaction No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction No."), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvHeader."Vendor Invoice No.", GSTLedgerEntry."External Document No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("External Document No."), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvLine."GST Reverse Charge", GSTLedgerEntry."Reverse Charge",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Reverse Charge"), GSTLedgerEntry.TableCaption));

            if ComponentCode <> CessLbl then
                Assert.AreNearlyEqual(TotalGSTAmount, GSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
                    StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Amount"), GSTLedgerEntry.TableCaption))
            else
                Assert.AreNearlyEqual(TotalCessAmount, GSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
                    StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Amount"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Entry Type"::"Initial Entry", GSTLedgerEntry."Entry Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Entry Type"), GSTLedgerEntry.TableCaption));
        end;
    end;

    local procedure VerifyDetailedGSTEntriesForPurchInvoice(
        PurchInvLine: Record "Purch. Inv. Line";
        DocumentNo: Code[20];
        ComponentList: List of [Code[30]])
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        PurchInvHeader: Record "Purch. Inv. Header";
        SourceCodeSetup: Record "Source Code Setup";
        Vendor: Record Vendor;
        Item: Record Item;
        GSTGroup: Record "GST Group";
        ProductType: Enum "Product Type";
        GSTBaseAmount, GSTAmount, CessAmount, CessPercent, CurrencyFactor : Decimal;
        EligibilityforITC: Enum "Eligibility for ITC";
        ComponentCode: Code[30];
        ReceivableApplicable: Boolean;
        GLAccountNo: Code[20];
        TransactionNo: Integer;
        OrderAddGSTRegNo: Code[20];
        OrderAddressStateCode: code[10];
        DocumentType: Enum "Gen. Journal Document Type";
    begin
        PurchInvHeader.Get(DocumentNo);

        CurrencyFactor := PurchInvHeader."Currency Factor";
        if CurrencyFactor = 0 then
            CurrencyFactor := 1;

        Vendor.Get(PurchInvHeader."Pay-to Vendor No.");
        SourceCodeSetup.Get();

        if PurchInvHeader."Order Address Code" <> '' then begin
            OrderAddGSTRegNo := PurchInvHeader."Order Address GST Reg. No.";
            OrderAddressStateCode := PurchInvHeader."GST Order Address State";
        end else begin
            OrderAddGSTRegNo := PurchInvHeader."Vendor GST Reg. No.";
            OrderAddressStateCode := Vendor."State Code";
        end;

        TransactionNo := GetTransactionNo(DocumentNo, PurchInvHeader."Posting Date", DocumentType::Invoice);

        foreach ComponentCode in ComponentList do begin
            if (ComponentCode = CessLbl) and (PurchInvLine.Type = PurchInvLine.Type::"Charge (Item)") then
                exit;

            DetailedGSTLedgerEntry.Reset();
            DetailedGSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Document Line No.", PurchInvLine."Line No.");
            DetailedGSTLedgerEntry.SetRange("Posting Date", PurchInvHeader."Posting Date");
            DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
            DetailedGSTLedgerEntry.FindFirst();

            DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.");

            ReceivableApplicable := LibraryGST.GetReceivableApplicable(
                PurchInvHeader."GST Vendor Type",
                PurchInvLine."GST Group Type",
                PurchInvLine."GST Credit",
                PurchInvHeader."Associated Enterprises",
                PurchInvLine."GST Reverse Charge");

            GLAccountNo := LibraryGST.GetGSTAccountNo(
                PurchInvHeader."Location State Code",
                ComponentCode,
                DetailedGSTLedgerEntry."Transaction Type"::Purchase,
                DetailedGSTLedgerEntry.Type::" ",
                PurchInvLine."GST Credit",
                PurchInvHeader."GST Input Service Distribution",
                ReceivableApplicable,
                PurchInvLine."GST Group Code");

            GSTGroup.Get(PurchInvLine."GST Group Code");
            EligibilityforITC := GetEligibilityforITC(PurchInvLine."GST Credit", PurchInvLine."GST Group Type", PurchInvLine.Type);

            GETGSTAmountsForPurchInvoice(PurchInvLine, GSTBaseAmount, GSTAmount);
            if GSTGroup."Component Calc. Type" <> GSTGroup."Component Calc. Type"::General then
                GetCessAmountForPurchInvoice(PurchInvLine, GSTBaseAmount, CessAmount, CessPercent);

            Assert.AreEqual(DetailedGSTLedgerEntry."Entry Type"::"Initial Entry", DetailedGSTLedgerEntry."Entry Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Entry Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Transaction Type"::Purchase, DetailedGSTLedgerEntry."Transaction Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Document Type"::Invoice, DetailedGSTLedgerEntry."Document Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Document Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvHeader."Posting Date", DetailedGSTLedgerEntry."Posting Date",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Posting Date"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(ComponentCode, DetailedGSTLedgerEntry."GST Component Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Component Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(GLAccountNo, DetailedGSTLedgerEntry."G/L Account No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("G/L Account No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvLine.Type, DetailedGSTLedgerEntry.Type,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption(Type), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvLine."No.", DetailedGSTLedgerEntry."No.",
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

            Assert.AreEqual(DetailedGSTLedgerEntry."Source Type"::Vendor, DetailedGSTLedgerEntry."Source Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvHeader."Pay-to Vendor No.", DetailedGSTLedgerEntry."Source No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvLine."HSN/SAC Code", DetailedGSTLedgerEntry."HSN/SAC Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("HSN/SAC Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvLine."GST Group Code", DetailedGSTLedgerEntry."GST Group Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Group Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvLine."GST Jurisdiction Type", DetailedGSTLedgerEntry."GST Jurisdiction Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Jurisdiction Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(GSTBaseAmount / CurrencyFactor, DetailedGSTLedgerEntry."GST Base Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Base Amount"), DetailedGSTLedgerEntry.TableCaption));

            if ComponentCode <> CessLbl then begin
                if PurchInvHeader."GST Vendor Type" in [PurchInvHeader."GST Vendor Type"::Registered,
                    PurchInvHeader."GST Vendor Type"::Unregistered,
                    PurchInvHeader."GST Vendor Type"::Import,
                    PurchInvHeader."GST Vendor Type"::SEZ] then
                    if DetailedGSTLedgerEntry."GST Jurisdiction Type" = DetailedGSTLedgerEntry."GST Jurisdiction Type"::Interstate then
                        if PurchInvLine.Exempted then
                            Assert.AreEqual(0, DetailedGSTLedgerEntry."GST %",
                                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
                        else
                            Assert.AreEqual(ComponentPerArray[3], DetailedGSTLedgerEntry."GST %",
                                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
                    else
                        Assert.AreEqual(ComponentPerArray[1], DetailedGSTLedgerEntry."GST %",
                            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
                else
                    if PurchInvHeader."GST Vendor Type" in [PurchInvHeader."GST Vendor Type"::Composite,
                        PurchInvHeader."GST Vendor Type"::Exempted] then
                        Assert.AreEqual(0.0, DetailedGSTLedgerEntry."GST %",
                            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption));
            end else
                Assert.AreEqual(CessPercent, DetailedGSTLedgerEntry."GST %",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption));

            if ComponentCode <> CessLbl then
                Assert.AreNearlyEqual(GSTAmount, DetailedGSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Amount"), DetailedGSTLedgerEntry.TableCaption))
            else
                Assert.AreNearlyEqual(CessAmount, DetailedGSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Amount"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvHeader."Vendor Invoice No.", DetailedGSTLedgerEntry."External Document No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("External Document No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvLine.Quantity, DetailedGSTLedgerEntry.Quantity,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName(Quantity), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(UserId, DetailedGSTLedgerEntryInfo."User ID",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("User ID"), DetailedGSTLedgerEntryInfo.TableCaption));

            if ComponentCode <> CessLbl then
                if GSTAmount > 0 then
                    Assert.AreEqual(true, DetailedGSTLedgerEntryInfo.Positive,
                        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(Positive), DetailedGSTLedgerEntryInfo.TableCaption))
                else
                    Assert.AreEqual(false, DetailedGSTLedgerEntryInfo.Positive,
                        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(Positive), DetailedGSTLedgerEntryInfo.TableCaption))
            else
                if CessAmount > 0 then
                    Assert.AreEqual(true, DetailedGSTLedgerEntryInfo.Positive,
                        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(Positive), DetailedGSTLedgerEntryInfo.TableCaption))
                else
                    Assert.AreEqual(false, DetailedGSTLedgerEntryInfo.Positive,
                        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(Positive), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(PurchInvLine."Line No.", DetailedGSTLedgerEntry."Document Line No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Reverse Charge"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvLine."GST Reverse Charge", DetailedGSTLedgerEntry."Reverse Charge",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Reverse Charge"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvHeader."Nature of Supply", DetailedGSTLedgerEntryInfo."Nature of Supply",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Nature of Supply"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(PurchInvHeader."Location State Code", DetailedGSTLedgerEntryInfo."Location State Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Location State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(OrderAddressStateCode, DetailedGSTLedgerEntryInfo."Buyer/Seller State Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Buyer/Seller State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(PurchInvHeader."Location GST Reg. No.", DetailedGSTLedgerEntry."Location  Reg. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Location  Reg. No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(OrderAddGSTRegNo, DetailedGSTLedgerEntry."Buyer/Seller Reg. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Buyer/Seller Reg. No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvLine."GST Group Type", DetailedGSTLedgerEntry."GST Group Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Group Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvLine."GST Credit", DetailedGSTLedgerEntry."GST Credit",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Credit"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransactionNo, DetailedGSTLedgerEntry."Transaction No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntryInfo."Original Doc. Type"::Invoice, DetailedGSTLedgerEntryInfo."Original Doc. Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. Type"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(DocumentNo, DetailedGSTLedgerEntryInfo."Original Doc. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. No."), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(PurchInvHeader."Location Code", DetailedGSTLedgerEntry."Location Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Location Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvHeader."GST Vendor Type", DetailedGSTLedgerEntry."GST Vendor Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Vendor Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvLine."Gen. Bus. Posting Group", DetailedGSTLedgerEntryInfo."Gen. Bus. Posting Group",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldName("Gen. Bus. Posting Group"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(PurchInvLine."Gen. Prod. Posting Group", DetailedGSTLedgerEntryInfo."Gen. Prod. Posting Group",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Gen. Prod. Posting Group"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(PurchInvLine."Unit of Measure Code", DetailedGSTLedgerEntryInfo.UOM,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(UOM), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(EligibilityforITC, DetailedGSTLedgerEntry."Eligibility for ITC",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Eligibility for ITC"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchInvHeader."Order Address Code", DetailedGSTLedgerEntryInfo."Order Address Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName(Quantity), DetailedGSTLedgerEntry.TableCaption));
        end;
    end;

    local procedure VerifyGSTEntriesForPurchCrMemo(
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        DocumentNo: Code[20];
        ComponentList: List of [Code[30]])
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        SourceCodeSetup: Record "Source Code Setup";
        GSTGroup: Record "GST Group";
        GSTBaseAmount, GSTAmount, CessAmount, CessPercent, CurrencyFactor : Decimal;
        ComponentCode: Code[30];
        TransactionNo: Integer;
        DocumentType: Enum "Gen. Journal Document Type";
    begin
        PurchCrMemoHdr.Get(DocumentNo);

        CurrencyFactor := PurchCrMemoHdr."Currency Factor";
        if CurrencyFactor = 0 then
            CurrencyFactor := 1;

        GSTGroup.Get(PurchCrMemoLine."GST Group Code");
        SourceCodeSetup.Get();
        TransactionNo := GetTransactionNo(DocumentNo, PurchCrMemoHdr."Posting Date", DocumentType::"Credit Memo");

        foreach ComponentCode in ComponentList do begin
            GSTLedgerEntry.Reset();
            GSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            GSTLedgerEntry.SetRange("Document No.", DocumentNo);
            GSTLedgerEntry.SetRange("Posting Date", PurchCrMemoHdr."Posting Date");
            GSTLedgerEntry.SetRange("Document Type", GSTLedgerEntry."Document Type"::"Credit Memo");
            GSTLedgerEntry.FindFirst();

            GETGSTAmountsForPurchCrMemo(PurchCrMemoLine, GSTBaseAmount, GSTAmount);
            if GSTGroup."Component Calc. Type" <> GSTGroup."Component Calc. Type"::General then
                GetCessAmountForPurchCrMemo(PurchCrMemoLine, GSTBaseAmount, CessAmount, CessPercent);

            Assert.AreEqual(PurchCrMemoLine."Gen. Bus. Posting Group", GSTLedgerEntry."Gen. Bus. Posting Group",
               StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldName("Gen. Bus. Posting Group"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoLine."Gen. Prod. Posting Group", GSTLedgerEntry."Gen. Prod. Posting Group",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Gen. Prod. Posting Group"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoHdr."Posting Date", GSTLedgerEntry."Posting Date",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Posting Date"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Document Type"::"Credit Memo", GSTLedgerEntry."Document Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Document Type"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Transaction Type"::Purchase, GSTLedgerEntry."Transaction Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction Type"), GSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(-GSTBaseAmount / CurrencyFactor, GSTLedgerEntry."GST Base Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Base Amount"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Source Type"::Vendor, GSTLedgerEntry."Source Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Type"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoHdr."Pay-to Vendor No.", GSTLedgerEntry."Source No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source No."), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(UserId, GSTLedgerEntry."User ID",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("User ID"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(SourceCodeSetup.Purchases, GSTLedgerEntry."Source Code",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Code"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransactionNo, GSTLedgerEntry."Transaction No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction No."), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoHdr."Vendor Cr. Memo No.", GSTLedgerEntry."External Document No.",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("External Document No."), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoLine."GST Reverse Charge", GSTLedgerEntry."Reverse Charge",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Reverse Charge"), GSTLedgerEntry.TableCaption));

            if ComponentCode <> CessLbl then
                Assert.AreNearlyEqual(-GSTAmount, GSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
                    StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Amount"), GSTLedgerEntry.TableCaption))
            else
                Assert.AreNearlyEqual(-CessAmount, GSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(GSTLedgerEntry."GST Component Code"),
                    StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Amount"), GSTLedgerEntry.TableCaption));

            Assert.AreEqual(GSTLedgerEntry."Entry Type"::"Initial Entry", GSTLedgerEntry."Entry Type",
                StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Entry Type"), GSTLedgerEntry.TableCaption));
        end;
    end;

    local procedure VerifyDetailedGSTEntriesForPurchCrMemo(
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        DocumentNo: Code[20];
        ComponentList: List of [Code[30]])
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        SourceCodeSetup: Record "Source Code Setup";
        Vendor: Record Vendor;
        Item: Record Item;
        GSTGroup: Record "GST Group";
        ProductType: Enum "Product Type";
        GSTBaseAmount, GSTAmount, CessAmount, CessPercent, CurrencyFactor : Decimal;
        EligibilityforITC: Enum "Eligibility for ITC";
        ComponentCode: Code[30];
        ReceivableApplicable: Boolean;
        GLAccountNo: Code[20];
        TransactionNo: Integer;
        DocumentType: Enum "Gen. Journal Document Type";
    begin
        PurchCrMemoHdr.Get(DocumentNo);

        CurrencyFactor := PurchCrMemoHdr."Currency Factor";
        if CurrencyFactor = 0 then
            CurrencyFactor := 1;

        Vendor.Get(PurchCrMemoHdr."Pay-to Vendor No.");
        SourceCodeSetup.Get();

        TransactionNo := GetTransactionNo(DocumentNo, PurchCrMemoHdr."Posting Date", DocumentType::"Credit Memo");

        GSTGroup.Get(PurchCrMemoLine."GST Group Code");

        foreach ComponentCode in ComponentList do begin
            DetailedGSTLedgerEntry.Reset();
            DetailedGSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Posting Date", PurchCrMemoHdr."Posting Date");
            DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::"Credit Memo");
            DetailedGSTLedgerEntry.SetRange("Document Line No.", PurchCrMemoLine."Line No.");
            DetailedGSTLedgerEntry.FindFirst();

            DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.");

            EligibilityforITC := GetEligibilityforITC(PurchCrMemoLine."GST Credit", PurchCrMemoLine."GST Group Type", PurchCrMemoLine.Type);

            GETGSTAmountsForPurchCrMemo(PurchCrMemoLine, GSTBaseAmount, GSTAmount);
            if GSTGroup."Component Calc. Type" <> GSTGroup."Component Calc. Type"::General then
                GetCessAmountForPurchCrMemo(PurchCrMemoLine, GSTBaseAmount, CessAmount, CessPercent);

            ReceivableApplicable := LibraryGST.GetReceivableApplicable(
                PurchCrMemoHdr."GST Vendor Type",
                PurchCrMemoLine."GST Group Type",
                PurchCrMemoLine."GST Credit",
                PurchCrMemoHdr."Associated Enterprises",
                PurchCrMemoLine."GST Reverse Charge");

            GLAccountNo := LibraryGST.GetGSTAccountNo(
                PurchCrMemoHdr."Location State Code",
                ComponentCode,
                DetailedGSTLedgerEntry."Transaction Type"::Purchase,
                DetailedGSTLedgerEntry.Type::" ",
                PurchCrMemoLine."GST Credit",
                PurchCrMemoHdr."GST Input Service Distribution",
                ReceivableApplicable,
                PurchCrMemoLine."GST Group Code");

            Assert.AreEqual(DetailedGSTLedgerEntry."Entry Type"::"Initial Entry", DetailedGSTLedgerEntry."Entry Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Entry Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Transaction Type"::Purchase, DetailedGSTLedgerEntry."Transaction Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntry."Document Type"::"Credit Memo", DetailedGSTLedgerEntry."Document Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Document Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoHdr."Posting Date", DetailedGSTLedgerEntry."Posting Date",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Posting Date"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(ComponentCode, DetailedGSTLedgerEntry."GST Component Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Component Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(GLAccountNo, DetailedGSTLedgerEntry."G/L Account No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("G/L Account No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoLine.Type, DetailedGSTLedgerEntry.Type,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption(Type), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoLine."No.", DetailedGSTLedgerEntry."No.",
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

            Assert.AreEqual(DetailedGSTLedgerEntry."Source Type"::Vendor, DetailedGSTLedgerEntry."Source Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoHdr."Pay-to Vendor No.", DetailedGSTLedgerEntry."Source No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoLine."HSN/SAC Code", DetailedGSTLedgerEntry."HSN/SAC Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("HSN/SAC Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoLine."GST Group Code", DetailedGSTLedgerEntry."GST Group Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Group Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoLine."GST Jurisdiction Type", DetailedGSTLedgerEntry."GST Jurisdiction Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Jurisdiction Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreNearlyEqual(-GSTBaseAmount / CurrencyFactor, DetailedGSTLedgerEntry."GST Base Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Base Amount"), DetailedGSTLedgerEntry.TableCaption));

            if ComponentCode <> CessLbl then begin
                if PurchCrMemoHdr."GST Vendor Type" in [PurchCrMemoHdr."GST Vendor Type"::Registered,
                    PurchCrMemoHdr."GST Vendor Type"::Unregistered,
                    PurchCrMemoHdr."GST Vendor Type"::Import,
                    PurchCrMemoHdr."GST Vendor Type"::SEZ] then
                    if DetailedGSTLedgerEntry."GST Jurisdiction Type" = DetailedGSTLedgerEntry."GST Jurisdiction Type"::Interstate then
                        Assert.AreEqual(ComponentPerArray[3], DetailedGSTLedgerEntry."GST %",
                            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
                    else
                        Assert.AreEqual(ComponentPerArray[1], DetailedGSTLedgerEntry."GST %",
                            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
                else
                    if PurchCrMemoHdr."GST Vendor Type" in [PurchCrMemoHdr."GST Vendor Type"::Composite,
                        PurchCrMemoHdr."GST Vendor Type"::Exempted] then
                        Assert.AreEqual(0.0, DetailedGSTLedgerEntry."GST %",
                            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption));
            end else
                Assert.AreEqual(CessPercent, DetailedGSTLedgerEntry."GST %",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption));

            if ComponentCode <> CessLbl then
                Assert.AreNearlyEqual(-GSTAmount, DetailedGSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Amount"), DetailedGSTLedgerEntry.TableCaption))
            else
                Assert.AreNearlyEqual(-CessAmount, DetailedGSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Amount"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoHdr."Vendor Cr. Memo No.", DetailedGSTLedgerEntry."External Document No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("External Document No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoLine.Quantity, DetailedGSTLedgerEntry.Quantity,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName(Quantity), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(UserId, DetailedGSTLedgerEntryInfo."User ID",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("User ID"), DetailedGSTLedgerEntryInfo.TableCaption));

            if ComponentCode <> CessLbl then
                if -GSTAmount > 0 then
                    Assert.AreEqual(true, DetailedGSTLedgerEntryInfo.Positive,
                        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(Positive), DetailedGSTLedgerEntryInfo.TableCaption))
                else
                    Assert.AreEqual(false, DetailedGSTLedgerEntryInfo.Positive,
                        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(Positive), DetailedGSTLedgerEntryInfo.TableCaption))
            else
                if -CessAmount > 0 then
                    Assert.AreEqual(true, DetailedGSTLedgerEntryInfo.Positive,
                        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(Positive), DetailedGSTLedgerEntryInfo.TableCaption))
                else
                    Assert.AreEqual(false, DetailedGSTLedgerEntryInfo.Positive,
                        StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(Positive), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(PurchCrMemoLine."Line No.", DetailedGSTLedgerEntry."Document Line No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Reverse Charge"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoLine."GST Reverse Charge", DetailedGSTLedgerEntry."Reverse Charge",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Reverse Charge"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoHdr."Nature of Supply", DetailedGSTLedgerEntryInfo."Nature of Supply",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Nature of Supply"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(PurchCrMemoHdr."Location State Code", DetailedGSTLedgerEntryInfo."Location State Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Location State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(Vendor."State Code", DetailedGSTLedgerEntryInfo."Buyer/Seller State Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Buyer/Seller State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(PurchCrMemoHdr."Location GST Reg. No.", DetailedGSTLedgerEntry."Location  Reg. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Location  Reg. No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoHdr."Vendor GST Reg. No.", DetailedGSTLedgerEntry."Buyer/Seller Reg. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Buyer/Seller Reg. No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoLine."GST Group Type", DetailedGSTLedgerEntry."GST Group Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Group Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoLine."GST Credit", DetailedGSTLedgerEntry."GST Credit",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Credit"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(TransactionNo, DetailedGSTLedgerEntry."Transaction No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction No."), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(DetailedGSTLedgerEntryInfo."Original Doc. Type"::"Credit Memo", DetailedGSTLedgerEntryInfo."Original Doc. Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. Type"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(DocumentNo, DetailedGSTLedgerEntryInfo."Original Doc. No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. No."), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(PurchCrMemoHdr."Location Code", DetailedGSTLedgerEntry."Location Code",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Location Code"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoHdr."GST Vendor Type", DetailedGSTLedgerEntry."GST Vendor Type",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Vendor Type"), DetailedGSTLedgerEntry.TableCaption));

            Assert.AreEqual(PurchCrMemoLine."Gen. Bus. Posting Group", DetailedGSTLedgerEntryInfo."Gen. Bus. Posting Group",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldName("Gen. Bus. Posting Group"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(PurchCrMemoLine."Gen. Prod. Posting Group", DetailedGSTLedgerEntryInfo."Gen. Prod. Posting Group",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Gen. Prod. Posting Group"), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(PurchCrMemoLine."Unit of Measure Code", DetailedGSTLedgerEntryInfo.UOM,
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(UOM), DetailedGSTLedgerEntryInfo.TableCaption));

            Assert.AreEqual(EligibilityforITC, DetailedGSTLedgerEntry."Eligibility for ITC",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Eligibility for ITC"), DetailedGSTLedgerEntry.TableCaption));
        end;
    end;

    procedure GetEligibilityforITC(
        GSTCredit: Enum "GST Credit";
        GSTGroupType: Enum "GST Group Type";
        Type: Enum "Purchase Line Type")
        EligibilityforITC: Enum "Eligibility for ITC"
    begin
        if GSTCredit = "GST Credit"::"Non-Availment" then
            EligibilityforITC := "Eligibility for ITC"::Ineligible
        else
            if GSTCredit = "GST Credit"::Availment then
                if GSTGroupType = "GST Group Type"::Service then
                    EligibilityforITC := "Eligibility for ITC"::"Input Services"
                else
                    if Type = Type::"Fixed Asset" then
                        EligibilityforITC := "Eligibility for ITC"::"Capital goods"
                    else
                        EligibilityforITC := "Eligibility for ITC"::Inputs;
    end;

    local procedure GETGSTAmountsForPurchInvoice(PurchInvLine: Record "Purch. Inv. Line"; var GSTBaseAmount: Decimal; var GSTAmount: Decimal)
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        PurchInvHeader.Get(PurchInvLine."Document No.");

        case PurchInvHeader."GST Vendor Type" of
            PurchInvHeader."GST Vendor Type"::Registered, PurchInvHeader."GST Vendor Type"::Unregistered:
                GSTBaseAmount := PurchInvLine.Amount;

            PurchInvHeader."GST Vendor Type"::Import, PurchInvHeader."GST Vendor Type"::SEZ:
                if PurchInvLine.Type = PurchInvLine.Type::"G/L Account" then
                    GSTBaseAmount := PurchInvLine.Amount
                else
                    GSTBaseAmount := PurchInvLine."GST Assessable Value" + PurchInvLine."Custom Duty Amount";

            PurchInvHeader."GST Vendor Type"::Composite, PurchInvHeader."GST Vendor Type"::Exempted:
                begin
                    GSTAmount := 0.00;
                    GSTBaseAmount := PurchInvLine.Amount;
                end;
        end;

        if PurchInvLine."GST Jurisdiction Type" = PurchInvLine."GST Jurisdiction Type"::Interstate then
            GSTAmount := (GSTBaseAmount * ComponentPerArray[3]) / 100
        else
            GSTAmount := (GSTBaseAmount * ComponentPerArray[1]) / 100;

        if PurchInvLine.Exempted then
            GSTAmount := 0.00;

        if PurchInvHeader."Currency Code" <> '' then
            GSTAmount := GSTAmount / PurchInvHeader."Currency Factor";
    end;

    local procedure GETGSTAmountsForPurchCrMemo(PurchCrMemoLine: Record "Purch. Cr. Memo Line"; var GSTBaseAmount: Decimal; var GSTAmount: Decimal)
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        PurchCrMemoHdr.Get(PurchCrMemoLine."Document No.");

        case PurchCrMemoHdr."GST Vendor Type" of
            PurchCrMemoHdr."GST Vendor Type"::Registered, PurchCrMemoHdr."GST Vendor Type"::Unregistered,
            PurchCrMemoHdr."GST Vendor Type"::Import, PurchCrMemoHdr."GST Vendor Type"::SEZ:
                GSTBaseAmount := PurchCrMemoLine.Amount;

            PurchCrMemoHdr."GST Vendor Type"::Composite, PurchCrMemoHdr."GST Vendor Type"::Exempted:
                begin
                    GSTAmount := 0.00;
                    GSTBaseAmount := PurchCrMemoLine.Amount;
                end;
        end;

        if PurchCrMemoLine."GST Jurisdiction Type" = PurchCrMemoLine."GST Jurisdiction Type"::Interstate then
            GSTAmount := (GSTBaseAmount * ComponentPerArray[3]) / 100
        else
            GSTAmount := (GSTBaseAmount * ComponentPerArray[1]) / 100;

        if (PurchCrMemoLine.Exempted) or (PurchCrMemoHdr."GST Vendor Type" = PurchCrMemoHdr."GST Vendor Type"::Composite) then
            GSTAmount := 0.00;

        if PurchCrMemoHdr."Currency Code" <> '' then
            GSTAmount := GSTAmount / PurchCrMemoHdr."Currency Factor";
    end;

    local procedure GetCessAmountForPurchInvoice(PurchInvLine: Record "Purch. Inv. Line"; GSTBaseAmount: Decimal; var CessAmount: Decimal; var CessPercent: Decimal)
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        GSTGroup: Record "GST Group";
        CompareAmount, CurrencyFactor : Decimal;
        CessAmountByCessPercent, CessAmountByUnitFactor : Decimal;
    begin
        Clear(CessAmount);
        if PurchInvLine.Type = PurchInvLine.Type::"Charge (Item)" then
            exit;

        PurchInvHeader.Get(PurchInvLine."Document No.");
        GSTGroup.Get(PurchInvLine."GST Group Code");

        if PurchInvHeader."Currency Code" <> '' then
            CurrencyFactor := PurchInvHeader."Currency Factor"
        else
            CurrencyFactor := 1;

        CompareAmount := PurchInvLine.Amount / CurrencyFactor;

        case GSTGroup."Component Calc. Type" of
            "Component Calc Type"::"Cess %":
                begin
                    CessAmount := ((GSTBaseAmount * ComponentPerArray[5]) / 100) / CurrencyFactor;
                    CessPercent := ComponentPerArray[5];
                end;

            "Component Calc Type"::Threshold:
                if CompareAmount <= ComponentPerArray[7] then begin
                    CessAmount := ((GSTBaseAmount * ComponentPerArray[6]) / 100) / CurrencyFactor;
                    CessPercent := ComponentPerArray[6];
                end else begin
                    CessAmount := ((GSTBaseAmount * ComponentPerArray[5]) / 100) / CurrencyFactor;
                    CessPercent := ComponentPerArray[5];
                end;

            "Component Calc Type"::"Amount / Unit Factor":
                begin
                    CessAmount := (((CurrencyFactor * ComponentPerArray[8]) / ComponentPerArray[9]) * PurchInvLine.Quantity);
                    CessAmount := CessAmount / CurrencyFactor;
                    CessPercent := 0;
                end;

            "Component Calc Type"::"Cess % + Amount / Unit Factor":
                begin
                    CessAmount := ((GSTBaseAmount * ComponentPerArray[5]) / 100) / CurrencyFactor;
                    CessAmount += (((CurrencyFactor * ComponentPerArray[8]) / ComponentPerArray[9]) * PurchInvLine.Quantity) / CurrencyFactor;
                    CessPercent := 0;
                end;

            "Component Calc Type"::"Cess % Or Amount / Unit Factor Whichever Higher":
                begin
                    CessAmountByCessPercent := ((GSTBaseAmount * ComponentPerArray[5]) / 100) / CurrencyFactor;
                    CessAmountByUnitFactor := (((CurrencyFactor * ComponentPerArray[8]) / ComponentPerArray[9]) * PurchInvLine.Quantity) / CurrencyFactor;
                    if CessAmountByCessPercent >= CessAmountByUnitFactor then begin
                        CessAmount := CessAmountByCessPercent;
                        CessPercent := ComponentPerArray[5];
                    end else begin
                        CessAmount := CessAmountByUnitFactor;
                        CessPercent := 0;
                    end;
                end;
        end;
    end;

    local procedure GetCessAmountForPurchCrMemo(PurchCrMemoLine: Record "Purch. Cr. Memo Line"; GSTBaseAmount: Decimal; var CessAmount: Decimal; var CessPercent: Decimal)
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        GSTGroup: Record "GST Group";
        CompareAmount, CurrencyFactor : Decimal;
        CessAmountByCessPercent, CessAmountByUnitFactor : Decimal;
    begin
        PurchCrMemoHdr.Get(PurchCrMemoLine."Document No.");
        GSTGroup.Get(PurchCrMemoLine."GST Group Code");

        if PurchCrMemoHdr."Currency Code" <> '' then
            CurrencyFactor := PurchCrMemoHdr."Currency Factor"
        else
            CurrencyFactor := 1;

        CompareAmount := PurchCrMemoLine.Amount / CurrencyFactor;

        case GSTGroup."Component Calc. Type" of
            "Component Calc Type"::"Cess %":
                begin
                    CessAmount := ((GSTBaseAmount * ComponentPerArray[5]) / 100) / CurrencyFactor;
                    CessPercent := ComponentPerArray[5];
                end;

            "Component Calc Type"::Threshold:
                if CompareAmount <= ComponentPerArray[7] then begin
                    CessAmount := ((GSTBaseAmount * ComponentPerArray[6]) / 100) / CurrencyFactor;
                    CessPercent := ComponentPerArray[6];
                end else begin
                    CessAmount := ((GSTBaseAmount * ComponentPerArray[5]) / 100) / CurrencyFactor;
                    CessPercent := ComponentPerArray[5];
                end;

            "Component Calc Type"::"Amount / Unit Factor":
                begin
                    CessAmount := (((CurrencyFactor * ComponentPerArray[8]) / ComponentPerArray[9]) * PurchCrMemoLine.Quantity);
                    CessAmount := CessAmount / CurrencyFactor;
                    CessPercent := 0;
                end;

            "Component Calc Type"::"Cess % + Amount / Unit Factor":
                begin
                    CessAmount := ((GSTBaseAmount * ComponentPerArray[5]) / 100) / CurrencyFactor;
                    CessAmount += (((CurrencyFactor * ComponentPerArray[8]) / ComponentPerArray[9]) * PurchCrMemoLine.Quantity) / CurrencyFactor;
                    CessPercent := 0;
                end;

            "Component Calc Type"::"Cess % Or Amount / Unit Factor Whichever Higher":
                begin
                    CessAmountByCessPercent := ((GSTBaseAmount * ComponentPerArray[5]) / 100) / CurrencyFactor;
                    CessAmountByUnitFactor := (((CurrencyFactor * ComponentPerArray[8]) / ComponentPerArray[9]) * PurchCrMemoLine.Quantity) / CurrencyFactor;
                    if CessAmountByCessPercent >= CessAmountByUnitFactor then begin
                        CessAmount := CessAmountByCessPercent;
                        CessPercent := ComponentPerArray[5];
                    end else begin
                        CessAmount := CessAmountByUnitFactor;
                        CessPercent := 0;
                    end;
                end;
        end;
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

    procedure VerifyTaxTransactionForPurchaseQuote(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxAmount: Decimal;
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetFilter("No.", '<>%1', '');
        if PurchaseLine.FindSet() then
            repeat
                TaxAmount += GetTaxAmount(PurchaseLine.RecordId);
            until PurchaseLine.Next() = 0;

        if PurchaseLine.Exempted then
            Assert.AreEqual(TaxAmount, 0, StrSubstNo(GSTLEVerifyErr, TaxTransactionValue.FieldCaption(Amount), TaxTransactionValue.TableCaption))
        else
            Assert.AreNotEqual(TaxAmount, 0, StrSubstNo(GSTLEVerifyErr, TaxTransactionValue.FieldCaption(Amount), TaxTransactionValue.TableCaption));
    end;

    local procedure GetTaxAmount(RecID: RecordId): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTAmount: Decimal;
    begin
        TaxTransactionValue.SetRange("Tax Record ID", RecID);
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        if TaxTransactionValue.FindSet() then
            repeat
                GSTAmount += TaxTransactionValue.Amount;
            until TaxTransactionValue.Next() = 0;

        exit(GSTAmount);
    end;

    procedure UpdateVendorSetupWithGST(
        VendorNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        AssociateEnterprise: boolean;
        StateCode: Code[10];
        PANNo: Code[20]);
    var
        Vendor: Record Vendor;
        State: Record State;
        Currency: Record Currency;
    begin
        Vendor.Get(VendorNo);
        if (GSTVendorType <> GSTVendorType::Import) then begin
            State.Get(StateCode);
            Vendor.Validate("State Code", StateCode);
            Vendor.Validate("P.A.N. No.", PANNo);
            if not ((GSTVendorType = GSTVendorType::" ") or (GSTVendorType = GSTVendorType::Unregistered)) then
                Vendor.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", PANNo));
        end;

        Vendor.Validate("GST Vendor Type", GSTVendorType);
        if Vendor."GST Vendor Type" = vendor."GST Vendor Type"::Import then begin
            LibraryERM.CreateCurrency(Currency);
            LibraryERM.CreateRandomExchangeRate(Currency.Code);
            Vendor.Validate("Currency Code", Currency.Code);
            vendor.Validate("Associated Enterprises", AssociateEnterprise);
        end;
        Vendor.Modify(true);
    end;

    procedure UpdateReferenceInvoiceNoAndVerify(var PurchaseHeader: Record "Purchase Header"; PostedDocumentNo: Code[20])
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        ReferenceInvoiceNoMgt: Codeunit "Reference Invoice No. Mgt.";
    begin
        ReferenceInvoiceNo.Init();
        ReferenceInvoiceNo.Validate("Document No.", PurchaseHeader."No.");
        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::"Credit Memo":
                ReferenceInvoiceNo.Validate("Document Type", ReferenceInvoiceNo."Document Type"::"Credit Memo");
            PurchaseHeader."Document Type"::"Return Order":
                ReferenceInvoiceNo.Validate("Document Type", ReferenceInvoiceNo."Document Type"::"Return Order");
        end;

        ReferenceInvoiceNo.Validate("Source Type", ReferenceInvoiceNo."Source Type"::Vendor);
        ReferenceInvoiceNo.Validate("Source No.", PurchaseHeader."Buy-from Vendor No.");
        ReferenceInvoiceNo.Validate("Reference Invoice Nos.", PostedDocumentNo);
        ReferenceInvoiceNo.Insert(true);

        ReferenceInvoiceNoMgt.UpdateReferenceInvoiceNoforVendor(ReferenceInvoiceNo, ReferenceInvoiceNo."Document Type", ReferenceInvoiceNo."Document No.");
        ReferenceInvoiceNoMgt.VerifyReferenceNo(ReferenceInvoiceNo);
    end;

    procedure CreateGSTComponentAndPostingSetup(
        IntraState: Boolean;
        LocationStateCode: Code[10];
        TaxComponent: Record "Tax Component";
        GSTComponentCode: Text[30])
    begin
        if IntraState then begin
            GSTComponentCode := CGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

            GSTComponentCode := SGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end else begin
            GSTComponentCode := IGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end;
    end;

    procedure CreateItemChargeAssignment(
        var ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        PurchaseLine: Record "Purchase Line";
        DocType: Enum "Purchase Document Type";
        DocNo: Code[20];
        DocLineNo: Integer;
        ItemNo: Code[20])
    var
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        LibraryInventory.CreateItemChargeAssignPurchase(ItemChargeAssignmentPurch, PurchaseLine, DocType, DocNo, DocLineNo, ItemNo);

        ItemChargeAssignmentPurch.Validate("Qty. to Assign", PurchaseLine.Quantity);
        ItemChargeAssignmentPurch.Modify(true);
    end;

    procedure CreateAndPostPurchaseDocWithChargeItem(var PurchaseHeader: Record "Purchase Header"): Code[20]
    var
        NewPurchaseLine: Record "Purchase Line";
        PurchaseLine: Record "Purchase Line";
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        DocumentNo: Code[20];
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.SetFilter("No.", '<>%1', '');
        PurchaseLine.FindFirst();

        CreatePurchaseLineWithGST(
            PurchaseHeader,
            NewPurchaseLine,
            NewPurchaseLine.Type::"Charge (Item)",
            StorageBoolean.Get(InputCreditAvailmentLbl),
            StorageBoolean.Get(ExemptedLbl),
            StorageBoolean.Get(LineDiscountLbl),
            1);

        CreateItemChargeAssignment(
            ItemChargeAssignmentPurch,
            NewPurchaseLine,
            PurchaseHeader."Document Type",
            PurchaseHeader."No.",
            PurchaseLine."Line No.",
            PurchaseLine."No.");

        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, DocumentNo);

        exit(DocumentNo);
    end;

    procedure CreatePurchaseHeaderWithGST(
        VAR PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
        DocumentType: Enum "Purchase Document Type";
        LocationCode: Code[10];
        PurchaseInvoiceType: Enum "GST Invoice Type")
    var
        LibraryUtility: Codeunit "Library - Utility";
        Overseas: Boolean;
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Validate("Location Code", LocationCode);

        if Overseas then
            PurchaseHeader.Validate("POS Out Of India", true);

        if PurchaseInvoiceType in [PurchaseInvoiceType::"Debit Note", PurchaseInvoiceType::Supplementary] then
            PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateRandomCode(PurchaseHeader.fieldno("Vendor Invoice No."), Database::"Purchase Header"))
        else
            PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateRandomCode(PurchaseHeader.fieldno("Vendor Cr. Memo No."), Database::"Purchase Header"));

        if PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::SEZ then begin
            PurchaseHeader."Bill of Entry No." := LibraryUtility.GenerateRandomCode(PurchaseHeader.fieldno("Bill of Entry No."), Database::"Purchase Header");
            PurchaseHeader."Bill of Entry Date" := WorkDate();
            PurchaseHeader."Bill of Entry Value" := LibraryRandom.RandInt(1000);
        end;

        PurchaseHeader.Modify(true);
    end;

    procedure CreatePurchaseLineWithGST(
        var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        InputCreditAvailment: Boolean;
        Exempted: Boolean;
        LineDiscount: Boolean;
        NoOfLine: Integer);
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LineTypeNo: Code[20];
        LineNo: Integer;
    begin
        for LineNo := 1 to NoOfLine do begin
            case LineType of
                LineType::Item:
                    LineTypeNo := LibraryGST.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, Exempted);
                LineType::"G/L Account":
                    LineTypeNo := LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, Exempted);
                LineType::"Fixed Asset":
                    LineTypeNo := LibraryGST.CreateFixedAssetWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, Exempted);
                LineType::"Charge (Item)":
                    LineTypeNo := LibraryGST.CreateChargeItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, Exempted);
            end;

            LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, LineType, LineTypeno, LibraryRandom.RandDecInRange(2, 10, 0));

            PurchaseLine.Validate("VAT Prod. Posting Group", VATPostingsetup."VAT Prod. Posting Group");
            if InputCreditAvailment then
                PurchaseLine."GST Credit" := PurchaseLine."GST Credit"::Availment
            else
                PurchaseLine."GST Credit" := PurchaseLine."GST Credit"::"Non-Availment";

            if LineDiscount then begin
                PurchaseLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));
                LibraryGST.UpdateLineDiscAccInGeneralPostingSetup(PurchaseLine."Gen. Bus. Posting Group", PurchaseLine."Gen. Prod. Posting Group");
            end;

            if ((PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ])) and (PurchaseLine.Type = PurchaseLine.Type::"Fixed Asset") then
                PurchaseLine.Validate("GST Assessable Value", LibraryRandom.RandInt(1000))
            else
                if (PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ]) then begin
                    PurchaseLine.Validate("GST Assessable Value", LibraryRandom.RandInt(1000));
                    PurchaseLine.Validate("Custom Duty Amount", LibraryRandom.RandInt(1000));
                end;
            PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandInt(1000));
            PurchaseLine.Modify(true);
        end;
    end;

    procedure SetStorageLibraryPurchaseText(FromStorage: Dictionary of [Text[20], Text[20]])
    begin
        Storage := FromStorage;
    end;

    procedure SetStorageLibraryPurchaseBoolean(FromStorage: Dictionary of [Text[20], Boolean])
    begin
        StorageBoolean := FromStorage;
    end;
}