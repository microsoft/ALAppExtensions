report 31270 "Compensation CZC"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/Compensation.rdl';
    Caption = 'Compensation';
    UsageCategory = None;

    dataset
    {
        dataitem(CompensationHeaderCZC; "Compensation Header CZC")
        {
            DataItemTableView = sorting("No.");
            RequestfilterFields = "No.", "Company No.";
            column(CompensationHeader_No; "No.")
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(CompensationHeader_Address; CompanyAddress)
                    {
                    }
                    column(CompensationHeader_Name; CompanyName)
                    {
                    }
                    column(CompanyInfo_RegistrationNo; CompanyInformation."Registration No.")
                    {
                    }
                    column(CompanyInfo_BankAccountNo; CompanyInformation."Bank Account No.")
                    {
                    }
                    column(CompanyInfo_Address_PostCode_City; CompanyInformation.Address + ', ' + CompanyInformation."Post Code" + '  ' + CompanyInformation.City)
                    {
                    }
                    column(CompanyInfo_Name; CompanyInformation.Name)
                    {
                    }
                    column(CompensationHeader_AgreementNo; StrSubstNo(AgreementTxt, CompensationHeaderCZC."No."))
                    {
                    }
                    column(CompensationHeader_PostingDate; StrSubstNo(ToDateTxt, Format(CompensationHeaderCZC."Posting Date", 0, 4)))
                    {
                    }
                    column(CompensationHeader_RegistrationNo; CompanyRegistrationNo)
                    {
                    }
                    column(PageLoop_OutputCounter; OutputCounter)
                    {
                    }
                    column(PageLoop_Number; Number)
                    {
                    }
                    dataitem(CustomerCompensationLineCZC; "Compensation Line CZC")
                    {
                        DataItemLink = "Compensation No." = field("No.");
                        DataItemLinkReference = CompensationHeaderCZC;
                        DataItemTableView = sorting("Compensation No.", "Line No.") where("Source Type" = const(Customer));
                        column(CustomerCompensationLine_Name; StrSubstNo(ReceivablesTxt, CompanyName))
                        {
                        }
                        column(CustomerCompensationLine_RemainingAmount; "Remaining Amount")
                        {
                        }
                        column(CustomerCompensationLine_Amount; Amount)
                        {
                        }
                        column(CustomerCompensationLine_LERemainingAmount; "Ledg. Entry Remaining Amount")
                        {
                        }
                        column(CustomerCompensationLine_LEOriginalAmount; "Ledg. Entry Original Amount")
                        {
                        }
                        column(CustomerCompensationLine_DueDate; Format(CustomerDueDate))
                        {
                        }
                        column(CustomerCompensationLine_CurrencyCode; "Currency Code")
                        {
                        }
                        column(CustomerCompensationLine_VariableSymbol; "Variable Symbol")
                        {
                        }
                        column(CustomerCompensationLine_DocumentNo; "Document No.")
                        {
                        }
                        column(CustomerCompensationLine_DocumentType; "Document Type")
                        {
                        }
                        column(CustomerCompensationLine_PostingDate; Format("Posting Date"))
                        {
                        }
                        column(CustomerCompensationLine_LineNo; "Line No.")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            CustLedgerEntry.Get("Source Entry No.");
                            CustomerDueDate := CustLedgerEntry."Due Date";

                            if "Currency Code" = '' then
                                "Currency Code" := GeneralLedgerSetup."LCY Code";

                            if "Remaining Amount" <> 0 then begin
                                TempCustomerCompensationLineCZC := CustomerCompensationLineCZC;
                                TempCustomerCompensationLineCZC.Insert();
                            end;
                        end;
                    }
                    dataitem(VendorCompensationLineCZC; "Compensation Line CZC")
                    {
                        DataItemLink = "Compensation No." = field("No.");
                        DataItemLinkReference = CompensationHeaderCZC;
                        DataItemTableView = sorting("Compensation No.", "Line No.") where("Source Type" = const(Vendor));
                        column(VendorCompensationLine_Name; StrSubstNo(PayablesTxt, CompanyName))
                        {
                        }
                        column(VendorCompensationLine_RemainingAmount; -"Remaining Amount")
                        {
                        }
                        column(VendorCompensationLine_Amount; -Amount)
                        {
                        }
                        column(VendorCompensationLine_LERemainingAmount; -"Ledg. Entry Remaining Amount")
                        {
                        }
                        column(VendorCompensationLine_LEOriginalAmount; -"Ledg. Entry Original Amount")
                        {
                        }
                        column(VendorCompensationLine_DueDate; Format(VendorDueDate))
                        {
                        }
                        column(VendorCompensationLine_CurrencyCode; "Currency Code")
                        {
                        }
                        column(VendorCompensationLine_VariableSymbol; "Variable Symbol")
                        {
                        }
                        column(VendorCompensationLine_DocumentNo; "Document No.")
                        {
                        }
                        column(VendorCompensationLine_DocumentType; "Document Type")
                        {
                        }
                        column(VendorCompensationLine_PostingDate; Format("Posting Date"))
                        {
                        }
                        column(VendorCompensationLine_LineNo; "Line No.")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            VendorLedgerEntry.Get("Source Entry No.");
                            VendorDueDate := VendorLedgerEntry."Due Date";

                            if "Currency Code" = '' then
                                "Currency Code" := GeneralLedgerSetup."LCY Code";

                            if "Remaining Amount" <> 0 then begin
                                TempVendorCompensationLineCZC := VendorCompensationLineCZC;
                                TempVendorCompensationLineCZC.Insert();
                            end;
                        end;
                    }
                    dataitem(CustomerInteger; Integer)
                    {
                        DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                        column(CustomerInteger_Name; StrSubstNo(RemainingReceivablesAndPayablesTxt, RemaningCompanyName))
                        {
                        }
                        column(CustomerInteger_VariableSymbol; StrSubstNo(AmountAfterCompensationTxt, TempCustomerCompensationLineCZC."Variable Symbol",
                                Format(Abs(TempCustomerCompensationLineCZC."Remaining Amount"), 0, '<Precision,2:2><Sign><Integer><1000Character, ><Decimals>'),
                                TempCustomerCompensationLineCZC."Currency Code"))
                        {
                        }
                        column(CustomerInteger_Number; Number)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                if not TempCustomerCompensationLineCZC.FindSet() then
                                    CurrReport.Break();
                            end else
                                if TempCustomerCompensationLineCZC.Next() = 0 then
                                    CurrReport.Break();
                        end;

                        trigger OnPreDataItem()
                        begin
                            TempCustomerCompensationLineCZC.SetRange("Source Type", TempCustomerCompensationLineCZC."Source Type"::Customer);
                            RemaningCompanyName := CompanyInformation.Name;
                        end;
                    }
                    dataitem(VendorInteger; Integer)
                    {
                        DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                        column(VendorInteger_Name; StrSubstNo(RemainingReceivablesAndPayablesTxt, RemaningCompanyName))
                        {
                        }
                        column(VendorInteger_VariableSymbol; StrSubstNo(AmountAfterCompensationTxt, TempVendorCompensationLineCZC."Variable Symbol",
                                Format(Abs(TempVendorCompensationLineCZC."Remaining Amount"), 0, '<Precision,2:2><Sign><Integer><1000Character, ><Decimals>'),
                                TempVendorCompensationLineCZC."Currency Code"))
                        {
                        }
                        column(VendorInteger_Number; Number)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                if not TempVendorCompensationLineCZC.FindSet() then
                                    CurrReport.Break();
                            end else
                                if TempVendorCompensationLineCZC.Next() = 0 then
                                    CurrReport.Break();
                        end;

                        trigger OnPreDataItem()
                        begin
                            TempVendorCompensationLineCZC.SetRange("Source Type", TempVendorCompensationLineCZC."Source Type"::Vendor);
                            RemaningCompanyName := CompanyName;
                        end;
                    }
                    dataitem(Summary; Integer)
                    {
                        DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                        MaxIteration = 1;
                        column(WORKDATE; Format(WorkDate()))
                        {
                        }
                        column(Summary_Number; Number)
                        {
                        }
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if Number > 1 then
                        OutputCounter += 1;

                    TempCustomerCompensationLineCZC.Reset();
                    TempCustomerCompensationLineCZC.DeleteAll();
                    Clear(TempCustomerCompensationLineCZC);

                    TempVendorCompensationLineCZC.Reset();
                    TempVendorCompensationLineCZC.DeleteAll();
                    Clear(TempVendorCompensationLineCZC);
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopies) + 1;
                    if NoOfLoops <= 0 then
                        NoOfLoops := 1;
                    SetRange(Number, 1, NoOfLoops);
                    OutputCounter := 1;
                end;
            }

            trigger OnAfterGetRecord()
            var
                Vendor: Record Vendor;
                Customer: Record Customer;
                Contact: Record Contact;
            begin
                Clear(CompanyName);
                Clear(CompanyAddress);
                Clear(CompanyRegistrationNo);

                CompanyName := "Company Name";
                if "Company Name 2" <> '' then
                    CompanyName := CompanyName + ' ' + "Company Name 2";

                CompanyAddress := "Company Address";
                if "Company Address 2" <> '' then
                    CompanyAddress := CompanyAddress + ' ' + "Company Address 2";
                if ("Company Post Code" <> '') or ("Company City" <> '') then
                    CompanyAddress := CompanyAddress + ', ' + "Company Post Code" + ' ' + "Company City";

                case "Company Type" of
                    "Company Type"::Vendor:
                        if Vendor.Get("Company No.") then
                            CompanyRegistrationNo := Vendor."Registration No. CZL";
                    "Company Type"::Customer:
                        if Customer.Get("Company No.") then
                            CompanyRegistrationNo := Customer."Registration No. CZL";
                    "Company Type"::Contact:
                        if Contact.Get("Company No.") then
                            CompanyRegistrationNo := Contact."Registration No. CZL";
                end;
            end;

            trigger OnPreDataItem()
            begin
                CompanyInformation.Get();
                GeneralLedgerSetup.Get();
                GeneralLedgerSetup.TestField("LCY Code");
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
                    field(NoOfCopiesCZC; NoOfCopies)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies the number of copies to print.';
                    }
                }
            }
        }
    }

    labels
    {
        ResidenceLbl = 'Residence:';
        BusinessNameLbl = 'Business Name:';
        RegistrationNoLbl = 'Reg. No.:';
        BankConnectionLbl = 'Bank connection:';
        ParagraphLbl = 'by reciprocally Compensation receibables by PAR. 1982-1991 of Civil Code No. 89/2012';
        RemainingAmountLbl = 'Remaining Amount';
        CompensationAmountLbl = 'Compensation Amount';
        LedgerEntryRemainingAmountLbl = 'Ledg. Entry Remaining Amount';
        LedgerEntryOriginalAmountLbl = 'Ledg. Entry Original Amount';
        DueDateLbl = 'Due Date';
        EnterIntoForceLbl = 'This agreement shall enter into force upon signature by both parties.';
        NameAndSignatureLbl = 'Name and Signature';
        DotsLbl = '......................................................................';
        InAndDateLbl = 'In .............................., date .................';
        SendBackLbl = 'In case you agree, send one confirmed agreement back to our address.';
        ForLbl = 'For';
        MakeDateLbl = 'Make Date';
        CurrencyCodeLbl = 'Currency Code';
        VariableSymbolLbl = 'Variable Symbol';
        DocumentNoLbl = 'Document No';
        DocumentTypeLbl = 'Document Type';
        PostingDateLbl = 'Posting Date';
    }

    var
        CompanyInformation: Record "Company Information";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempCustomerCompensationLineCZC, TempVendorCompensationLineCZC : Record "Compensation Line CZC" temporary;
        CompanyName, CompanyAddress, CompanyRegistrationNo, RemaningCompanyName : Text;
        CustomerDueDate, VendorDueDate : Date;
        NoOfCopies, NoOfLoops, OutputCounter : Integer;
        AgreementTxt: Label 'AGREEMENT %1', Comment = '%1 = Compensation No.';
        ToDateTxt: Label 'To Date %1', Comment = '%1 = Posting Date';
        ReceivablesTxt: Label 'Receivables %1', Comment = '%1 = Company Name';
        PayablesTxt: Label 'Payables %1', Comment = '%1 = Company Name';
        RemainingReceivablesAndPayablesTxt: Label 'Remaining Receivable and Payables of %1 to pay after realize Compensation.', Comment = '%1 = Company Name';
        AmountAfterCompensationTxt: Label 'for the variable symbol %1 are %2 %3 after the Compensation.', Comment = '%1 = Variable Symbol, %2 = Remaining Amount, %3 = Currency Code';
}
