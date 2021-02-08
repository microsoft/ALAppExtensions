#pragma warning disable AL0432
codeunit 11779 "VAT Curr. Factor Handler CZL"
{
    var
        VATPostingSetup: Record "VAT Posting Setup";
        SourceCodeSetup: Record "Source Code Setup";
        GLEntry: Record "G/L Entry";
        Currency: Record Currency;
        VATCurrFactor: Decimal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostInvPostBuffer', '', false, false)]
    local procedure SalesPostVATCurrencyFactorOnAfterPostInvPostBuffer(var GenJnlLine: Record "Gen. Journal Line"; var InvoicePostBuffer: Record "Invoice Post. Buffer"; var SalesHeader: Record "Sales Header"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        if SalesHeader."Currency Factor" <> SalesHeader."VAT Currency Factor CZL" then begin
            VATPostingSetup.Get(GenJnlLine."VAT Bus. Posting Group", GenJnlLine."VAT Prod. Posting Group");
            VATPostingSetup.TestField("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT");
            VATPostingSetup.TestField("Sales VAT Curr. Exch. Acc CZL");
            SourceCodeSetup.Get();
            SourceCodeSetup.TestField("Sales VAT Delay CZL");
            GLEntry.Get(GLEntryNo);
            PostSalesVATCurrencyFactor(SalesHeader, InvoicePostBuffer, false, 1, true, VATPostingSetup, GenJnlPostLine);
            if SalesHeader."VAT Currency Factor CZL" = 0 then
                VATCurrFactor := 1
            else
                VATCurrFactor := SalesHeader."Currency Factor" / SalesHeader."VAT Currency Factor CZL";
            if VATCurrFactor = 0 then
                VATCurrFactor := 1;

            PostSalesVATCurrencyFactor(SalesHeader, InvoicePostBuffer, true, VATCurrFactor, false, VATPostingSetup, GenJnlPostLine);

            EliminateDoublePosting(GenJnlLine); // Elimination of double Accounting
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Posting Journals Mgt.", 'OnAfterPostInvoicePostBuffer', '', false, false)]
    local procedure ServPostingVATCurrencyFactorOnAfterPostInvPostBuffer(var GenJournalLine: Record "Gen. Journal Line"; var InvoicePostBuffer: Record "Invoice Post. Buffer"; ServiceHeader: Record "Service Header"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        if ServiceHeader."Currency Factor" <> ServiceHeader."VAT Currency Factor CZL" then begin
            VATPostingSetup.Get(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group");
            VATPostingSetup.TestField("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT");
            VATPostingSetup.TestField("Sales VAT Curr. Exch. Acc CZL");
            SourceCodeSetup.Get();
            SourceCodeSetup.TestField("Sales VAT Delay CZL");
            GLEntry.Get(GLEntryNo);
            PostServiceVATCurrencyFactor(ServiceHeader, InvoicePostBuffer, false, 1, true, VATPostingSetup, GenJnlPostLine);
            if ServiceHeader."VAT Currency Factor CZL" = 0 then
                VATCurrFactor := 1
            else
                VATCurrFactor := ServiceHeader."Currency Factor" / ServiceHeader."VAT Currency Factor CZL";
            if VATCurrFactor = 0 then
                VATCurrFactor := 1;

            PostServiceVATCurrencyFactor(ServiceHeader, InvoicePostBuffer, true, VATCurrFactor, false, VATPostingSetup, GenJnlPostLine);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostInvPostBuffer', '', false, false)]
    [Obsolete('This procedure will be removed after removing feature from Base Application.', '17.0')]
    local procedure OnBeforePostInvPostBuffer(var InvoicePostBuffer: Record "Invoice Post. Buffer"; var PurchHeader: Record "Purchase Header")
    begin
        // Elimination of double Accounting
        if (PurchHeader."Currency Code" <> '') and (PurchHeader."Currency Factor" <> PurchHeader."VAT Currency Factor CZL") and
                     ((InvoicePostBuffer."VAT Calculation Type" = InvoicePostBuffer."VAT Calculation Type"::"Reverse Charge VAT") or
                      (InvoicePostBuffer."VAT Calculation Type" = InvoicePostBuffer."VAT Calculation Type"::"Normal VAT"))
                  then
            PurchHeader."Your Reference" := 'VAT Currency Diff. Posted';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostInvPostBuffer', '', false, false)]
    local procedure PurchasePostVATCurrencyFactorOnAfterPostInvPostBuffer(var GenJnlLine: Record "Gen. Journal Line"; var InvoicePostBuffer: Record "Invoice Post. Buffer"; PurchHeader: Record "Purchase Header"; GLEntryNo: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        if (PurchHeader."Currency Code" <> '') and (PurchHeader."Currency Factor" <> PurchHeader."VAT Currency Factor CZL") and
                    ((InvoicePostBuffer."VAT Calculation Type" = InvoicePostBuffer."VAT Calculation Type"::"Reverse Charge VAT") or
                     (InvoicePostBuffer."VAT Calculation Type" = InvoicePostBuffer."VAT Calculation Type"::"Normal VAT"))
                 then begin
            VATPostingSetup.Get(InvoicePostBuffer."VAT Bus. Posting Group", InvoicePostBuffer."VAT Prod. Posting Group");
            VATPostingSetup.TestField("Purch. VAT Curr. Exch. Acc CZL");
            SourceCodeSetup.Get();
            SourceCodeSetup.TestField("Purchase VAT Delay CZL");
            GLEntry.Get(GLEntryNo);
            PostPurchaseVATCurrencyFactor(
              PurchHeader, InvoicePostBuffer, false, PurchHeader."Posting Date", true, VATPostingSetup, PurchHeader."VAT Date CZL", GenJnlPostLine);
            PostPurchaseVATCurrencyFactor(
              PurchHeader, InvoicePostBuffer, true, PurchHeader."Posting Date", false, VATPostingSetup, PurchHeader."VAT Date CZL", GenJnlPostLine);
            // VAT Correction posting
            case InvoicePostBuffer."VAT Calculation Type" of
                InvoicePostBuffer."VAT Calculation Type"::"Normal VAT":
                    begin
                        PostPurchVATCurrencyFactorDifference(
                          PurchHeader, InvoicePostBuffer, PurchHeader."Posting Date", VATPostingSetup, PurchHeader."VAT Date CZL", 0, GenJnlPostLine);
                        PostPurchVATCurrencyFactorDifference(
                          PurchHeader, InvoicePostBuffer, PurchHeader."Posting Date", VATPostingSetup, PurchHeader."VAT Date CZL", 1, GenJnlPostLine);
                    end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy - VAT Posting Setup", 'OnAfterCopyVATPostingSetup', '', false, false)]

    local procedure CopyCZLfieldsOnAfterCopyVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; FromVATPostingSetup: Record "VAT Posting Setup"; Sales: Boolean; Purch: Boolean)
    begin
        if Sales then
            VATPostingSetup."Sales VAT Curr. Exch. Acc CZL" := FromVATPostingSetup."Sales VAT Curr. Exch. Acc CZL";
        if Purch then
            VATPostingSetup."Purch. VAT Curr. Exch. Acc CZL" := FromVATPostingSetup."Purch. VAT Curr. Exch. Acc CZL";
        VATPostingSetup."VIES Purchase CZL" := FromVATPostingSetup."VIES Purchase CZL";
        VATPostingSetup."VIES Sales CZL" := FromVATPostingSetup."VIES Sales CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ServContractManagement, 'OnBeforeServHeaderModify', '', false, false)]
    local procedure CurrencyFactorToVATCurrencyFactorOnBeforeServHeaderModify(var ServiceHeader: Record "Service Header")
    begin
        ServiceHeader."VAT Currency Factor CZL" := ServiceHeader."Currency Factor";
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnAfterCopyFromGenJnlLine', '', false, false)]
    local procedure VATDelayOnAfterCopyFromGenJnlLine(var VATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VATEntry.Validate("VAT Delay CZL", GenJournalLine."VAT Delay CZL");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnCalcPmtDiscIfAdjVATOnBeforeVATEntryFind', '', false, false)]
    local procedure VATDelayOnCalcPmtDiscIfAdjVATOnBeforeVATEntryFind(var VATEntry: Record "VAT Entry")
    begin
        VATEntry.SetRange("VAT Delay CZL", false);
    end;

    local procedure PostSalesVATCurrencyFactor(SalesHeader: Record "Sales Header"; InvoicePostBuffer: Record "Invoice Post. Buffer"; ToPost: Boolean; CurrFactor: Decimal; IsCorrection: Boolean; VATPostSet: Record "VAT Posting Setup"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
        Sign: Integer;
    begin
        if ToPost then
            Sign := 1
        else
            Sign := -1;

        GenJournalLine.Init();
        GenJournalLine."Posting Date" := SalesHeader."Posting Date";
        GenJournalLine.Validate("VAT Date CZL", SalesHeader."VAT Date CZL");
        GenJournalLine.Validate("Original Doc. VAT Date CZL", SalesHeader."Original Doc. VAT Date CZL");
        GenJournalLine."Document Date" := SalesHeader."Document Date";
        GenJournalLine.Description := SalesHeader."Posting Description";
        GenJournalLine."Reason Code" := SalesHeader."Reason Code";
        GenJournalLine."Document Type" := GLEntry."Document Type";
        GenJournalLine."Document No." := GLEntry."Document No.";
        GenJournalLine."External Document No." := GLEntry."External Document No.";
        GenJournalLine."Account No." := VATPostSet."Sales VAT Curr. Exch. Acc CZL";
        GenJournalLine."System-Created Entry" := InvoicePostBuffer."System-Created Entry";
        GenJournalLine."Source Currency Code" := SalesHeader."Currency Code";
        GetCurrency(SalesHeader."Currency Code");
        if IsCorrection then
            GenJournalLine.Correction := not InvoicePostBuffer.Correction
        else
            GenJournalLine.Correction := InvoicePostBuffer.Correction;
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
        GenJournalLine."VAT Bus. Posting Group" := InvoicePostBuffer."VAT Bus. Posting Group";
        GenJournalLine."VAT Prod. Posting Group" := InvoicePostBuffer."VAT Prod. Posting Group";
        GenJournalLine."Tax Area Code" := InvoicePostBuffer."Tax Area Code";
        GenJournalLine."Tax Liable" := InvoicePostBuffer."Tax Liable";
        GenJournalLine."Tax Group Code" := InvoicePostBuffer."Tax Group Code";
        GenJournalLine."Use Tax" := InvoicePostBuffer."Use Tax";
        GenJournalLine."VAT Calculation Type" := InvoicePostBuffer."VAT Calculation Type";
        GenJournalLine."VAT Base Discount %" := SalesHeader."VAT Base Discount %";
        GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
        GenJournalLine."Shortcut Dimension 1 Code" := InvoicePostBuffer."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := InvoicePostBuffer."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := InvoicePostBuffer."Dimension Set ID";
        GenJournalLine."Job No." := InvoicePostBuffer."Job No.";
        GenJournalLine."Source Code" := SourceCodeSetup."Sales VAT Delay CZL";
        GenJournalLine."Bill-to/Pay-to No." := SalesHeader."Bill-to Customer No.";
        GenJournalLine."Source Type" := GenJournalLine."Source Type"::Customer;
        GenJournalLine."Source No." := SalesHeader."Bill-to Customer No.";
        GenJournalLine."Posting No. Series" := SalesHeader."Posting No. Series";
        GenJournalLine."Bal. Account No." := VATPostSet."Sales VAT Curr. Exch. Acc CZL";
        GenJournalLine.Quantity := Sign * InvoicePostBuffer.Quantity;
        GenJournalLine.Amount := Round(Sign * InvoicePostBuffer.Amount * CurrFactor, Currency."Amount Rounding Precision");
        GenJournalLine."VAT Amount" := Round(Sign * InvoicePostBuffer."VAT Amount" *
            CurrFactor, Currency."Amount Rounding Precision");
        GenJournalLine."VAT Base Amount" := GenJournalLine.Amount;
        GenJournalLine."Source Currency Amount" := Round(Sign * InvoicePostBuffer."Amount (ACY)" * CurrFactor,
            Currency."Amount Rounding Precision");
        GenJournalLine."Source Curr. VAT Amount" := Round(Sign * InvoicePostBuffer."VAT Amount (ACY)" * CurrFactor,
            Currency."Amount Rounding Precision");
        GenJournalLine."Source Curr. VAT Base Amount" := GenJournalLine."Source Currency Amount" - GenJournalLine."Source Curr. VAT Amount";
        GenJournalLine."VAT Difference" := Round(Sign * InvoicePostBuffer."VAT Difference" * CurrFactor,
            Currency."Amount Rounding Precision");
        GenJournalLine."Gen. Bus. Posting Group" := InvoicePostBuffer."Gen. Bus. Posting Group";
        GenJournalLine."Gen. Prod. Posting Group" := InvoicePostBuffer."Gen. Prod. Posting Group";
        GenJournalLine.Validate("VAT Delay CZL", true);

        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure PostServiceVATCurrencyFactor(ServiceHeader: Record "Service Header"; InvoicePostBuffer: Record "Invoice Post. Buffer"; ToPost: Boolean; CurrFactor: Decimal; IsCorrection: Boolean; VATPostSet: Record "VAT Posting Setup"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
        Sign: Integer;
    begin
        if ToPost then
            Sign := 1
        else
            Sign := -1;

        GenJournalLine.Init();
        GenJournalLine."Posting Date" := ServiceHeader."Posting Date";
        GenJournalLine.Validate("VAT Date CZL", ServiceHeader."VAT Date CZL");
        GenJournalLine."Document Date" := ServiceHeader."Document Date";
        GenJournalLine.Description := ServiceHeader."Posting Description";
        GenJournalLine."Reason Code" := ServiceHeader."Reason Code";
        GenJournalLine."Document Type" := GLEntry."Document Type";
        GenJournalLine."Document No." := GLEntry."Document No.";
        GenJournalLine."External Document No." := GLEntry."External Document No.";
        GenJournalLine."Account No." := VATPostSet."Sales VAT Curr. Exch. Acc CZL";
        GenJournalLine."System-Created Entry" := InvoicePostBuffer."System-Created Entry";
        GenJournalLine."Source Currency Code" := ServiceHeader."Currency Code";
        GetCurrency(ServiceHeader."Currency Code");
        if IsCorrection then
            GenJournalLine.Correction := not InvoicePostBuffer.Correction
        else
            GenJournalLine.Correction := InvoicePostBuffer.Correction;
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
        GenJournalLine."VAT Bus. Posting Group" := InvoicePostBuffer."VAT Bus. Posting Group";
        GenJournalLine."VAT Prod. Posting Group" := InvoicePostBuffer."VAT Prod. Posting Group";
        GenJournalLine."Tax Area Code" := InvoicePostBuffer."Tax Area Code";
        GenJournalLine."Tax Liable" := InvoicePostBuffer."Tax Liable";
        GenJournalLine."Tax Group Code" := InvoicePostBuffer."Tax Group Code";
        GenJournalLine."Use Tax" := InvoicePostBuffer."Use Tax";
        GenJournalLine."VAT Calculation Type" := InvoicePostBuffer."VAT Calculation Type";
        GenJournalLine."VAT Base Discount %" := ServiceHeader."VAT Base Discount %";
        GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
        GenJournalLine."Shortcut Dimension 1 Code" := InvoicePostBuffer."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := InvoicePostBuffer."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := InvoicePostBuffer."Dimension Set ID";
        GenJournalLine."Job No." := InvoicePostBuffer."Job No.";
        GenJournalLine."Source Code" := SourceCodeSetup."Sales VAT Delay CZL";
        GenJournalLine."Bill-to/Pay-to No." := ServiceHeader."Bill-to Customer No.";
        GenJournalLine."Source Type" := GenJournalLine."Source Type"::Customer;
        GenJournalLine."Source No." := ServiceHeader."Bill-to Customer No.";
        GenJournalLine."Posting No. Series" := ServiceHeader."Posting No. Series";
        GenJournalLine."Bal. Account No." := VATPostSet."Sales VAT Curr. Exch. Acc CZL";
        GenJournalLine.Quantity := Sign * InvoicePostBuffer.Quantity;
        GenJournalLine.Amount := Round(Sign * InvoicePostBuffer.Amount * CurrFactor, Currency."Amount Rounding Precision");
        GenJournalLine."VAT Amount" := Round(Sign * InvoicePostBuffer."VAT Amount" *
            CurrFactor, Currency."Amount Rounding Precision");
        GenJournalLine."VAT Base Amount" := GenJournalLine.Amount;
        GenJournalLine."Source Currency Amount" := Round(Sign * InvoicePostBuffer."Amount (ACY)" * CurrFactor,
            Currency."Amount Rounding Precision");
        GenJournalLine."Source Curr. VAT Amount" := Round(Sign * InvoicePostBuffer."VAT Amount (ACY)" * CurrFactor,
            Currency."Amount Rounding Precision");
        GenJournalLine."Source Curr. VAT Base Amount" := GenJournalLine."Source Currency Amount" - GenJournalLine."Source Curr. VAT Amount";
        GenJournalLine."VAT Difference" := Round(Sign * InvoicePostBuffer."VAT Difference" * CurrFactor,
            Currency."Amount Rounding Precision");
        GenJournalLine."Gen. Bus. Posting Group" := InvoicePostBuffer."Gen. Bus. Posting Group";
        GenJournalLine."Gen. Prod. Posting Group" := InvoicePostBuffer."Gen. Prod. Posting Group";
        GenJournalLine.Validate("VAT Delay CZL", true);

        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure PostPurchaseVATCurrencyFactor(PurchHeader: Record "Purchase Header"; InvoicePostBuffer: Record "Invoice Post. Buffer"; Post: Boolean; PostingDate: Date; IsCorrection: Boolean; VATPostingSetup: Record "VAT Posting Setup"; VATDate: Date; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.Init();
        GenJournalLine."Posting Date" := PostingDate;
        GenJournalLine."Document Date" := PurchHeader."Document Date";
        GenJournalLine.Validate("VAT Date CZL", VATDate);
        GenJournalLine.Validate("Original Doc. VAT Date CZL", PurchHeader."Original Doc. VAT Date CZL");
        GenJournalLine.Description := PurchHeader."Posting Description";
        GenJournalLine."Reason Code" := PurchHeader."Reason Code";
        GenJournalLine."Document Type" := GLEntry."Document Type";
        GenJournalLine."Document No." := GLEntry."Document No.";
        GenJournalLine."External Document No." := GLEntry."External Document No.";
        GenJournalLine."Account No." := VATPostingSetup."Purch. VAT Curr. Exch. Acc CZL";
        GenJournalLine."System-Created Entry" := InvoicePostBuffer."System-Created Entry";
        GenJournalLine."Source Currency Code" := PurchHeader."Currency Code";
        if IsCorrection then
            GenJournalLine.Correction := not InvoicePostBuffer.Correction
        else
            GenJournalLine.Correction := InvoicePostBuffer.Correction;
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
        GenJournalLine."Gen. Bus. Posting Group" := InvoicePostBuffer."Gen. Bus. Posting Group";
        GenJournalLine."Gen. Prod. Posting Group" := InvoicePostBuffer."Gen. Prod. Posting Group";
        GenJournalLine."EU 3-Party Trade" := PurchHeader."EU 3-Party Trade CZL";
        GenJournalLine.Validate("EU 3-Party Intermed. Role CZL", PurchHeader."EU 3-Party Intermed. Role CZL");
        GenJournalLine."VAT Bus. Posting Group" := InvoicePostBuffer."VAT Bus. Posting Group";
        GenJournalLine."VAT Prod. Posting Group" := InvoicePostBuffer."VAT Prod. Posting Group";
        GenJournalLine."Tax Area Code" := InvoicePostBuffer."Tax Area Code";
        GenJournalLine."Tax Liable" := InvoicePostBuffer."Tax Liable";
        GenJournalLine."Tax Group Code" := InvoicePostBuffer."Tax Group Code";
        GenJournalLine."Use Tax" := InvoicePostBuffer."Use Tax";
        GenJournalLine."VAT Calculation Type" := InvoicePostBuffer."VAT Calculation Type";
        GenJournalLine."VAT Base Discount %" := PurchHeader."VAT Base Discount %";
        GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
        GenJournalLine."Shortcut Dimension 1 Code" := InvoicePostBuffer."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := InvoicePostBuffer."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := InvoicePostBuffer."Dimension Set ID";
        GenJournalLine."Job No." := InvoicePostBuffer."Job No.";
        GenJournalLine."Source Code" := SourceCodeSetup."Purchase VAT Delay CZL";
        GenJournalLine."Bill-to/Pay-to No." := PurchHeader."Pay-to Vendor No.";
        GenJournalLine."Source Type" := GenJournalLine."Source Type"::Vendor;
        GenJournalLine."Source No." := PurchHeader."Pay-to Vendor No.";
        GenJournalLine."Posting No. Series" := PurchHeader."Posting No. Series";
        GenJournalLine."Country/Region Code" := PurchHeader."VAT Country/Region Code";
        GenJournalLine."VAT Registration No." := PurchHeader."VAT Registration No.";
        GenJournalLine.Validate("Registration No. CZL", PurchHeader."Registration No. CZL");
        if InvoicePostBuffer."VAT Calculation Type" = InvoicePostBuffer."VAT Calculation Type"::"Reverse Charge VAT" then
            GenJournalLine."Bal. Account No." := VATPostingSetup."Purch. VAT Curr. Exch. Acc CZL";
        InitVATDelayAmounts(PurchHeader, InvoicePostBuffer, Post, GenJournalLine);
        GenJournalLine.Validate("VAT Delay CZL", true);

        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure InitVATDelayAmounts(PurchHeader: Record "Purchase Header"; InvoicePostBuffer: Record "Invoice Post. Buffer"; Post: Boolean; var GenJournalLine: Record "Gen. Journal Line")
    var
        CurrFactor: Decimal;
    begin
        if Post then begin
            if InvoicePostBuffer."VAT Calculation Type" = InvoicePostBuffer."VAT Calculation Type"::"Normal VAT" then begin
                // Normal VAT
                GenJournalLine.Quantity := InvoicePostBuffer.Quantity;
                if PurchHeader."Prices Including VAT" then begin
                    GenJournalLine.Amount := Round(InvoicePostBuffer."Ext. Amount" - InvoicePostBuffer."Ext. VAT Difference (LCY)",
                        Currency."Amount Rounding Precision");
                    GenJournalLine."VAT Amount" := Round(InvoicePostBuffer."Ext. Amount Including VAT" - InvoicePostBuffer."Ext. Amount" +
                        InvoicePostBuffer."Ext. VAT Difference (LCY)", Currency."Amount Rounding Precision");
                    GenJournalLine."VAT Base Amount" := GenJournalLine.Amount;
                    GenJournalLine."Source Currency Amount" := Round(InvoicePostBuffer."Amount (ACY)", Currency."Amount Rounding Precision");
                    GenJournalLine."Source Curr. VAT Amount" :=
                      Round(InvoicePostBuffer."VAT Amount (ACY)", Currency."Amount Rounding Precision");
                    GenJournalLine."Source Curr. VAT Base Amount" :=
                      Round(InvoicePostBuffer."VAT Base Amount (ACY)", Currency."Amount Rounding Precision");
                    GenJournalLine."VAT Difference" :=
                      Round(InvoicePostBuffer."Ext. VAT Difference (LCY)", Currency."Amount Rounding Precision");
                    GenJournalLine."VAT Difference (LCY)" := GenJournalLine."VAT Difference";
                end else begin
                    GenJournalLine.Amount := Round(InvoicePostBuffer."Ext. Amount", Currency."Amount Rounding Precision");
                    GenJournalLine."VAT Amount" := Round(InvoicePostBuffer."Ext. Amount Including VAT" - InvoicePostBuffer."Ext. Amount" +
                        InvoicePostBuffer."Ext. VAT Difference (LCY)", Currency."Amount Rounding Precision");
                    GenJournalLine."VAT Base Amount" := GenJournalLine.Amount;
                    GenJournalLine."Source Currency Amount" := Round(InvoicePostBuffer."Amount (ACY)", Currency."Amount Rounding Precision");
                    GenJournalLine."Source Curr. VAT Amount" :=
                      Round(InvoicePostBuffer."VAT Amount (ACY)", Currency."Amount Rounding Precision");
                    GenJournalLine."Source Curr. VAT Base Amount" :=
                      Round(InvoicePostBuffer."VAT Base Amount (ACY)", Currency."Amount Rounding Precision");
                    GenJournalLine."VAT Difference" :=
                      Round(InvoicePostBuffer."Ext. VAT Difference (LCY)", Currency."Amount Rounding Precision");
                    GenJournalLine."VAT Difference (LCY)" := GenJournalLine."VAT Difference";
                end;
            end else begin
                // Reverse Charge VAT
                if PurchHeader."VAT Currency Factor CZL" = 0 then
                    CurrFactor := 1
                else
                    CurrFactor := PurchHeader."Currency Factor" / PurchHeader."VAT Currency Factor CZL";
                if CurrFactor = 0 then
                    CurrFactor := 1;

                GenJournalLine.Amount := Round(InvoicePostBuffer.Amount * CurrFactor, Currency."Amount Rounding Precision");
                GenJournalLine."VAT Amount" := Round(InvoicePostBuffer."VAT Amount" *
                    CurrFactor, Currency."Amount Rounding Precision");
                GenJournalLine."VAT Base Amount" := GenJournalLine.Amount;
                GenJournalLine."Source Currency Amount" := Round(InvoicePostBuffer."Amount (ACY)" * CurrFactor,
                    Currency."Amount Rounding Precision");
                GenJournalLine."Source Curr. VAT Amount" := Round(InvoicePostBuffer."VAT Amount (ACY)" * CurrFactor,
                    Currency."Amount Rounding Precision");
                GenJournalLine."Source Curr. VAT Base Amount" := GenJournalLine."Source Currency Amount" - GenJournalLine."Source Curr. VAT Amount";
                GenJournalLine."VAT Difference" := Round(InvoicePostBuffer."VAT Difference" * CurrFactor,
                    Currency."Amount Rounding Precision");
            end;
        end else begin
            GenJournalLine.Quantity := -InvoicePostBuffer.Quantity;
            GenJournalLine.Amount := -Round(InvoicePostBuffer.Amount, Currency."Amount Rounding Precision");
            GenJournalLine."VAT Amount" := -Round(InvoicePostBuffer."VAT Amount", Currency."Amount Rounding Precision");
            GenJournalLine."VAT Base Amount" := GenJournalLine.Amount;
            GenJournalLine."Source Currency Amount" := -Round(InvoicePostBuffer."Amount (ACY)", Currency."Amount Rounding Precision");
            GenJournalLine."Source Curr. VAT Amount" := -Round(InvoicePostBuffer."VAT Amount (ACY)", Currency."Amount Rounding Precision");
            GenJournalLine."Source Curr. VAT Base Amount" := GenJournalLine."Source Currency Amount";
            GenJournalLine."VAT Difference" := -Round(InvoicePostBuffer."VAT Difference", Currency."Amount Rounding Precision");
        end;
    end;

    local procedure PostPurchVATCurrencyFactorDifference(PurchHeader: Record "Purchase Header"; InvoicePostBuffer: Record "Invoice Post. Buffer"; PostingDate: Date; VATPostingSetup: Record "VAT Posting Setup"; VATDate: Date; AmtType: Option Base,VAT; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        CalcAmt: Decimal;
        AccountNo: Code[20];
        AmtTmp: Decimal;
    begin
        GetCurrency(PurchHeader."Currency Code");
        case AmtType of
            AmtType::Base:
                begin
                    AccountNo := VATPostingSetup."Purch. VAT Curr. Exch. Acc CZL";
                    if PurchHeader."Prices Including VAT" then
                        CalcAmt := InvoicePostBuffer.Amount -
                          Round(InvoicePostBuffer."Ext. Amount" - InvoicePostBuffer."Ext. VAT Difference (LCY)",
                            Currency."Amount Rounding Precision")
                    else
                        CalcAmt := (InvoicePostBuffer.Amount -
                           (Round(InvoicePostBuffer."Ext. Amount", Currency."Amount Rounding Precision")));
                end;
            AmtType::VAT:
                begin
                    CalcAmt := InvoicePostBuffer."VAT Amount" -
                       Round(InvoicePostBuffer."Ext. Amount Including VAT" - InvoicePostBuffer."Ext. Amount" +
                         InvoicePostBuffer."Ext. VAT Difference (LCY)", Currency."Amount Rounding Precision");

                    if CalcAmt < 0 then
                        AccountNo := Currency."Realized Gains Acc."
                    else
                        AccountNo := Currency."Realized Losses Acc.";
                end;
        end;
        PostPurchVATCurrencyDiffJournal(PurchHeader, InvoicePostBuffer, PostingDate, VATDate, CalcAmt, AccountNo, GenJnlPostLine);
    end;

    local procedure PostPurchVATCurrencyDiffJournal(PurchHeader: Record "Purchase Header"; InvoicePostBuffer: Record "Invoice Post. Buffer"; PostingDate: Date; VATDate: Date; CalcAmt: Decimal; AccountNo: Code[20]; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.Init();
        GenJournalLine."Posting Date" := PostingDate;
        GenJournalLine."Document Date" := PurchHeader."Document Date";
        GenJournalLine.Validate("VAT Date CZL", VATDate);
        GenJournalLine.Validate("Original Doc. VAT Date CZL", PurchHeader."Original Doc. VAT Date CZL");
        GenJournalLine.Description := PurchHeader."Posting Description";
        GenJournalLine."Reason Code" := PurchHeader."Reason Code";
        GenJournalLine."Document Type" := GLEntry."Document Type";
        GenJournalLine."Document No." := GLEntry."Document No.";
        GenJournalLine."External Document No." := GLEntry."External Document No.";
        GenJournalLine."Account No." := AccountNo;
        GenJournalLine."System-Created Entry" := InvoicePostBuffer."System-Created Entry";
        GenJournalLine."Source Currency Code" := PurchHeader."Currency Code";
        GenJournalLine.Correction := InvoicePostBuffer.Correction;
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::" ";
        GenJournalLine."Tax Area Code" := InvoicePostBuffer."Tax Area Code";
        GenJournalLine."Tax Liable" := InvoicePostBuffer."Tax Liable";
        GenJournalLine."Tax Group Code" := InvoicePostBuffer."Tax Group Code";
        GenJournalLine."Use Tax" := InvoicePostBuffer."Use Tax";
        GenJournalLine."VAT Calculation Type" := InvoicePostBuffer."VAT Calculation Type";
        GenJournalLine."VAT Base Discount %" := PurchHeader."VAT Base Discount %";
        GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
        GenJournalLine."Shortcut Dimension 1 Code" := InvoicePostBuffer."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := InvoicePostBuffer."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := InvoicePostBuffer."Dimension Set ID";
        GenJournalLine."Job No." := InvoicePostBuffer."Job No.";
        GenJournalLine."Source Code" := SourceCodeSetup."Purchase VAT Delay CZL";
        GenJournalLine."Bill-to/Pay-to No." := PurchHeader."Pay-to Vendor No.";
        GenJournalLine."Source Type" := GenJournalLine."Source Type"::Vendor;
        GenJournalLine."Source No." := PurchHeader."Pay-to Vendor No.";
        GenJournalLine."Posting No. Series" := PurchHeader."Posting No. Series";
        GenJournalLine."Country/Region Code" := PurchHeader."VAT Country/Region Code";
        GenJournalLine."VAT Registration No." := PurchHeader."VAT Registration No.";
        GenJournalLine.Validate("Registration No. CZL", PurchHeader."Registration No. CZL");
        GenJournalLine.Quantity := InvoicePostBuffer.Quantity;
        GenJournalLine.Amount := CalcAmt;
        GenJournalLine.Validate("VAT Delay CZL", true);

        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure GetCurrency(CurrencyCode: Code[10])
    begin
        if CurrencyCode = '' then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get(CurrencyCode);
            Currency.TestField("Amount Rounding Precision");
        end;
    end;

    [Obsolete('This procedure will be removed after removing feature from Base Application.', '17.0')]
    local procedure EliminateDoublePosting(var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine.Amount := 0;
    end;

}