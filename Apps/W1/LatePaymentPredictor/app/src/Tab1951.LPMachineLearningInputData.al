table 1951 "LP ML Input Data"
{
    ReplicateData = false;

    fields
    {
        field(1; Number; Code[20])
        {
        }


        field(2; "Payment Terms Days"; Integer)
        {
        }

        field(3; Corrected; Boolean)
        {
        }

        field(4; "No. Paid Invoices"; Integer)
        {
        }

        field(5; "No. Paid Late Invoices"; Integer)
        {
        }

        field(6; "Ratio Paid Late/Paid Invoices"; Decimal)
        {
        }

        field(7; "Total Paid Invoices Amount"; Decimal)
        {
        }

        field(8; "Total Paid Late Inv. Amount"; Decimal)
        {
        }

        field(9; "Ratio PaidLateAmnt/PaidAmnt"; Decimal)
        {
        }

        field(10; "Average Days Late"; Decimal)
        {
        }

        field(11; "No. Outstanding Inv."; Integer)
        {
        }

        field(12; "No. Outstanding Late Inv."; Integer)
        {
        }

        field(13; "Ratio NoOutstngLate/NoOutstng"; Decimal)
        {
        }
        field(14; "Total Outstng Invoices Amt."; Decimal)
        {
        }

        field(15; "Total Outstng Late Inv. Amt."; Decimal)
        {
        }

        field(16; "Ratio AmtLate/Amt Outstng Inv"; Decimal)
        {
        }

        field(17; "Average Outstanding Days Late"; Decimal)
        {
        }

        field(18; "Bill-to Customer No."; Code[20])
        {
        }

        field(19; "Base Amount"; Decimal)
        {
        }

        field(20; "Posting Date"; Date)
        {
        }

        field(21; "Due Date"; Date)
        {
        }

        field(22; "Closed Date"; Date)
        {
        }

        field(23; Closed; Boolean)
        {
        }

        field(24; "Paid Late Days"; Integer)
        {
        }

        field(25; "UsedForPredict And ToBeDeleted"; Boolean)
        {
        }

        field(100; "Is Late"; Boolean)
        {
        }

        field(101; "Confidence"; Decimal)
        {
        }
    }

    keys
    {
        key(PK; Number)
        {
            Clustered = true;
        }
        key(CalculateKey; "Bill-to Customer No.", Closed, "Closed Date", "Due Date", "Posting Date", "Is Late", "Base Amount", "Paid Late Days") { }
        key(PostingDateKey; "Posting Date") { }
    }

    procedure InsertFromSalesHeader(SalesHeader: Record "Sales Header")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        Init();

        if NOT GET(SalesHeader."No.") Then begin

            SalesHeader.CalcFields(Amount);

            Number := SalesHeader."No.";

            "Due Date" := SalesHeader."Due Date";
            "Bill-to Customer No." := SalesHeader."Bill-to Customer No.";
            if (SalesHeader."Posting Date" = 0D) then
                "Posting Date" := SalesHeader."Document Date"
            else
                "Posting Date" := SalesHeader."Posting Date";
            "Base Amount" := SalesHeader.Amount; // flowfield
            "Payment Terms Days" := "Due Date" - "Posting Date";

            SalesCrMemoHeader.SetRange("Applies-to Doc. Type", SalesCrMemoHeader."Applies-to Doc. Type"::Invoice);
            SalesCrMemoHeader.SetRange("Applies-to Doc. No.", Number);
            Corrected := not SalesCrMemoHeader.IsEmpty();

            // not closed because not posted yet

            "Is Late" := WorkDate() > SalesHeader."Due Date";

            CalculateFeatures(SalesHeader."Posting Date", SalesHeader."Bill-to Customer No.");
            "UsedForPredict And ToBeDeleted" := true;
            Insert();
        end else begin
            "UsedForPredict And ToBeDeleted" := true;
            Modify();
        end;
    end;

    procedure InsertFromSalesInvoice(LppSalesInvoiceHeaderInput: Query "LPP Sales Invoice Header Input");
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaidLate: Boolean;
    begin
        Init();

        Number := LppSalesInvoiceHeaderInput.No;
        "Due Date" := LppSalesInvoiceHeaderInput.DueDate;
        "Bill-to Customer No." := LppSalesInvoiceHeaderInput.BillToCustomerNo;
        "Posting Date" := LppSalesInvoiceHeaderInput.PostingDate;
        "Base Amount" := LppSalesInvoiceHeaderInput.Amount;
        Closed := LppSalesInvoiceHeaderInput.Closed;
        "Payment Terms Days" := "Due Date" - "Posting Date";

        SalesCrMemoHeader.SetRange("Applies-to Doc. Type", SalesCrMemoHeader."Applies-to Doc. Type"::Invoice);
        SalesCrMemoHeader.SetRange("Applies-to Doc. No.", Number);
        Corrected := not SalesCrMemoHeader.IsEmpty();

        CustLedgerEntry.SetRange("Entry No.", LppSalesInvoiceHeaderInput.CustLedgerEntryNo);
        if CustLedgerEntry.FindFirst() then
            "Closed Date" := CustLedgerEntry."Closed at Date";

        PaidLate := LPFeatureTableHelper.WasInvoiceHeaderPaidLate(LppSalesInvoiceHeaderInput);
        // paidLate or (notPaid and late)
        "Is Late" := PaidLate or (("Closed Date" = 0D) and (WorkDate() > "Due Date"));

        if PaidLate and ("Closed Date" <> 0D) then
            "Paid Late Days" := "Closed Date" - "Due Date";

        CalculateFeatures(LppSalesInvoiceHeaderInput.PostingDate, LppSalesInvoiceHeaderInput.BillToCustomerNo);

        Insert();
    end;

    local procedure CalculateFeatures(PostingDate: Date; CustomerNo: Code[20]);
    var
        SourceLPMLInputDataForComputation: Record "LP ML Input Data";
    begin
        // Populate features
        Rec."No. Paid Invoices" := LPFeatureTableHelper.CalculateNumberPaidInvoices(PostingDate, CustomerNo, SourceLPMLInputDataForComputation);
        Rec."No. Paid Late Invoices" := LPFeatureTableHelper.CalculateNumberPaidLateInvoices(PostingDate, CustomerNo, SourceLPMLInputDataForComputation);

        if Rec."No. Paid Invoices" > 0 then
            Rec."Ratio Paid Late/Paid Invoices" := Rec."No. Paid Late Invoices" / Rec."No. Paid Invoices";
        Rec."Total Paid Invoices Amount" := LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(PostingDate, CustomerNo, SourceLPMLInputDataForComputation);
        Rec."Total Paid Late Inv. Amount" := LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(PostingDate, CustomerNo, SourceLPMLInputDataForComputation);

        if Rec."Total Paid Invoices Amount" > 0 then
            Rec."Ratio PaidLateAmnt/PaidAmnt" := Rec."Total Paid Late Inv. Amount" / Rec."Total Paid Invoices Amount";
        Rec."Average Days Late" := LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(PostingDate, CustomerNo, SourceLPMLInputDataForComputation);
        Rec."No. Outstanding Inv." := LPFeatureTableHelper.CalculateNumberOutstandingInvoices(PostingDate, CustomerNo, SourceLPMLInputDataForComputation);
        Rec."No. Outstanding Late Inv." := LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(PostingDate, CustomerNo, SourceLPMLInputDataForComputation);

        if Rec."No. Outstanding Inv." > 0 then
            Rec."Ratio NoOutstngLate/NoOutstng" := Rec."No. Outstanding Late Inv." / Rec."No. Outstanding Inv.";
        Rec."Total Outstng Invoices Amt." := LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(PostingDate, CustomerNo, SourceLPMLInputDataForComputation);
        Rec."Total Outstng Late Inv. Amt." := LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(PostingDate, CustomerNo, SourceLPMLInputDataForComputation);

        if Rec."Total Outstng Invoices Amt." > 0 then
            Rec."Ratio AmtLate/Amt Outstng Inv" := Rec."Total Outstng Late Inv. Amt." / Rec."Total Outstng Invoices Amt.";
        Rec."Average Outstanding Days Late" := LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(PostingDate, CustomerNo, SourceLPMLInputDataForComputation);
    end;

    procedure AddParametersToMgt(var MLPredictionManagement: Codeunit "ML Prediction Management")
    begin
        MLPredictionManagement.SetRecord(Rec);

        MLPredictionManagement.AddFeature(FieldNo("Base Amount"));
        MLPredictionManagement.AddFeature(FieldNo("Payment Terms Days"));
        MLPredictionManagement.AddFeature(FieldNo(Corrected));
        MLPredictionManagement.AddFeature(FieldNo("No. Paid Invoices"));
        MLPredictionManagement.AddFeature(FieldNo("No. Paid Late Invoices"));
        MLPredictionManagement.AddFeature(FieldNo("Ratio Paid Late/Paid Invoices"));
        MLPredictionManagement.AddFeature(FieldNo("Total Paid Invoices Amount"));
        MLPredictionManagement.AddFeature(FieldNo("Total Paid Late Inv. Amount"));
        MLPredictionManagement.AddFeature(FieldNo("Ratio PaidLateAmnt/PaidAmnt"));
        MLPredictionManagement.AddFeature(FieldNo("Average Days Late"));
        MLPredictionManagement.AddFeature(FieldNo("No. Outstanding Inv."));
        MLPredictionManagement.AddFeature(FieldNo("No. Outstanding Late Inv."));
        MLPredictionManagement.AddFeature(FieldNo("Ratio NoOutstngLate/NoOutstng"));
        MLPredictionManagement.AddFeature(FieldNo("Total Outstng Invoices Amt."));
        MLPredictionManagement.AddFeature(FieldNo("Total Outstng Late Inv. Amt."));
        MLPredictionManagement.AddFeature(FieldNo("Ratio AmtLate/Amt Outstng Inv"));
        MLPredictionManagement.AddFeature(FieldNo("Average Outstanding Days Late"));

        MLPredictionManagement.SetConfidence(FieldNo(Confidence));
        MLPredictionManagement.SetLabel(FieldNo("Is Late"));
    end;

    var
        LPFeatureTableHelper: Codeunit "LP Feature Table Helper";

}