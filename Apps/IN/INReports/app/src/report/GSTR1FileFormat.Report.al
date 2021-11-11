report 18049 "GSTR-1 File Format"
{
    Caption = 'GSTR-1 File Format';
    ProcessingOnly = true;
    UseRequestPage = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = sorting(Number)
                                where(Number = const(1));

            trigger OnAfterGetRecord()
            begin
                case NatureofSupply of
                    NatureofSupply::" ":
                        ERRor(FileFormatErr);
                    NatureofSupply::B2B:
                        begin
                            MakeExcelBodyB2B();
                            CreateandOpenExcel(B2BTxt);
                        end;
                    NatureofSupply::B2CL:
                        begin
                            MakeExcelBodyB2CL();
                            CreateandOpenExcel(B2CLTxt);
                        end;
                    NatureofSupply::B2CS:
                        begin
                            MakeExcelBodyB2CS();
                            CreateandOpenExcel(B2CSTxt);
                        end;
                    NatureofSupply::AT:
                        begin
                            MakeExcelBodyAT();
                            CreateandOpenExcel(ATTxt);
                        end;
                    NatureofSupply::ATADJ:
                        begin
                            MakeExcelBodyATADJ();
                            CreateandOpenExcel(ATADJTxt);
                        end;
                    NatureofSupply::CDNR:
                        begin
                            MakeExcelBodyCDNR();
                            CreateandOpenExcel(CDNRTxt);
                        end;
                    NatureofSupply::CDNUR:
                        begin
                            MakeExcelBodyCDNUR();
                            CreateandOpenExcel(CDNURTxt);
                        end;
                    NatureofSupply::EXP:
                        begin
                            MakeExcelBodyEXP();
                            CreateandOpenExcel(EXPTxt);
                        end;
                    NatureofSupply::HSN:
                        begin
                            MakeExcelBodyHSN();
                            CreateandOpenExcel(HSNTxt);
                        end;
                    NatureofSupply::EXEMP:
                        begin
                            MakeExcelBodyEXEMP();
                            CreateandOpenExcel(EXEMPTxt);
                        end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                TempExcelBuffer.DeleteAll();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(GSTIN; LocationGSTIN)
                    {
                        Caption = 'GSTin of the location';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the GST registration number for which the report will be generated.';
                        TableRelation = "GST Registration Nos.".Code;
                    }
                    field(Date; ReturnDate)
                    {
                        Caption = 'Date';
                        ToolTip = 'Specifies the date that you want the period of the Return.';
                        ApplicationArea = Basic, Suite;

                        trigger OnValidate()
                        begin
                            StartDate := CalcDate('<-CM>', ReturnDate);
                            EndDate := CalcDate('<+CM>', ReturnDate);
                        end;
                    }
                    field(FileFormat; NatureofSupply)
                    {
                        Caption = 'File Format';
                        ToolTip = 'Specifies the nature of GST transaction. For example, B2B/B2C.';
                        ApplicationArea = Basic, Suite;

                        trigger OnValidate()
                        begin
                            case NatureofSupply of
                                NatureofSupply::B2CL:
                                    B2CLimit := 250000;
                                NatureofSupply::B2CS:
                                    B2CLimit := 250000;
                                else
                                    B2CLimit := 0.00
                            end;
                        end;
                    }
                    field(B2CLimit; B2CLimit)
                    {
                        Caption = 'B2C Limit';
                        ToolTip = 'Specifies the Invoice Value for B2CL or B2CS. For example , 250000.';
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        if not GuiAllowed then
            exit;

        Progress.Open(ProgressMsg);
    end;

    trigger OnPostReport()
    begin
        Counter += 1;
        Progress.Update(1, Counter);
        Sleep(50);

        Progress.Close();
    end;

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        LocationGSTIN: Code[15];
        ReturnDate: Date;
        StartDate: Date;
        B2CLimit: Decimal;
        EndDate: Date;
        Counter: Integer;
        Progress: Dialog;
        ProgressMsg: Label 'Processing......#1######################\';
        B2BTxt: Label 'b2b';
        B2CLTxt: Label 'b2cl';
        ELbl: Label 'E';
        B2CSTxt: Label 'b2cs';
        WOPAYTxt: Label 'wopay';
        WPAYTxt: Label 'wpay';
        OtherECommTxt: Label 'oe';
        TypeTxt: Label 'Type';
        CDNURTxt: Label 'cdnur';
        YLbl: Label 'Y';
        NLbl: Label 'N';
        CLbl: Label 'C';
        DLbl: Label 'D';
        RLbl: Label 'R';
        ATTxt: Label 'at';
        CDNRTxt: Label 'cdnr';
        ATADJTxt: Label 'atadj';
        HSNTxt: Label 'hsn';
        EXPTxt: Label 'exp';
        IGSTLbl: Label 'IGST';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        CessLbl: Label 'CESS';
        NonGSTxt: Label 'Non-GST Supplies';
        DespTxt: Label 'Desciption';
        NilTxt: Label 'Nil Rated Supplies';
        InterRegTxt: Label 'Inter-State supplies to registered persons';
        IntraRegTxt: Label 'Intra-State supplies to registered persons';
        InterUnRegTxt: Label 'Inter-State supplies to unregistered persons';
        IntraUnRegTxt: Label 'Intra-State supplies to unregistered persons';
        ExmpTxt: Label 'Exempted(other than nil rated/non GST supply)';
        EXEMPTxt: Label 'exemp';
        DescTxt: Label 'Desciption Text';
        UQCTxt: Label 'uqc';
        HSNSACofSupplyTxt: Label 'HSN/SAC of Supply';
        SEZWPayTxt: Label 'SEZ With Pay';
        IGSTAmountTxt: Label 'IGST Amount';
        CGSTAmountTxt: Label 'CGST Amount';
        SGSTAmountTxt: Label 'SGST Amount';
        TotalQtyTxt: Label 'Total Quantity';
        TotalValTxt: Label 'Total Value';
        GSTINUINTxt: Label 'GSTIN/Uin of Recipient';
        InvoiceNoTxt: Label 'Invoice Number';
        URTypeTxt: Label 'UR Type';
        RegularTxt: Label 'Regular';
        EXPWOPayTxt: Label 'expwop';
        EXPWPayTxt: Label 'expwp';
        DeemedExportTxt: Label 'Deemed Export';
        ExportTypeTxt: Label 'Export Type';
        PortCodeTxt: Label 'Port Code';
        ShipBillNoTxt: Label 'Shipping Bill Number';
        ShipBillDateTxt: Label 'Shipping Bill Date';
        DocumentTypeTxt: Label 'Document Type';
        PreGSTTxt: Label 'Pre GST';
        RefundVoucherValueTxt: Label 'Note/Refund Voucher Value';
        DebitNoteNoTxt: Label 'Note/Refund Voucher Number';
        DebitNoteDateTxt: Label 'Note/Refund Voucher Date';
        InvoiceDateTxt: Label 'Invoice Date';
        InvoiceValueTxt: Label 'Invoice Value';
        PlaceofSupplyTxt: Label 'Place of Supply';
        ReverseChargeTxt: Label 'Reverse Charge';
        ECommGSTINTxt: Label 'E-Commerce GSTIN';
        TaxableValueTxt: Label 'Taxable Value';
        CESSAmountTxt: Label 'CESS Amount';
        GrossAdvanceRcvdTxt: Label 'Gross Advance Received';
        RateTxt: Label 'Rate';
        FileFormatErr: Label 'You must select GSTR File Format.';
        SEZWOPayTxt: Label 'SEZ Without Pay';
        OriginalInvNoTxt: Label 'Invoice/Advance Receipt Number';
        OriginalInvDateTxt: Label 'Invoice/Advance Receipt date';
        InvoiceTypeTxt: Label 'Invoice Type';
        ReceiverTxt: Label 'Receiver Name';
        TaxTxt: Label 'Applicable % of Tax Rate';
        ExempIntraRegAmount: Decimal;
        ExempInterRegAmount: Decimal;
        ExpExempInterRegAmt: Decimal;
        ExpExempIntraRegAmt: Decimal;
        ExpExempInterUnRegAmt: Decimal;
        ExpExempIntraUnRegAmt: Decimal;
        ExempCustIntraUnRegAmt: Decimal;
        ExempCustInterUnRegAmt: Decimal;
        ExempNonGSTInterRegAmt: Decimal;
        EXempNonGSTIntraRegAmt: Decimal;
        ExempNonGSTInterUnRegAmt: Decimal;
        ExempNonGSTIntraUnRegAmt: Decimal;
        NatureofSupply: Enum "Nature of Supply";

    procedure MakeExcelHeaderB2B()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(GSTINUINTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ReceiverTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(PlaceofSupplyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ReverseChargeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ECommGSTINTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxableValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CESSAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyB2B()
    var
        GSTR1B2BQuery: Query GSTR1B2BQuery;
    begin
        MakeExcelHeaderB2B();
        GSTR1B2BQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2BQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2BQuery.SetFilter(GSTR1B2BQuery.GST_Customer_Type, '%1|%2|%3|%4', "GST Customer Type"::"Deemed Export", "GST Customer Type"::"SEZ Unit", "GST Customer Type"::"SEZ Development", "GST Customer Type"::Registered);
        GSTR1B2BQuery.Open();
        while GSTR1B2BQuery.Read() do
            FillExcelBufferB2B(GSTR1B2BQuery);
    end;

    local procedure FillExcelBufferB2B(GSTR1B2BQuery: Query GSTR1B2BQuery)
    var
        GSTR1B2BGSTPer: Query GSTR1B2BGSTPer;
        GSTR1B2BCessAmt: Query GSTR1B2BCessAmt;
    begin
        TempExcelBuffer.NewRow();
        if GSTR1B2BQuery.Reverse_Charge then
            TempExcelBuffer.AddColumn(GSTR1B2BQuery.Location__Reg__No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn(GSTR1B2BQuery.Buyer_Seller_Reg__No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if GSTR1B2BQuery.Source_No_ <> '' then
            TempExcelBuffer.AddColumn(GSTR1B2BQuery.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn(GSTR1B2BQuery.Document_No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        if GSTR1B2BQuery.Original_Doc__Type = GSTR1B2BQuery.Original_Doc__Type::"Transfer Shipment" then begin
            TempExcelBuffer.AddColumn(GSTR1B2BQuery.Posting_Date, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
        end else begin
            TempExcelBuffer.AddColumn(GetDocumentDate(GSTR1B2BQuery.Document_No_, "GST Document Type"::Invoice), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
            if GSTR1B2BQuery.Finance_Charge_Memo then
                TempExcelBuffer.AddColumn(GetInvoiceValueFinCharge(GSTR1B2BQuery.Document_No_), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(GetInvoiceValue(GSTR1B2BQuery.Document_No_, "GST Document Type"::Invoice), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        end;

        if GSTR1B2BQuery.Buyer_Seller_State_Code <> '' then
            TempExcelBuffer.AddColumn(GSTR1B2BQuery.State_Code__GST_Reg__No__ + '-' + GSTR1B2BQuery.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if GSTR1B2BQuery.Reverse_Charge then
            TempExcelBuffer.AddColumn(YLbl, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn(NLbl, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GetInvoiceType(GSTR1B2BQuery), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if GSTR1B2BQuery.e_Comm__Operator_GST_Reg__No_ <> '' then
            TempExcelBuffer.AddColumn(GSTR1B2BQuery.e_Comm__Operator_GST_Reg__No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR1B2BGSTPer.TopNumberOfRows(1);
        GSTR1B2BGSTPer.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2BGSTPer.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2BGSTPer.SetRange(Document_No_, GSTR1B2BQuery.Document_No_);
        GSTR1B2BGSTPer.SetRange(GST_Customer_Type, GSTR1B2BQuery.GST_Customer_Type);
        GSTR1B2BGSTPer.Open();
        while GSTR1B2BGSTPer.Read() do
            if GSTR1B2BGSTPer.GST_Jurisdiction_Type = GSTR1B2BGSTPer.GST_Jurisdiction_Type::Intrastate then
                TempExcelBuffer.AddColumn(2 * GSTR1B2BGSTPer.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(GSTR1B2BGSTPer.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        if GSTR1B2BQuery.GST_Jurisdiction_Type = GSTR1B2BQuery.GST_Jurisdiction_Type::Intrastate then
            TempExcelBuffer.AddColumn(Abs(GSTR1B2BQuery.GST_Base_Amount / 2), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(Abs(GSTR1B2BQuery.GST_Base_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR1B2BCessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2BCessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2BCessAmt.SetRange(GSTR1B2BCessAmt.Document_No_, GSTR1B2BQuery.Document_No_);
        GSTR1B2BCessAmt.SetRange(GSTR1B2BCessAmt.GST_Customer_Type, GSTR1B2BQuery.GST_Customer_Type);
        GSTR1B2BCessAmt.Open();
        if GSTR1B2BCessAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR1B2BCessAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(0.00, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
    end;

    local procedure MakeExcelHeaderB2CL()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(InvoiceNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(PlaceofSupplyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxableValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CESSAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ECommGSTINTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyB2CL()
    var
        GSTR1B2CLQuery: Query GSTR1B2CLQuery;
    begin
        MakeExcelHeaderB2CL();
        GSTR1B2CLQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2CLQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2CLQuery.SetRange(GSTR1B2CLQuery.GST_Jurisdiction_Type, "GST Jurisdiction Type"::Interstate);
        GSTR1B2CLQuery.Open();
        while GSTR1B2CLQuery.Read() do
            if GetInvoiceValue(GSTR1B2CLQuery.Document_No_, "GST Document Type"::Invoice) >= B2CLimit then
                FillExcelBufferForB2CL(GSTR1B2CLQuery);
    end;

    local procedure FillExcelBufferForB2CL(GSTR1B2CLQuery: Query GSTR1B2CLQuery)
    var
        GSTR1B2CLPer: Query GSTR1B2CLPer;
        GSTR1B2CLCessAmt: Query GSTR1B2CLCessAmt;
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(GSTR1B2CLQuery.Document_No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTR1B2CLQuery.Posting_Date, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
        TempExcelBuffer.AddColumn(GetInvoiceValue(GSTR1B2CLQuery.Document_No_, "GST Document Type"::Invoice), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        if GSTR1B2CLQuery.Buyer_Seller_State_Code <> '' then
            TempExcelBuffer.AddColumn(GSTR1B2CLQuery.State_Code__GST_Reg__No__ + '-' + GSTR1B2CLQuery.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR1B2CLPer.TopNumberOfRows(1);
        GSTR1B2CLPer.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2CLPer.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2CLPer.SetRange(GSTR1B2CLPer.Document_No_, GSTR1B2CLQuery.Document_No_);
        GSTR1B2CLPer.SetRange(GSTR1B2CLPer.GST_Jurisdiction_Type, "GST Jurisdiction Type"::Interstate);
        GSTR1B2CLPer.Open();
        while GSTR1B2CLPer.Read() do
            TempExcelBuffer.AddColumn(GSTR1B2CLPer.GST__, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        TempExcelBuffer.AddColumn(Abs(GSTR1B2CLQuery.GST_Base_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR1B2CLCessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2CLCessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2CLCessAmt.SetRange(GSTR1B2CLCessAmt.Document_No_, GSTR1B2CLQuery.Document_No_);
        GSTR1B2CLCessAmt.SetRange(GSTR1B2CLCessAmt.GST_Jurisdiction_Type, "GST Jurisdiction Type"::Interstate);
        GSTR1B2CLCessAmt.Open();
        if GSTR1B2CLCessAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR1B2CLCessAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(0.00, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        if GSTR1B2CLQuery.e_Comm__Operator_GST_Reg__No_ <> '' then
            TempExcelBuffer.AddColumn(GSTR1B2CLQuery.e_Comm__Operator_GST_Reg__No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelHeaderB2CS()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(TypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(PlaceOfSupplyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxableValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CESSAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ECommGSTINTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyB2CS()
    var
        GSTR1B2CSQuery: Query GSTR1B2CSQuery;
    begin
        MakeExcelHeaderB2CS();
        GSTR1B2CSQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2CSQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2CSQuery.SetFilter(GST_Customer_Type, '%1', "GST Customer Type"::Unregistered);
        GSTR1B2CSQuery.SetFilter(Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
        GSTR1B2CSQuery.Open();
        while GSTR1B2CSQuery.Read() do
            FillExcelBufferForB2CS(GSTR1B2CSQuery);
    end;

    local procedure FillExcelBufferForB2CS(GSTR1B2CSQuery: Query GSTR1B2CSQuery)
    var
        State: Record State;
        GSTR1B2CSCessAmt: Query GSTR1B2CSCessAmt;
        GSTR1B2CInterCess: query GSTR1B2CInterCess;
        GSTR1B2CSIntraAmt: Query GSTR1B2CSIntra;
        GSTR1B2CSPer: Query GSTR1B2CSPer;
        GSTR1B2CSInter: Query GSTR1B2CSInter;
        GSTR1B2CSIntraCess: Query GSTR1B2CIntraCess;
        GSTRB2CSIntraAmount: Decimal;
        GSTR1B2CSInterBaseAmt: Decimal;
        GSTR1IntraCess: Decimal;
        GSTR1InterCess: Decimal;
    begin
        TempExcelBuffer.NewRow();
        if GSTR1B2CSQuery.e_Comm__Operator_GST_Reg__No_ <> '' then
            TempExcelBuffer.AddColumn(ELbl, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn(UpperCase(OtherECommTxt), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if State.Get(GSTR1B2CSQuery.Buyer_Seller_State_Code) then
            TempExcelBuffer.AddColumn(State."State Code (GST Reg. No.)" + '-' + State.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR1B2CSPer.TopNumberOfRows(1);
        GSTR1B2CSPer.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2CSPer.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2CSPer.SetFilter(GST_Customer_Type, '%1', "GST Customer Type"::Unregistered);
        GSTR1B2CSPer.SetFilter(Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
        GSTR1B2CSPer.Open();
        while GSTR1B2CSPer.Read() do
            if GSTR1B2CSPer.GST_Jurisdiction_Type = GSTR1B2CSPer.GST_Jurisdiction_Type::Intrastate then
                TempExcelBuffer.AddColumn(2 * GSTR1B2CSPer.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(GSTR1B2CSPer.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        GSTR1B2CSIntraAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2CSIntraAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2CSIntraAmt.SetFilter(GST_Customer_Type, '%1', "GST Customer Type"::Unregistered);
        GSTR1B2CSIntraAmt.SetRange(e_Comm__Operator_GST_Reg__No_, GSTR1B2CSQuery.e_Comm__Operator_GST_Reg__No_);
        GSTR1B2CSIntraAmt.SetRange(GSTR1B2CSIntraAmt.Buyer_Seller_State_Code, GSTR1B2CSQuery.Buyer_Seller_State_Code);
        GSTR1B2CSIntraAmt.SetFilter(Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
        GSTR1B2CSIntraAmt.Open();
        while GSTR1B2CSIntraAmt.Read() do
            GSTRB2CSIntraAmount := GSTR1B2CSIntraAmt.GST_Base_Amount;

        GSTR1B2CSInter.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2CSInter.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2CSInter.SetFilter(GST_Customer_Type, '%1', "GST Customer Type"::Unregistered);
        GSTR1B2CSInter.SetRange(e_Comm__Operator_GST_Reg__No_, GSTR1B2CSQuery.e_Comm__Operator_GST_Reg__No_);
        GSTR1B2CSInter.SetRange(GSTR1B2CSInter.Buyer_Seller_State_Code, GSTR1B2CSQuery.Buyer_Seller_State_Code);
        GSTR1B2CSInter.SetFilter(Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
        GSTR1B2CSInter.Open();
        while GSTR1B2CSInter.Read() do
            GSTR1B2CSInterBaseAmt := GSTR1B2CSInter.GST_Base_Amount;

        TempExcelBuffer.AddColumn(Abs(GSTR1B2CSInterBaseAmt + GSTRB2CSIntraAmount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR1B2CSCessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1B2CSCessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1B2CSCessAmt.SetFilter(GST_Customer_Type, '%1', "GST Customer Type"::Unregistered);
        GSTR1B2CSCessAmt.SetFilter(Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
        GSTR1B2CSCessAmt.Open();
        if GSTR1B2CSCessAmt.Read() then begin
            GSTR1B2CSIntraCess.SetRange(Location__Reg__No_, LocationGSTIN);
            GSTR1B2CSIntraCess.SetRange(Posting_Date, StartDate, EndDate);
            GSTR1B2CSIntraCess.SetFilter(GST_Customer_Type, '%1', "GST Customer Type"::Unregistered);
            GSTR1B2CSIntraCess.SetRange(e_Comm__Operator_GST_Reg__No_, GSTR1B2CSQuery.e_Comm__Operator_GST_Reg__No_);
            GSTR1B2CSIntraCess.SetRange(Buyer_Seller_State_Code, GSTR1B2CSQuery.Buyer_Seller_State_Code);
            GSTR1B2CSIntraCess.SetFilter(Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
            GSTR1B2CSIntraCess.Open();
            while GSTR1B2CSIntraCess.Read() do
                GSTR1IntraCess := GSTR1B2CSIntraCess.GST_Amount;

            GSTR1B2CInterCess.SetRange(Location__Reg__No_, LocationGSTIN);
            GSTR1B2CInterCess.SetRange(Posting_Date, StartDate, EndDate);
            GSTR1B2CInterCess.SetFilter(GST_Customer_Type, '%1', "GST Customer Type"::Unregistered);
            GSTR1B2CInterCess.SetRange(e_Comm__Operator_GST_Reg__No_, GSTR1B2CSQuery.e_Comm__Operator_GST_Reg__No_);
            GSTR1B2CInterCess.SetRange(Buyer_Seller_State_Code, GSTR1B2CSQuery.Buyer_Seller_State_Code);
            GSTR1B2CInterCess.SetFilter(Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
            GSTR1B2CInterCess.Open();
            while GSTR1B2CInterCess.Read() do
                GSTR1InterCess := GSTR1B2CInterCess.GST_Amount;
        end;

        TempExcelBuffer.AddColumn(Abs(GSTR1IntraCess + GSTR1InterCess), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        if GSTR1B2CSQuery.e_Comm__Operator_GST_Reg__No_ <> '' then
            TempExcelBuffer.AddColumn(GSTR1B2CSQuery.e_Comm__Operator_GST_Reg__No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelHeaderAT()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(PlaceOfSupplyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GrossAdvanceRcvdTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CESSAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyAT()
    var
        GSTR1ATQuery: Query GSTR1ATQuery;
    begin
        MakeExcelHeaderAT();
        GSTR1ATQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ATQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ATQuery.SetRange(GSTR1ATQuery.Reversed, false);
        GSTR1ATQuery.SetRange(GST_on_Advance_Payment, true);
        GSTR1ATQuery.Open();
        while GSTR1ATQuery.Read() do
            FillExcelBufferForAT(GSTR1ATQuery);
    end;

    local procedure MakeExcelHeaderHSN()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(HSNSACofSupplyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DescTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(UpperCase(UQCTxt), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TotalQtyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TotalValTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxableValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(IGSTAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CGSTAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(SGSTAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CESSAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyHSN()
    var
        GSTR1HSNQuery: Query GSTR1HSNQuery;
    begin
        MakeExcelHeaderHSN();
        GSTR1HSNQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1HSNQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1HSNQuery.SetFilter(GSTR1HSNQuery.Document_Type, '%1|%2', "GST Document Type"::Invoice, "GST Document Type"::"Credit Memo");
        GSTR1HSNQuery.Open();
        while GSTR1HSNQuery.Read() do
            FillExcelBufferForHSN(GSTR1HSNQuery);
    end;

    local procedure FillExcelBufferForHSN(GSTR1HSNQuery: Query GSTR1HSNQuery)
    var
        GSTR1HSNGSTAmt: Query GSTR1HSNGSTAmt;
        GSTR1HSNQty: Query GSTR1HSNQty;
        HSNIGSTAmt: Decimal;
        HSNCGSTAmt: Decimal;
        HSNSGSTAmt: Decimal;
        HSNCessAmt: Decimal;
        HSNQty: Decimal;
        HSNGSTBaseAmt: Decimal;
    begin
        GSTR1HSNGSTAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1HSNGSTAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1HSNGSTAmt.SetRange(HSN_SAC_Code, GSTR1HSNQuery.HSN_SAC_Code);
        GSTR1HSNGSTAmt.SetRange(GST_Component_Code, CGSTLbl);
        GSTR1HSNGSTAmt.SetRange(UOM, GSTR1HSNQuery.UOM);
        GSTR1HSNGSTAmt.Open();
        while GSTR1HSNGSTAmt.Read() do
            HSNCGSTAmt := GSTR1HSNGSTAmt.GST_Amount;

        GSTR1HSNGSTAmt.SetRange(GST_Component_Code, SGSTLbl);
        GSTR1HSNGSTAmt.Open();
        while GSTR1HSNGSTAmt.Read() do
            HSNSGSTAmt := GSTR1HSNGSTAmt.GST_Amount;

        GSTR1HSNGSTAmt.SetRange(GST_Component_Code, IGSTLbl);
        GSTR1HSNGSTAmt.Open();
        while GSTR1HSNGSTAmt.Read() do
            HSNIGSTAmt := GSTR1HSNGSTAmt.GST_Amount;

        GSTR1HSNGSTAmt.SetRange(GST_Component_Code, CessLbl);
        GSTR1HSNGSTAmt.Open();
        while GSTR1HSNGSTAmt.Read() do
            HSNCessAmt := GSTR1HSNGSTAmt.GST_Amount;

        GSTR1HSNQty.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1HSNQty.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1HSNQty.SetRange(HSN_SAC_Code, GSTR1HSNQuery.HSN_SAC_Code);
        GSTR1HSNQty.SetRange(UOM, GSTR1HSNQuery.UOM);
        GSTR1HSNQty.Open();
        while GSTR1HSNQty.Read() do
            if GSTR1HSNQty.GST_Jurisdiction_Type = GSTR1HSNQty.GST_Jurisdiction_Type::Intrastate then begin
                HSNQty += GSTR1HSNQty.Quantity / 2;
                HSNGSTBaseAmt += GSTR1HSNQty.GST_Base_Amount / 2;
            end else begin
                HSNQty += GSTR1HSNQty.Quantity;
                HSNGSTBaseAmt += GSTR1HSNQty.GST_Base_Amount;
            end;

        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(GSTR1HSNQuery.HSN_SAC_Code, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if GSTR1HSNQuery.HSN_SAC_Code <> '' then
            TempExcelBuffer.AddColumn(GSTR1HSNQuery.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn(GSTR1HSNQuery.UOM, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(-(HSNQty), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(-(HSNGSTBaseAmt + HSNIGSTAmt + HSNCGSTAmt + HSNSGSTAmt + HSNCessAmt), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(-(HSNGSTBaseAmt), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(-HSNIGSTAmt, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(-HSNCGSTAmt, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(-HSNSGSTAmt, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(-HSNCessAmt, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
    end;

    local procedure MakeExcelHeaderEXP()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(ExportTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(InvoiceValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(PortCodeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ShipBillNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ShipBillDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxableValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CESSAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyEXP()
    var
        GSTR1EXPQuery: Query GSTR1ExpQuery;
    begin
        MakeExcelHeaderEXP();
        GSTR1EXPQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1EXPQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1EXPQuery.Open();
        while GSTR1EXPQuery.Read() do
            FillExcelBufferForExport(GSTR1ExpQuery);
    end;

    local procedure FillExcelBufferForExport(GSTR1ExpQuery: Query GSTR1ExpQuery)
    var
        GSTR1ExpPerQuery: Query GSTR1ExpPer;
        GSTR1ExpCessAmt: Query GSTR1ExpCessAmt;
    begin
        TempExcelBuffer.NewRow();
        if GSTR1ExpQuery.GST_Without_Payment_of_Duty then
            TempExcelBuffer.AddColumn(UpperCase(WOPAYTxt), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn(UpperCase(WPAYTxt), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        TempExcelBuffer.AddColumn(GSTR1ExpQuery.Document_No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTR1ExpQuery.Posting_Date, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);

        if GSTR1ExpQuery.Finance_Charge_Memo then
            TempExcelBuffer.AddColumn(GetInvoiceValueFinCharge(GSTR1ExpQuery.Document_No_), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(GetInvoiceValue(GSTR1ExpQuery.Document_No_, "GST Document Type"::Invoice), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        TempExcelBuffer.AddColumn(GetExitPoint(GSTR1ExpQuery.Document_No_), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTR1ExpQuery.Bill_Of_Export_No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTR1ExpQuery.Bill_Of_Export_Date, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
        TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR1ExpPerQuery.TopNumberOfRows(1);
        GSTR1ExpPerQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ExpPerQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ExpPerQuery.SetRange(Document_No_, GSTR1ExpQuery.Document_No_);
        GSTR1ExpPerQuery.Open();
        while GSTR1ExpPerQuery.Read() do
            TempExcelBuffer.AddColumn(Abs(GSTR1ExpPerQuery.GST__), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        if GSTR1ExpQuery.GST_Jurisdiction_Type = GSTR1ExpQuery.GST_Jurisdiction_Type::Intrastate then
            TempExcelBuffer.AddColumn(Abs(GSTR1ExpQuery.GST_Base_Amount / 2), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(Abs(GSTR1ExpQuery.GST_Base_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR1ExpCessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ExpCessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ExpCessAmt.SetRange(Document_No_, GSTR1ExpQuery.Document_No_);
        GSTR1ExpCessAmt.Open();
        if GSTR1ExpCessAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR1ExpCessAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(0.00, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
    end;

    local procedure GetExitPoint(DocumentNo: Code[20]): Code[10]
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if SalesInvoiceHeader.Get(DocumentNo) then
            exit(SalesInvoiceHeader."Exit Point");
    end;

    local procedure MakeExcelHeaderATADJ()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(PlaceOfSupplyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GrossAdvanceRcvdTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CESSAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyATADJ()
    var
        GSTR1ATADJQuery: Query GSTR1ATADJQuery;
    begin
        MakeExcelHeaderATADJ();
        GSTR1ATADJQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ATADJQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ATADJQuery.SetRange(UnApplied, false);
        GSTR1ATADJQuery.SetRange(Reversed, false);
        GSTR1ATADJQuery.Open();
        while GSTR1ATADJQuery.Read() do
            FillExcelBufferForATADJ(GSTR1ATADJQuery);
    end;

    local procedure FillExcelBufferForATADJ(GSTR1ATADJQuery: Query GSTR1ATADJQuery)
    var
        State: Record State;
        GSTR1ATADJGSTPer: Query GSTR1ATADJGSTPer;
        GSTR1ATADJCessAmt: Query GSTR1ATADJCessAmt;
    begin
        TempExcelBuffer.NewRow();
        if State.Get(GSTR1ATADJQuery.Buyer_Seller_State_Code) then
            TempExcelBuffer.AddColumn(GSTR1ATADJQuery.State_Code__GST_Reg__No__ + '-' + GSTR1ATADJQuery.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR1ATADJGSTPer.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ATADJGSTPer.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ATADJGSTPer.SetRange(UnApplied, false);
        GSTR1ATADJGSTPer.SetRange(Reversed, false);
        GSTR1ATADJGSTPer.Open();
        if GSTR1ATADJGSTPer.Read() then
            if GSTR1ATADJGSTPer.GST_Jurisdiction_Type = GSTR1ATADJGSTPer.GST_Jurisdiction_Type::Intrastate then
                TempExcelBuffer.AddColumn(2 * GSTR1ATADJGSTPer.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(GSTR1ATADJGSTPer.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        if GSTR1ATADJQuery.GST_Jurisdiction_Type = GSTR1ATADJQuery.GST_Jurisdiction_Type::Intrastate then
            TempExcelBuffer.AddColumn(Abs(GSTR1ATADJQuery.GST_Base_Amount / 2), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(Abs(GSTR1ATADJQuery.GST_Base_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR1ATADJCessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ATADJCessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ATADJCessAmt.SetRange(UnApplied, false);
        GSTR1ATADJCessAmt.SetRange(Reversed, false);
        GSTR1ATADJCessAmt.Open();
        if GSTR1ATADJCessAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR1ATADJCessAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(0.00, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
    end;

    local procedure FillExcelBufferForAT(GSTR1ATQuery: Query GSTR1ATQuery)
    var
        State: Record State;
        GSTR1ATPer: Query GSTR1ATPer;
        GSTR1ATCessAmt: Query GSTR1ATCessAmt;
    begin
        TempExcelBuffer.NewRow();
        if State.Get(GSTR1ATQuery.Buyer_Seller_State_Code) then
            TempExcelBuffer.AddColumn(GSTR1ATQuery.State_Code__GST_Reg__No__ + '-' + GSTR1ATQuery.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR1ATPer.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ATPer.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ATPer.SetRange(GST_on_Advance_Payment, true);
        GSTR1ATPer.SetRange(Document_No_, GSTR1ATQuery.Document_No_);
        GSTR1ATPer.SetRange(Reversed, false);
        GSTR1ATPer.Open();
        while GSTR1ATPer.Read() do
            if GSTR1ATPer.GST_Jurisdiction_Type = GSTR1ATPer.GST_Jurisdiction_Type::Intrastate then
                TempExcelBuffer.AddColumn(2 * GSTR1ATPer.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(GSTR1ATPer.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        if GSTR1ATQuery.GST_Jurisdiction_Type = GSTR1ATQuery.GST_Jurisdiction_Type::Intrastate then
            TempExcelBuffer.AddColumn(Abs(GSTR1ATQuery.GST_Base_Amount / 2), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(Abs(GSTR1ATQuery.GST_Base_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR1ATCessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ATCessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ATCessAmt.SetRange(GST_on_Advance_Payment, true);
        GSTR1ATCessAmt.SetRange(Document_No_, GSTR1ATQuery.Document_No_);
        GSTR1ATCessAmt.SetRange(Reversed, false);
        GSTR1ATCessAmt.Open();
        if GSTR1ATCessAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR1ATCessAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(0.00, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
    end;

    local procedure MakeExcelHeaderCDNR()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(GSTINUINTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ReceiverTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(OriginalInvNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(OriginalInvDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DebitNoteNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DebitNoteDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DocumentTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(PlaceOfSupplyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RefundVoucherValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxableValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CESSAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(PreGSTTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyCDNR()
    var
        GSTR1CDNRQuery: Query GSTR1CDNRQuery;
    begin
        MakeExcelHeaderCDNR();
        GSTR1CDNRQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1CDNRQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1CDNRQuery.SetFilter(Document_Type, '%1|%2|%3',
            "GST Document Type"::"Credit Memo",
            "GST Document Type"::Invoice,
            "GST Document Type"::Refund);
        GSTR1CDNRQuery.SetFilter(GST_Customer_Type, '%1|%2|%3|%4',
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit",
            "GST Customer Type"::Registered);
        GSTR1CDNRQuery.Open();
        while GSTR1CDNRQuery.Read() do
            if FilterDGLEForCDNR(GSTR1CDNRQuery) then
                FillExcelBufferForCDNR(GSTR1CDNRQuery);
    end;

    local procedure FilterDGLEForCDNR(GSTR1CDNRQuery: Query GSTR1CDNRQuery): Boolean
    begin
        if FilterDGLEDocTypeForCDNR(GSTR1CDNRQuery) or FilterDGLEDocTypeInvForCDNR(GSTR1CDNRQuery) then
            exit(true);
    end;

    local procedure FilterDGLEDocTypeForCDNR(GSTR1CDNRQuery: Query GSTR1CDNRQuery): Boolean
    begin
        if (GSTR1CDNRQuery.Document_Type = GSTR1CDNRQuery.Document_Type::"Credit Memo") or (FilterDGLEForRefundDocType(GSTR1CDNRQuery)) then
            exit(true);
    end;

    local procedure FilterDGLEForRefundDocType(GSTR1CDNRQuery: Query GSTR1CDNRQuery): Boolean
    begin
        if (GSTR1CDNRQuery.Document_Type = GSTR1CDNRQuery.Document_Type::Refund) and (not GSTR1CDNRQuery.Adv__Pmt__Adjustment) then
            exit(true);
    end;

    local procedure FilterDGLEDocTypeInvForCDNR(GSTR1CDNRQuery: Query GSTR1CDNRQuery): Boolean
    begin
        if (GSTR1CDNRQuery.Document_Type = GSTR1CDNRQuery.Document_Type::Invoice) and FilterDGLESalesInvForCDNR(GSTR1CDNRQuery) then
            exit(true);
    end;

    local procedure FillExcelBufferForCDNR(GSTR1CDNRQuery: Query GSTR1CDNRQuery)
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        GSTR1CDNRPerQuery: Query GSTR1CDNRPerQuery;
        GSTR1CDNRCess: Query GSTR1CDNRCess;
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(GSTR1CDNRQuery.Buyer_Seller_Reg__No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if GSTR1CDNRQuery.Source_No_ <> '' then
            TempExcelBuffer.AddColumn(GSTR1CDNRQuery.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if (GSTR1CDNRQuery.Document_Type in [GSTR1CDNRQuery.Document_Type::"Credit Memo", GSTR1CDNRQuery.Document_Type::Invoice]) then begin
            ReferenceInvoiceNo.Reset();
            ReferenceInvoiceNo.SetRange("Document No.", GSTR1CDNRQuery.Document_No_);
            ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType2DocumentTypeEnum(GSTR1CDNRQuery.Document_Type));
            ReferenceInvoiceNo.SetRange("Source No.", GSTR1CDNRQuery.Source_No_);
            if ReferenceInvoiceNo.FindFirst() then begin
                TempExcelBuffer.AddColumn(ReferenceInvoiceNo."Reference Invoice Nos.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(GetPostingDate(ReferenceInvoiceNo), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
            end else begin
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
            end;
        end;

        TempExcelBuffer.AddColumn(GSTR1CDNRQuery.Document_No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTR1CDNRQuery.Posting_Date, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);

        TempExcelBuffer.AddColumn(GetDocumentTypeTxt(GSTR1CDNRQuery.Document_Type), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if GSTR1CDNRQuery.Buyer_Seller_State_Code <> '' then
            TempExcelBuffer.AddColumn(GSTR1CDNRQuery.State_Code__GST_Reg__No__ + '-' + GSTR1CDNRQuery.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if GSTR1CDNRQuery.Document_Type in [GSTR1CDNRQuery.Document_Type::Invoice, GSTR1CDNRQuery.Document_Type::"Credit Memo"] then
            if GSTR1CDNRQuery.Finance_Charge_Memo then
                TempExcelBuffer.AddColumn(GetInvoiceValueFinCharge(GSTR1CDNRQuery.Document_No_), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(GetInvoiceValue(GSTR1CDNRQuery.Document_No_, GSTR1CDNRQuery.Document_Type), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(Abs(GSTR1CDNRQuery.GST_Base_Amount) + Abs(GSTR1CDNRCess.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR1CDNRPerQuery.TopNumberOfRows(1);
        GSTR1CDNRPerQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1CDNRPerQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1CDNRPerQuery.SetRange(Document_No_, GSTR1CDNRQuery.Document_No_);
        GSTR1CDNRPerQuery.SetRange(Document_Type, GSTR1CDNRQuery.Document_Type);
        GSTR1CDNRPerQuery.Open();
        while GSTR1CDNRPerQuery.Read() do
            if GSTR1CDNRPerQuery.GST_Jurisdiction_Type = GSTR1CDNRPerQuery.GST_Jurisdiction_Type::Intrastate then
                TempExcelBuffer.AddColumn(2 * GSTR1CDNRPerQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(GSTR1CDNRPerQuery.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        if GSTR1CDNRQuery.GST_Jurisdiction_Type = GSTR1CDNRQuery.GST_Jurisdiction_Type::Intrastate then
            TempExcelBuffer.AddColumn(Abs(GSTR1CDNRQuery.GST_Base_Amount / 2), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(Abs(GSTR1CDNRQuery.GST_Base_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR1CDNRCess.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1CDNRCess.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1CDNRCess.SetRange(GSTR1CDNRCess.Document_No_, GSTR1CDNRQuery.Document_No_);
        GSTR1CDNRCess.SetRange(Document_No_, GSTR1CDNRQuery.Document_No_);
        GSTR1CDNRCess.SetRange(Document_Type, GSTR1CDNRQuery.Document_Type);
        GSTR1CDNRCess.Open();
        if GSTR1CDNRCess.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR1CDNRCess.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(0.00, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        if CheckPreGSTForCDNR(GSTR1CDNRQuery) then
            TempExcelBuffer.AddColumn(YLbl, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn(NLbl, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure GetPostingDate(var ReferenceInvoiceNo: Record "Reference Invoice No."): Date
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PostingDate: Date;
    begin
        CustLedgerEntry.SetRange("Customer No.", ReferenceInvoiceNo."Source No.");
        CustLedgerEntry.SetFilter("Document Type", '%1|%2', CustLedgerEntry."Document Type"::Invoice, CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", ReferenceInvoiceNo."Reference Invoice Nos.");
        if CustLedgerEntry.FindFirst() then
            PostingDate := CustLedgerEntry."Posting Date";
        exit(PostingDate);
    end;

    local procedure GSTDocumentType2DocumentTypeEnum(GSTDocumentType: Enum "GST Document Type"): Enum "Document Type Enum"
    begin
        case GSTDocumentType of
            GSTDocumentType::"Credit Memo":
                exit("Document Type Enum"::"Credit Memo");
            GSTDocumentType::Invoice:
                exit("Document Type Enum"::Invoice);
            GSTDocumentType::Refund:
                exit("Document Type Enum"::Refund);
            GSTDocumentType::Payment:
                exit("Document Type Enum"::Payment);
        end;
    end;

    local procedure MakeExcelHeaderCDNUR()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(URTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DebitNoteNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DebitNoteDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(DocumentTypeTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(OriginalInvNoTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(OriginalInvDateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(PlaceOfSupplyTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RefundVoucherValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(RateTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(TaxableValueTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CESSAmountTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(PreGSTTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyCDNUR()
    var
        GSTR1CDNURQuery: Query GSTR1CDNURQuery;
    begin
        MakeExcelHeaderCDNUR();
        GSTR1CDNURQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1CDNURQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1CDNURQuery.SetFilter(Document_Type, '%1|%2|%3',
            "GST Document Type"::"Credit Memo",
            "GST Document Type"::Invoice,
            "GST Document Type"::Refund);
        GSTR1CDNURQuery.SetFilter(GST_Customer_Type, '%1|%2',
            "GST Customer Type"::Export,
            "GST Customer Type"::Unregistered);
        GSTR1CDNURQuery.Open();
        while GSTR1CDNURQuery.Read() do
            if FilterDGLEForCDNUR(GSTR1CDNURQuery) then
                MakeExcelBodyLinesCDNUR(GSTR1CDNURQuery);
    end;

    local procedure MakeExcelBodyLinesCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery)
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        GSTR1CDNURGSTPer: Query GSTR1CDNURGSTPer;
        GSTR1CDNURCessAmt: Query GSTR1CDNURCessAmt;
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(GetURType(GSTR1CDNURQuery), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTR1CDNURQuery.Document_No_, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GSTR1CDNURQuery.Posting_Date, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
        TempExcelBuffer.AddColumn(GetDocumentTypeTxt(GSTR1CDNURQuery.Document_Type), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if (GSTR1CDNURQuery.Document_Type in [GSTR1CDNURQuery.Document_Type::"Credit Memo", GSTR1CDNURQuery.Document_Type::Invoice]) then begin
            ReferenceInvoiceNo.Reset();
            ReferenceInvoiceNo.SetRange("Document No.", GSTR1CDNURQuery.Document_No_);
            ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType2DocumentTypeEnum(GSTR1CDNURQuery.Document_Type));
            ReferenceInvoiceNo.SetRange("Source No.", GSTR1CDNURQuery.Source_No_);
            if ReferenceInvoiceNo.FindFirst() then begin
                TempExcelBuffer.AddColumn(ReferenceInvoiceNo."Reference Invoice Nos.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(GetPostingDate(ReferenceInvoiceNo), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
            end else begin
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
            end;
        end;

        if GSTR1CDNURQuery.Buyer_Seller_State_Code <> '' then
            TempExcelBuffer.AddColumn(GetStateCodeGSTRegForCDNUR(GSTR1CDNURQuery) + '-' + GetStateDesForCDNUR(GSTR1CDNURQuery), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn(GetLocStateCodeRegForCDNUR(GSTR1CDNURQuery) + '-' + GetLocStateDesForCDNUR(GSTR1CDNURQuery), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if GSTR1CDNURQuery.Document_Type in [GSTR1CDNURQuery.Document_Type::"Credit Memo", GSTR1CDNURQuery.Document_Type::Invoice] then
            if GSTR1CDNURQuery.Finance_Charge_Memo then
                TempExcelBuffer.AddColumn(GetInvoiceValueFinCharge(GSTR1CDNURQuery.Document_No_), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(GetInvoiceValue(GSTR1CDNURQuery.Document_No_, GSTR1CDNURQuery.Document_Type), false, '0.00', false, false, false, '', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(Abs(GSTR1CDNURQuery.GST_Base_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        GSTR1CDNURGSTPer.TopNumberOfRows(1);
        GSTR1CDNURGSTPer.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1CDNURGSTPer.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1CDNURGSTPer.SetRange(Document_No_, GSTR1CDNURQuery.Document_No_);
        GSTR1CDNURGSTPer.SetRange(Document_Type, GSTR1CDNURQuery.Document_Type);
        GSTR1CDNURGSTPer.SetRange(GST_Customer_Type, GSTR1CDNURQuery.GST_Customer_Type);
        GSTR1CDNURGSTPer.Open();
        while GSTR1CDNURGSTPer.Read() do
            if GSTR1CDNURGSTPer.GST_Jurisdiction_Type = GSTR1CDNURGSTPer.GST_Jurisdiction_Type::Intrastate then
                TempExcelBuffer.AddColumn(2 * GSTR1CDNURGSTPer.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number)
            else
                TempExcelBuffer.AddColumn(GSTR1CDNURGSTPer.GST__, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

        TempExcelBuffer.AddColumn(Abs(GSTR1CDNURQuery.GST_Base_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        GSTR1CDNURCessAmt.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1CDNURCessAmt.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1CDNURCessAmt.SetRange(GSTR1CDNURCessAmt.Document_No_, GSTR1CDNURQuery.Document_No_);
        GSTR1CDNURCessAmt.SetRange(Document_Type, GSTR1CDNURQuery.Document_Type);
        GSTR1CDNURCessAmt.SetRange(GST_Customer_Type, GSTR1CDNURQuery.GST_Customer_Type);
        GSTR1CDNURCessAmt.Open();
        if GSTR1CDNURCessAmt.Read() then
            TempExcelBuffer.AddColumn(Abs(GSTR1CDNURCessAmt.GST_Amount), false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number)
        else
            TempExcelBuffer.AddColumn(0.00, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        if CheckPreGSTForCDNUR(GSTR1CDNURQuery) then
            TempExcelBuffer.AddColumn(YLbl, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
        else
            TempExcelBuffer.AddColumn(NLbl, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure FilterDGLEForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Boolean
    begin
        if FilterDGLECustTypeForCDNUR(GSTR1CDNURQuery) and (FilterDGLEDocTypeForCDNUR(GSTR1CDNURQuery) or FilterDGLEDocTypeInvForCDNUR(GSTR1CDNURQuery)) then
            exit(true);
    end;

    local procedure FilterDGLECustTypeForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Boolean
    begin
        if (GSTR1CDNURQuery.GST_Customer_Type = GSTR1CDNURQuery.GST_Customer_Type::Export) or (FilterDGLEUnregCustForCDNUR(GSTR1CDNURQuery)) then
            exit(true);
    end;

    local procedure FilterDGLEUnregCustForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Boolean
    begin
        if (GSTR1CDNURQuery.GST_Customer_Type = GSTR1CDNURQuery.GST_Customer_Type::Unregistered) and (GetInvoiceValue(GSTR1CDNURQuery.Document_No_, "GST Document Type"::"Credit Memo") >= B2CLimit) then
            exit(true);
    end;

    local procedure FilterDGLEDocTypeForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Boolean
    begin
        if (GSTR1CDNURQuery.Document_Type = GSTR1CDNURQuery.Document_Type::"Credit Memo") then
            exit(true);
    end;

    local procedure FilterDGLEDocTypeInvForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Boolean
    begin
        if (GSTR1CDNURQuery.Document_Type = GSTR1CDNURQuery.Document_Type::Invoice) and (FilterDGLESalesInvForCDNUR(GSTR1CDNURQuery)) then
            exit(true);
    end;

    local procedure FilterDGLESalesInvForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Boolean
    begin
        if (GSTR1CDNURQuery.Sales_Invoice_Type in [GSTR1CDNURQuery.Sales_Invoice_Type::"Debit Note", GSTR1CDNURQuery.Sales_Invoice_Type::Supplementary]) then
            exit(true);
    end;

    local procedure FilterDGLESalesInvForCDNR(GSTR1CDNRQuery: Query GSTR1CDNRQuery): Boolean
    begin
        if (GSTR1CDNRQuery.Sales_Invoice_Type in [GSTR1CDNRQuery.Sales_Invoice_Type::"Debit Note", GSTR1CDNRQuery.Sales_Invoice_Type::Supplementary]) then
            exit(true);
    end;

    local procedure GetStateCodeGSTRegForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Code[10]
    var
        State: Record State;
        StateGSTRegNo: Code[10];
    begin
        State.SetRange(Code, GSTR1CDNURQuery.Buyer_Seller_State_Code);
        if State.FindFirst() then
            StateGSTRegNo := State."State Code (GST Reg. No.)";
        exit(StateGSTRegNo)
    end;

    local procedure GetStateDesForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Text[50]
    var
        State: Record State;
        Description: Text[50];
    begin
        State.SetRange(Code, GSTR1CDNURQuery.Buyer_Seller_State_Code);
        if State.FindFirst() then
            Description := State.Description;
        exit(Description);
    end;

    local procedure GetLocStateCodeRegForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Code[10]
    var
        State: Record State;
        StateGSTRegNo: Code[10];
    begin
        State.SetRange(Code, GSTR1CDNURQuery.Location_State_Code);
        if State.FindFirst() then
            StateGSTRegNo := State."State Code (GST Reg. No.)";
        exit(StateGSTRegNo)
    end;

    local procedure GetLocStateDesForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Text[50]
    var
        State: Record State;
        Description: Text[50];
    begin
        State.SetRange(Code, GSTR1CDNURQuery.Location_State_Code);
        if State.FindFirst() then
            Description := State.Description;
        exit(Description);
    end;

    local procedure GetDocumentTypeTxt(GSTDocumentType: Enum "GST Document Type"): Text
    begin
        case GSTDocumentType of
            GSTDocumentType::"Credit Memo":
                exit(CLbl);
            GSTDocumentType::Invoice:
                exit(DLbl);
            GSTDocumentType::Refund:
                exit(RLbl);
        end;
    end;

    local procedure MakeExcelHeaderEXEMP()
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(DespTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(NilTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ExmpTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(NonGSTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure MakeExcelBodyEXEMP()
    begin
        MakeExcelHeaderEXEMP();
        GetInterIntraUnRegAmount();
        GetIntraInterRegAmount();
        GetExmpInterIntraRegAmount();
        GetExmpIntraInterUnRegAmount();
        GetExmpNonGSTInterRegAmt();
        GetExmpNonGSTInterUnRegAmt();

        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(InterRegTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ExpExempInterRegAmt, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(ExempInterRegAmount, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(ExempNonGSTInterRegAmt, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(IntraRegTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ExpExempIntraRegAmt, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(ExempIntraRegAmount, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(EXempNonGSTIntraRegAmt, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(InterUnRegTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ExpExempInterUnRegAmt, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(ExempCustInterUnRegAmt, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(ExempNonGSTInterUnRegAmt, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);

        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(IntraUnRegTxt, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(ExpExempIntraUnRegAmt, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(ExempCustIntraUnRegAmt, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(ExempNonGSTIntraUnRegAmt, false, '', false, false, false, '0.00', TempExcelBuffer."Cell Type"::Number);
    end;

    local procedure CheckPreGSTForCDNR(GSTR1CDNRQuery: Query GSTR1CDNRQuery): Boolean
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
    begin
        ReferenceInvoiceNo.Reset();
        ReferenceInvoiceNo.SetRange("Document No.", GSTR1CDNRQuery.Document_No_);
        ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType2DocumentTypeEnum(GSTR1CDNRQuery.Document_Type));
        ReferenceInvoiceNo.SetRange("Source No.", GSTR1CDNRQuery.Source_No_);
        if not ReferenceInvoiceNo.IsEmpty then
            exit(true);
    end;

    local procedure CheckPreGSTForCDNUR(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Boolean
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
    begin
        ReferenceInvoiceNo.Reset();
        ReferenceInvoiceNo.SetRange("Document No.", GSTR1CDNURQuery.Document_No_);
        ReferenceInvoiceNo.SetRange("Document Type", GSTDocumentType2DocumentTypeEnum(GSTR1CDNURQuery.Document_Type));
        ReferenceInvoiceNo.SetRange("Source No.", GSTR1CDNURQuery.Source_No_);
        if not ReferenceInvoiceNo.IsEmpty then
            exit(true);
    end;

    local procedure GetURType(GSTR1CDNURQuery: Query GSTR1CDNURQuery): Text
    begin
        case GSTR1CDNURQuery.GST_Customer_Type of
            GSTR1CDNURQuery.GST_Customer_Type::Unregistered:
                exit(B2CLTxt);
            GSTR1CDNURQuery.GST_Customer_Type::"SEZ Development",
            GSTR1CDNURQuery.GST_Customer_Type::"SEZ Unit",
            GSTR1CDNURQuery.GST_Customer_Type::Export,
            GSTR1CDNURQuery.GST_Customer_Type::"Deemed Export":
                begin
                    if GSTR1CDNURQuery.GST_Without_Payment_of_Duty then
                        exit(UpperCase(EXPWOPayTxt));
                    exit(UpperCase(EXPWPayTxt));
                end;
        end;
    end;

    local procedure GetIntraInterRegAmount()
    var
        GSTR1ExpExemp: Query GSTR1ExpExemp;
    begin
        GSTR1ExpExemp.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ExpExemp.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ExpExemp.SetRange(GST_Without_Payment_of_Duty, false);
        GSTR1ExpExemp.SetRange(GST_Exempted_Goods, false);
        GSTR1ExpExemp.SetFilter(Document_Type, '%1|%2',
            "GST Document Type"::Invoice,
            "GST Document Type"::"Credit Memo");
        GSTR1ExpExemp.SetFilter(GST_Customer_Type, '%1|%2|%3|%4',
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit",
            "GST Customer Type"::Registered);
        GSTR1ExpExemp.SetFilter(GST__, '=%1', 0);
        GSTR1ExpExemp.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Intrastate);
        GSTR1ExpExemp.Open();
        while GSTR1ExpExemp.Read() do
            ExpExempIntraRegAmt += Abs(GSTR1ExpExemp.GST_Base_Amount / 2);

        GSTR1ExpExemp.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Interstate);
        GSTR1ExpExemp.Open();
        while GSTR1ExpExemp.Read() do
            ExpExempInterRegAmt += Abs(GSTR1ExpExemp.GST_Base_Amount);
    end;

    local procedure GetInterIntraUnRegAmount()
    var
        GSTR1ExpExemp: Query GSTR1ExpExemp;
    begin
        GSTR1ExpExemp.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1ExpExemp.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1ExpExemp.SetRange(GSTR1ExpExemp.GST_Exempted_Goods, false);
        GSTR1ExpExemp.SetFilter(GSTR1ExpExemp.Document_Type, '%1|%2',
            "GST Document Type"::Invoice,
            "GST Document Type"::"Credit Memo");
        GSTR1ExpExemp.SetFilter(GSTR1ExpExemp.GST_Customer_Type, '%1|%2',
            "GST Customer Type"::Unregistered,
            "GST Customer Type"::Export);
        GSTR1ExpExemp.SetFilter(GSTR1ExpExemp.GST__, '=%1', 0);
        GSTR1ExpExemp.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Interstate);
        GSTR1ExpExemp.Open();
        while GSTR1ExpExemp.Read() do
            ExpExempInterUnRegAmt += Abs(GSTR1ExpExemp.GST_Base_Amount);

        GSTR1ExpExemp.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Intrastate);
        GSTR1ExpExemp.Open();
        while GSTR1ExpExemp.Read() do
            ExpExempIntraUnRegAmt += Abs(GSTR1ExpExemp.GST_Base_Amount / 2);
    end;

    local procedure GetExmpInterIntraRegAmount()
    var
        GSTR1EXEMPQuery: Query GSTR1EXEMPQuery;
    begin
        GSTR1EXEMPQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1EXEMPQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1EXEMPQuery.SetRange(GST_Exempted_Goods, true);
        GSTR1EXEMPQuery.SetFilter(Document_Type, '%1|%2',
            "GST Document Type"::Invoice,
            "GST Document Type"::"Credit Memo");
        GSTR1EXEMPQuery.SetFilter(GST_Customer_Type, '%1|%2|%3|%4',
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit",
            "GST Customer Type"::Registered);
        GSTR1EXEMPQuery.SetFilter(GST__, '=%1', 0);
        GSTR1EXEMPQuery.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Interstate);
        GSTR1EXEMPQuery.Open();
        while GSTR1EXEMPQuery.Read() do
            ExempInterRegAmount += Abs(GSTR1EXEMPQuery.GST_Base_Amount);

        GSTR1EXEMPQuery.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Intrastate);
        GSTR1EXEMPQuery.Open();
        if GSTR1EXEMPQuery.Read() then
            ExempIntraRegAmount += Abs(GSTR1EXEMPQuery.GST_Base_Amount / 2);
    end;

    local procedure GetExmpNonGSTInterRegAmt()
    var
        GSTR1NonGSTExemp: Query GSTR1NonGSTExemp;
    begin
        GSTR1NonGSTExemp.SetRange(Location_GST_Reg__No_, LocationGSTIN);
        GSTR1NonGSTExemp.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1NonGSTExemp.SetFilter(GST_Customer_Type, '%1|%2|%3|%4',
            "GST Customer Type"::"Deemed Export",
            "GST Customer Type"::"SEZ Development",
            "GST Customer Type"::"SEZ Unit",
            "GST Customer Type"::Registered);
        GSTR1NonGSTExemp.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Interstate);
        GSTR1NonGSTExemp.Open();
        while GSTR1NonGSTExemp.Read() do
            ExempNonGSTInterRegAmt += Abs(GSTR1NonGSTExemp.Amount);

        GSTR1NonGSTExemp.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Intrastate);
        GSTR1NonGSTExemp.Open();
        while GSTR1NonGSTExemp.Read() do
            ExempNonGSTIntraRegAmt += Abs(GSTR1NonGSTExemp.Amount);
    end;

    local procedure GetExmpNonGSTInterUnRegAmt()
    var
        GSTR1NonGSTExemp: Query GSTR1NonGSTExemp;
    begin
        GSTR1NonGSTExemp.SetRange(Location_GST_Reg__No_, LocationGSTIN);
        GSTR1NonGSTExemp.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1NonGSTExemp.SetFilter(GST_Customer_Type, '%1|%2',
            "GST Customer Type"::Unregistered,
            "GST Customer Type"::Export);
        GSTR1NonGSTExemp.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Interstate);
        GSTR1NonGSTExemp.Open();
        while GSTR1NonGSTExemp.Read() do
            ExempNonGSTInterUnRegAmt += Abs(GSTR1NonGSTExemp.Amount);

        GSTR1NonGSTExemp.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Intrastate);
        GSTR1NonGSTExemp.Open();
        while GSTR1NonGSTExemp.Read() do
            ExempNonGSTIntraUnRegAmt += Abs(GSTR1NonGSTExemp.Amount);
    end;

    local procedure GetExmpIntraInterUnRegAmount()
    var
        GSTR1EXEMPQuery: Query GSTR1EXEMPQuery;
    begin
        GSTR1EXEMPQuery.SetRange(Location__Reg__No_, LocationGSTIN);
        GSTR1EXEMPQuery.SetRange(Posting_Date, StartDate, EndDate);
        GSTR1EXEMPQuery.SetRange(GST_Exempted_Goods, true);
        GSTR1EXEMPQuery.SetFilter(Document_Type, '%1|%2',
            "GST Document Type"::Invoice,
            "GST Document Type"::"Credit Memo");
        GSTR1EXEMPQuery.SetFilter(GST_Customer_Type, '%1|%2',
            "GST Customer Type"::Unregistered,
            "GST Customer Type"::Export);
        GSTR1EXEMPQuery.SetFilter(GST__, '=%1', 0);
        GSTR1EXEMPQuery.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Intrastate);
        GSTR1EXEMPQuery.Open();
        if GSTR1EXEMPQuery.Read() then
            ExempCustIntraUnRegAmt += Abs(GSTR1EXEMPQuery.GST_Base_Amount / 2);

        GSTR1EXEMPQuery.SetFilter(GST_Jurisdiction_Type, '%1', "GST Jurisdiction Type"::Interstate);
        GSTR1EXEMPQuery.Open();
        if GSTR1EXEMPQuery.Read() then
            ExempCustInterUnRegAmt += Abs(GSTR1EXEMPQuery.GST_Base_Amount);
    end;

    local procedure GetInvoiceType(GSTR1B2BQuery: Query GSTR1B2BQuery): Text[50]
    begin
        case GSTR1B2BQuery.GST_Customer_Type of
            GSTR1B2BQuery.GST_Customer_Type::Registered:
                exit(RegularTxt);
            GSTR1B2BQuery.GST_Customer_Type::"SEZ Development", GSTR1B2BQuery.GST_Customer_Type::"SEZ Unit":
                begin
                    if GSTR1B2BQuery.GST_Without_Payment_of_Duty then
                        exit(SEZWOPayTxt);
                    exit(SEZWPayTxt);
                end;
            GSTR1B2BQuery.GST_Customer_Type::"Deemed Export":
                exit(DeemedExportTxt);
        end;
    end;

    local procedure GetInvoiceValue(DocumentNo: Code[20]; DocumentType: Enum "GST Document Type"): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", GSTDocumentType2GenJnlDocumentType(DocumentType));
        CustLedgerEntry.SetRange("Document No.", DocumentNo);
        if CustLedgerEntry.FindFirst() then
            CustLedgerEntry.CalcFields("Amount (LCY)");
        exit(Abs(CustLedgerEntry."Amount (LCY)"));
    end;

    local procedure GSTDocumentType2GenJnlDocumentType(GSTDocumentType: Enum "GST Document Type"): Enum "Gen. Journal Document Type"
    begin
        case GSTDocumentType of
            GSTDocumentType::" ":
                exit("Gen. Journal Document Type"::" ");
            GSTDocumentType::Payment:
                exit("Gen. Journal Document Type"::Payment);
            GSTDocumentType::Invoice:
                exit("Gen. Journal Document Type"::Invoice);
            GSTDocumentType::"Credit Memo":
                exit("Gen. Journal Document Type"::"Credit Memo");
            GSTDocumentType::Refund:
                exit("Gen. Journal Document Type"::Refund);
        end;
    end;

    local procedure GetDocumentDate(DocumentNo: Code[20]; DocumentType: Enum "GST Document Type"): Date
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", GSTDocumentType2GenJnlDocumentType(DocumentType));
        CustLedgerEntry.SetRange("Document No.", DocumentNo);
        if CustLedgerEntry.FindFirst() then
            exit(CustLedgerEntry."Document Date");
    end;

    local procedure GetInvoiceValueFinCharge(DocumentNo: Code[20]): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Finance Charge Memo");
        CustLedgerEntry.SetRange("Document No.", DocumentNo);
        if CustLedgerEntry.FindFirst() then
            CustLedgerEntry.CalcFields("Amount (LCY)");
        exit(Abs(CustLedgerEntry."Amount (LCY)"));
    end;

    local procedure CreateandOpenExcel(FileFormatTxt: Text[250])
    begin
        TempExcelBuffer.CreateNewBook(FileFormatTxt);
        TempExcelBuffer.WriteSheet(FileFormatTxt, CompanyName(), UserId());
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.OpenExcel();
    end;
}

