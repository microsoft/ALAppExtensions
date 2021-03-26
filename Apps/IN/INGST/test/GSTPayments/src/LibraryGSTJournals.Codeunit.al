codeunit 18274 "Library GST Journals"
{
    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryGST: Codeunit "Library GST";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryRandom: Codeunit "Library - Random";
        Storage: Dictionary of [Text[20], Text[20]];
        StorageBoolean: Dictionary of [Text[20], Boolean];
        AccountNoLbl: Label 'AccountNo', locked = true;
        LocationCodeLbl: Label 'LocationCode', Locked = true;
        AccountTypeLbl: Label 'AccountType', Locked = true;
        CustomerNoLbl: Label 'CustomerNo', Locked = true;
        GSTGroupCodeLbl: Label 'GSTGroupCode', Locked = true;
        HSNSACCodeLbl: Label 'HSNSACCode', Locked = true;
        ExemptedLbl: Label 'Exempted', Locked = true;
        TemplateNameLbl: Label 'TemplateName', Locked = true;

    procedure CreateSecondGenJnlLineFromCustomerToGLForInvoice(var GenJournalLine: Record "Gen. Journal Line")
    var
        InsertGenJournalLine: Record "Gen. Journal Line";
    begin
        InsertGenJournalLine.Init();
        InsertGenJournalLine := GenJournalLine;
        InsertGenJournalLine."Line No." := GenJournalLine."Line No." + 10000;
        InsertGenJournalLine.Insert(true);
    end;

    procedure CreateLocationWithVoucherSetup(Type: Enum "Gen. Journal Template Type")
    var
        BankAccount: Record "Bank Account";
        GLAccount: Record "G/L Account";
        Location: Record Location;
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LocationCode: Code[10];
        AccountType: Enum "Gen. Journal Account Type";
    begin
        LocationCode := LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        case Type of
            Type::"Bank Payment Voucher", Type::"Bank Receipt Voucher":
                begin
                    LibraryERM.CreateBankAccount(BankAccount);
                    Storage.Set(AccountNoLbl, BankAccount."No.");
                    Storage.Set(AccountTypeLbl, Format(AccountType::"Bank Account"));
                    CreateVoucherAccountSetup(Type, LocationCode);
                end;
            Type::"Contra Voucher", Type::"Cash Receipt Voucher":
                begin
                    LibraryERM.CreateGLAccount(GLAccount);
                    Storage.Set(AccountNoLbl, GLAccount."No.");
                    Storage.Set(AccountTypeLbl, Format(AccountType::"G/L Account"));
                    CreateVoucherAccountSetup(Type, LocationCode);
                end;
        end;
    end;

    local procedure CreateVoucherAccountSetup(SubType: Enum "Gen. Journal Template Type"; LocationCode: Code[10])
    var
        TaxBaseTestPublishers: Codeunit "Tax Base Test Publishers";
        TransactionDirection: Option " ",Debit,Credit,Both;
        AccountNo: Code[20];
    begin
        AccountNo := CopyStr(Storage.Get(AccountNoLbl), 1, MaxStrLen(AccountNo));
        case SubType of
            SubType::"Bank Payment Voucher", SubType::"Cash Payment Voucher", SubType::"Contra Voucher":
                begin
                    TaxBaseTestPublishers.InsertJournalVoucherPostingSetupWithLocationCode(SubType, LocationCode, TransactionDirection::Credit);
                    TaxBaseTestPublishers.InsertVoucherCreditAccountNoWithLocationCode(SubType, LocationCode, AccountNo);
                end;
            SubType::"Cash Receipt Voucher", SubType::"Bank Receipt Voucher", SubType::"Journal Voucher":
                begin
                    TaxBaseTestPublishers.InsertJournalVoucherPostingSetupWithLocationCode(SubType, LocationCode, TransactionDirection::Debit);
                    TaxBaseTestPublishers.InsertVoucherDebitAccountNoWithLocationCode(SubType, LocationCode, AccountNo);
                end;
        end;
    end;

    procedure ProvidePOSOutofIndiaMultiLineValue(
        var GenJournalLine: Record "Gen. Journal Line";
        GSTPlaceOfSupply: Enum "GST Dependency Type";
        GSTCustomerType: Enum "GST Customer Type")
    begin
        GenJournalLine."POS Out Of India" := true;
        GenJournalLine."Old Document No." := GenJournalLine."Document No.";
        GenJournalLine."Location State Code" := GenJournalLine."GST Ship-to State Code";
        GenJournalLine."GST Place of Supply" := GSTPlaceOfSupply;
        GenJournalLine."GST Customer Type" := GSTCustomerType;
        GenJournalLine.Modify(true);
    end;

    procedure CreateGenJnlLineFromPartyTypeCustomerToGLForInvoice(var GenJournalLine: Record "Gen. Journal Line"; TemplateType: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VATPostingSetup: Record "VAT Posting Setup";
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, TemplateType);
        CustomerNo := CopyStr(Storage.Get(CustomerNoLbl), 1, 20);
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        LibraryJournals.CreateGenJournalLine(
            GenJournalLine,
            GenJournalTemplate.Name,
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::"G/L Account", '',
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryGST.CreateGLAccWithGSTDetails(
                VATPostingSetup,
                CopyStr(Storage.Get(GSTGroupCodeLbl), 1, 20),
                CopyStr(Storage.Get(HSNSACCodeLbl), 1, 10),
                true, StorageBoolean.Get(ExemptedLbl)),
                LibraryRandom.RandIntInRange(1, 100000));
        GenJournalLine.Validate("Party Type", GenJournalLine."Party Type"::Customer);
        GenJournalLine.Validate("Party Code", CustomerNo);
        GenJournalLine.Validate("Location Code", LocationCode);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::Sale);
        GenJournalLine.Modify(true);
    end;

    procedure CreateGenJournalTemplateBatch(
        var GenJournalTemplate: Record "Gen. Journal Template";
        var GenJournalBatch: Record "Gen. Journal Batch";
        TemplateType: Enum "Gen. Journal Template Type")
    var
        LocationCode: Code[10];
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, TemplateType);
        GenJournalTemplate.Modify(true);

        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Location Code", LocationCode);
        GenJournalBatch.Modify(true);
    end;

    procedure CreateGenJnlLineFromCustomerToGLForInvoice(
    var GenJournalLine: Record "Gen. Journal Line";
    TemplateType: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VATPostingSetup: Record "VAT Posting Setup";
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, TemplateType);
        CustomerNo := CopyStr(Storage.Get(CustomerNoLbl), 1, 20);
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
            GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, CopyStr(Storage.Get(GSTGroupCodeLbl), 1, 20), CopyStr(Storage.Get(HSNSACCodeLbl), 1, 10), true, StorageBoolean.Get(ExemptedLbl)),
            LibraryRandom.RandIntInRange(1, 100000));
        GenJournalLine.Validate("Location Code", LocationCode);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::Sale);
        CalculateGST(GenJournalLine);
        GenJournalLine.Modify(true);
    end;

    procedure CreateGenJnlLineFromCustomerToGLForCreditMemo(
        var GenJournalLine: Record "Gen. Journal Line";
        TemplateType: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VATPostingSetup: Record "VAT Posting Setup";
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, TemplateType);
        Storage.Set(TemplateNameLbl, GenJournalTemplate.Name);
        CustomerNo := CopyStr(Storage.Get(CustomerNoLbl), 1, 20);
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));

        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
            GenJournalLine."Document Type"::"Credit Memo",
            GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, CopyStr(Storage.Get(GSTGroupCodeLbl), 1, 20), CopyStr(Storage.Get(HSNSACCodeLbl), 1, 10), true, StorageBoolean.Get(ExemptedLbl)),
            -LibraryRandom.RandIntInRange(1, 100000));

        GenJournalLine.Validate("Location Code", LocationCode);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::Sale);
        GenJournalLine.Modify(true);
        CalculateGST(GenJournalLine);

        UpdateReferenceInvoiceNoAndVerify();
    end;

    local procedure UpdateReferenceInvoiceNoAndVerify()
    var
        SalesJournal: TestPage "Sales Journal";
    begin
        SalesJournal.OpenEdit();
        SalesJournal."Update Reference Invoice No.".Invoke();
    end;

    procedure UpdateCustomerSetupWithGST(
        CustomerNo: Code[20];
        GSTCustomerType: Enum "GST Customer Type";
        StateCode: Code[10];
        PANNo: Code[20])
    var
        Customer: Record Customer;
        State: Record State;
    begin
        Customer.Get(CustomerNo);
        if (GSTCustomerType <> GSTCustomerType::Export) then begin
            State.Get(StateCode);
            Customer.Validate("State Code", StateCode);
            Customer.Validate("P.A.N. No.", PANNo);
            if not ((GSTCustomerType = GSTCustomerType::" ") or (GSTCustomerType = GSTCustomerType::Unregistered)) then
                Customer.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", PANNo));
        end else
            Customer.Validate("Currency Code", LibraryGST.CreateCurrencyCode());
        Customer.Validate("GST Customer Type", GSTCustomerType);
        Customer.Modify(true);
    end;

    procedure CreateGenJnlLineForVoucherWithoutAdvancePayment(
        var GenJournalLine: Record "Gen. Journal Line";
        TemplateType: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        CustomerNo: Code[20];
        LocationCode: Code[10];
        AccountType: Enum "Gen. Journal Account Type";
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, TemplateType);
        CustomerNo := CopyStr(Storage.Get(CustomerNoLbl), 1, 20);
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        Evaluate(AccountType, Storage.Get(AccountTypeLbl));
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::Customer, CustomerNo,
            AccountType,
            CopyStr(Storage.Get(AccountNoLbl), 1, 20),
            -LibraryRandom.RandIntInRange(1, 10000));
        GenJournalLine.Validate("Location Code", LocationCode);
        GenJournalLine.Validate("GST Group Code", CopyStr(Storage.Get(GSTGroupCodeLbl), 1, 20));
        GenJournalLine.Validate("HSN/SAC Code", CopyStr(Storage.Get(HSNSACCodeLbl), 1, 10));
        CalculateGST(GenJournalLine);
        GenJournalLine.Modify(true);
    end;

    local procedure CalculateGST(GenJournalLine: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnGenJnlLine(GenJournalLine, GenJournalLine)
    end;

    procedure ProvidePOSOutofIndiaValue(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."POS Out Of India" := true;
        GenJournalLine."Location State Code" := GenJournalLine."GST Ship-to State Code";
        GenJournalLine."GST Place of Supply" := GenJournalLine."GST Place of Supply"::" ";
        GenJournalLine.Modify(true);
    end;

    procedure CreateGenJnlLineFromPartyTypeCustomerInvoice(
        var GenJournalLine: Record "Gen. Journal Line";
        TemplateType: Enum "Gen. Journal Template Type";
        PartyCode: Code[20])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VATPostingSetup: Record "VAT Posting Setup";
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, TemplateType);
        CustomerNo := CopyStr(Storage.Get(CustomerNoLbl), 1, 20);
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));
        LibraryJournals.CreateGenJournalLine(
            GenJournalLine,
            GenJournalTemplate.Name,
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryGST.CreateGLAccWithGSTDetails(
                VATPostingSetup,
                CopyStr(Storage.Get(GSTGroupCodeLbl), 1, 20),
                CopyStr(Storage.Get(HSNSACCodeLbl), 1, 10),
                true,
                StorageBoolean.Get(ExemptedLbl)
            ),
            LibraryRandom.RandIntInRange(1, 100000));
        GenJournalLine."Bal. Account No." := CustomerNo;
        GenJournalLine.Validate("Party Type", GenJournalLine."Party Type"::Party);
        GenJournalLine.Validate("Party Code", PartyCode);
        GenJournalLine.Validate("Location Code", LocationCode);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::Sale);
        GenJournalLine.Modify(true);
    end;

    procedure AssignFAInfotoGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; var XGenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."GST Place of Supply" := GenJournalLine."GST Place of Supply"::"Ship-to Address";
        GenJournalLine."FA Reclassification Entry" := true;
        GenJournalLine."FA Posting Type" := GenJournalLine."FA Posting Type"::"Acquisition Cost";
        XGenJournalLine."GST Place of Supply" := XGenJournalLine."GST Place of Supply"::"Bill-to Address";
        GenJournalLine.Modify(true)
    end;

    procedure AssignAppliesToDocNo(var GenJournalLine: Record "Gen. Journal Line")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        GenJournalLine."Applies-to Doc. No." := CopyStr(
                                                    LibraryUtility.GenerateRandomCode(
                                                        GenJournalLine.FieldNo("Applies-to Doc. No."),
                                                        Database::"Gen. Journal Line"
                                                    ),
                                                    1,
                                                    20);
        GenJournalLine."GST Place of Supply" := GenJournalLine."GST Place of Supply"::"Ship-to Address";
        GenJournalLine.Modify(true)
    end;

    procedure SetStorageGSTJournalText(FromStorage: Dictionary of [Text[20], Text[20]])
    begin
        Storage := FromStorage;
    end;

    procedure SetStorageGSTJournalBoolean(FromStorage: Dictionary of [Text[20], Boolean])
    begin
        StorageBoolean := FromStorage;
    end;
}