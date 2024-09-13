namespace Microsoft.SubscriptionBilling;

using System.Utilities;

page 8006 "Contract Renewal Selection"
{
    Caption = 'Select Contract Lines for Renewal';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Customer Contract Line";
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Options)
            {
                Caption = 'Options';

                field(AddVendorServicesCtrl; AddVendorServices)
                {
                    CaptionClass = GetAddVendorServicesCaption();
                    ToolTip = 'Selecting this Option will also select and add the related Vendor Contract Lines.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
            }

            group(Lines)
            {
                Caption = 'Contract Lines';

                repeater(ContractLines)
                {
                    field("Contract Line Type"; Rec."Contract Line Type")
                    {
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the contract line type.';

                        trigger OnAssistEdit()
                        begin
                            // blank trigger to prevent auto-closing on click when page is called in Lookup-mode
                        end;

                    }
                    field("Service Start Date"; TempServiceCommitment."Service Start Date")
                    {
                        Editable = false;
                        Caption = 'Service Start Date';
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the date from which the service is valid and will be invoiced.';
                    }
                    field("Service End Date"; TempServiceCommitment."Service End Date")
                    {
                        Editable = false;
                        Caption = 'Service End Date';
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the date up to which the service is valid.';
                    }
                    field(RenewalTermCtrl; RenewalTerm)
                    {
                        Caption = 'Renewal Term';
                        Enabled = RenewalTermEnabled;
                        ShowMandatory = true;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies a date formula by which the Contract Line is renewed and the end of the Contract Line is extended. It is automatically preset with the initial term of the service and can be changed manually.';

                        trigger OnValidate()
                        begin
                            Rec.TestField("Service Object No.");
                            Rec.TestField("Service Commitment Entry No.");

                            TempServiceCommitment."Renewal Term" := RenewalTerm;
                            TempServiceCommitment.Modify(false);
                            CurrPage.Update(false);
                        end;
                    }
                    field("Service Object No."; Rec."Service Object No.")
                    {
                        Editable = false;
                        Visible = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the number of the service object no.';

                        trigger OnAssistEdit()
                        begin
                            Rec.OpenServiceObjectCard();
                        end;
                    }
                    field("Service Object Serial No."; ServiceObject."Serial No.")
                    {
                        Caption = 'Serial No.';
                        Editable = false;
                        Visible = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the Serial No. assigned to the service object.';
                    }
                    field("Service Object Description"; Rec."Service Object Description")
                    {
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies a description of the service object.';

                        trigger OnAssistEdit()
                        begin
                            Rec.OpenServiceObjectCard();
                        end;
                    }
                    field("Service Object Customer Reference"; ServiceObject."Customer Reference")
                    {
                        Caption = 'Customer Reference';
                        Editable = false;
                        Visible = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the reference by which the customer identifies the service object.';
                    }
                    field("Service Commitment Description"; Rec."Service Commitment Description")
                    {
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the description of the service.';
                    }
                    field("Service Object Quantity"; Rec."Service Obj. Quantity Decimal")
                    {
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Number of units of service object.';

                        trigger OnDrillDown()
                        begin
                            Rec.OpenServiceObjectCard();
                        end;
                    }
                    field(Price; TempServiceCommitment.Price)
                    {
                        BlankZero = true;
                        Caption = 'Price';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the price of the service with quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                        Visible = false;
                    }
                    field("Discount %"; TempServiceCommitment."Discount %")
                    {
                        Caption = 'Discount %';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the percent of the discount for the service.';
                        BlankZero = true;
                        Visible = false;
                    }
                    field("Discount Amount"; TempServiceCommitment."Discount Amount")
                    {
                        Caption = 'Discount Amount';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the amount of the discount for the service.';
                        BlankZero = true;
                        Visible = false;
                    }
                    field("Service Amount"; TempServiceCommitment."Service Amount")
                    {
                        Caption = 'Service Amount';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the amount for the service including discount.';
                        BlankZero = true;
                    }
                    field("Price (LCY)"; TempServiceCommitment."Price (LCY)")
                    {
                        Caption = 'Price (LCY)';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the price of the service in client currency related to quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                        Visible = false;
                        BlankZero = true;
                    }
                    field("Discount Amount (LCY)"; TempServiceCommitment."Discount Amount (LCY)")
                    {
                        Caption = 'Discount Amount (LCY)';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the discount amount in client currency that is granted on the service.';
                        Visible = false;
                        BlankZero = true;
                    }
                    field("Service Amount (LCY)"; TempServiceCommitment."Service Amount (LCY)")
                    {
                        Caption = 'Service Amount (LCY)';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the amount in client currency for the service including discount.';
                        Visible = false;
                        BlankZero = true;
                    }
                    field("Currency Code"; TempServiceCommitment."Currency Code")
                    {
                        Caption = 'Currency Code';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the currency of amounts in the service.';
                        Visible = false;
                    }
                    field("Next Billing Date"; TempServiceCommitment."Next Billing Date")
                    {
                        Caption = 'Next Billing Date';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the date of the next billing possible.';
                    }
                    field("Calculation Base Amount"; TempServiceCommitment."Calculation Base Amount")
                    {
                        Caption = 'Calculation Base Amount';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the base amount from which the price will be calculated.';
                        BlankZero = true;
                    }
                    field("Calculation Base %"; TempServiceCommitment."Calculation Base %")
                    {
                        Caption = 'Calculation Base %';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the percent at which the price of the service will be calculated. 100% means that the price corresponds to the Base Price.';
                        BlankZero = true;
                    }
                    field("Term Until"; TempServiceCommitment."Term Until")
                    {
                        Caption = 'Term Until';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the earliest regular date for the end of the service, taking into account the initial term, extension term and a notice period. An initial term of 24 months results in a fixed term of 2 years. An extension period of 12 months postpones this date by 12 months.';
                    }
                    field("Initial Term"; TempServiceCommitment."Initial Term")
                    {
                        Caption = 'Initial Term';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies a date formula for calculating the minimum term of the service commitment. If the minimum term is filled and no extension term is entered, the end of service commitment is automatically set to the end of the initial term.';
                        Visible = false;
                    }
                    field("Planned Serv. Comm. exists"; Rec."Planned Serv. Comm. exists")
                    {
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies if a planned Renewal exists for the service commitment.';
                    }
                    field(LineCheckTextCtrl; LineCheckText)
                    {
                        Caption = 'Line verification';
                        Editable = false;
                        Style = StandardAccent;
                        StyleExpr = true;
                        ToolTip = 'Displays the result of a preliminary check to see if the line is valid for a Contract Renewal.';
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
    begin
        InitTempServiceCommitment();
        if Rec.FindFirst() then
            ContractRenewalMgt.NotifyIfLinesNotShown(Rec);
    end;

    trigger OnAfterGetRecord()
    begin
        InitializePageVariables();
        Rec.LoadAmountsForContractLine(TempServiceCommitment.Price, TempServiceCommitment."Discount %", TempServiceCommitment."Discount Amount",
                                       TempServiceCommitment."Service Amount", TempServiceCommitment."Calculation Base Amount", TempServiceCommitment."Calculation Base %");

        LineCheckText := '';
        if not CheckContractLine(Rec) then begin
            LineCheckText := CopyStr(GetLastErrorText(), 1, MaxStrLen(LineCheckText));
            LineFormatStyleExpression := 'Attention';
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        CustomerContractLine: Record "Customer Contract Line";
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
        DataIncompleteCloseAnywayQst: Label 'At least one check failed. Do you want to close the page and abort the process?\\The following error was found:\%1';
        ErrorDuringProcessingMsg: Label 'The following  error occured while processing:\\%1';
    begin
        SalesQuoteCreated := false;
        if CloseAction = CloseAction::LookupOK then begin
            TransferChangedValuesFromBufferToServiceCommitment();
            SelectLinesWithRenewalTerm(CustomerContractLine);
            ClearLastError();
            if CustomerContractLine.FindSet() then begin
                repeat
                    if not CheckContractLine(CustomerContractLine) then
                        exit(ConfirmManagement.GetResponse(StrSubstNo(DataIncompleteCloseAnywayQst, GetLastErrorText()), false));
                until CustomerContractLine.Next() = 0;
                Commit(); // Commit before Running Codeunit conditionally
                ClearLastError();
                Clear(ContractRenewalMgt);
                ContractRenewalMgt.SetAddVendorServices(AddVendorServices);
                SalesQuoteCreated := ContractRenewalMgt.Run(CustomerContractLine);
                if not SalesQuoteCreated then
                    Message(ErrorDuringProcessingMsg, GetLastErrorText()); // Message instead of error to allow closing of the page
            end;
            exit(true);
        end;
    end;

    local procedure SelectLinesWithRenewalTerm(var CustomerContractLine: Record "Customer Contract Line")
    begin
        CustomerContractLine.Reset();
        CustomerContractLine.Copy(Rec);
        if CustomerContractLine.FindSet() then
            repeat
                CustomerContractLine.Mark(ServiceHasRenewalTerm(CustomerContractLine));
            until CustomerContractLine.Next() = 0;
        CustomerContractLine.MarkedOnly(true);
    end;

    local procedure ServiceHasRenewalTerm(var CustomerContractLine: Record "Customer Contract Line"): Boolean
    var
        ServiceCommitment: Record "Service Commitment";
        TempServiceCommitment2: Record "Service Commitment" temporary;
        EmptyDateFormula: DateFormula;
    begin
        CustomerContractLine.TestField("Service Object No.");
        CustomerContractLine.TestField("Service Commitment Entry No.");

        TempServiceCommitment2 := TempServiceCommitment;
        if TempServiceCommitment.Get(CustomerContractLine."Service Commitment Entry No.") then begin
            ServiceCommitment := TempServiceCommitment;
            TempServiceCommitment := TempServiceCommitment2;
        end else
            ServiceCommitment.Get(CustomerContractLine."Service Commitment Entry No.");
        exit(ServiceCommitment."Renewal Term" <> EmptyDateFormula);
    end;


    local procedure InitializePageVariables()
    begin
        if not TempServiceCommitment.Get(Rec."Service Commitment Entry No.") then
            Clear(TempServiceCommitment);
        RenewalTerm := TempServiceCommitment."Renewal Term";
        RenewalTermEnabled := TempServiceCommitment."Service Object No." <> '';
        if not ServiceObject.Get(Rec."Service Object No.") then
            Clear(ServiceObject);
    end;

    local procedure AddVendorServicesToBuffer()
    var
        ServiceCommitmentVend: Record "Service Commitment";
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
    begin
        ContractRenewalMgt.FilterServCommVendFromServCommCust(TempServiceCommitment, ServiceCommitmentVend);
        if ServiceCommitmentVend.FindSet() then
            repeat
                if not TempServiceCommitmentVend.Get(ServiceCommitmentVend."Entry No.") then begin
                    TempServiceCommitmentVend := ServiceCommitmentVend;
                    TempServiceCommitmentVend.Insert(false)
 ;
                end;
            until ServiceCommitmentVend.Next() = 0;
    end;

    [TryFunction]
    internal procedure CheckContractLine(var CustomerContractLine: Record "Customer Contract Line")
    var
        SavedServiceCommitment: Record "Service Commitment";
        ServiceCommitment: Record "Service Commitment";
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
        EmptyDateFormula: DateFormula;
        ContractRenewalDocumentAlreadyExistsErr: Label 'A Sales document already exists for %1 %2, %3 %4.';
        ContractRenewalLineAlreadyExistsErr: Label 'A Contract Renewal Line already exists for %1 %2, %3 %4.';
    begin
        if CustomerContractLine."Contract Line Type" <> CustomerContractLine."Contract Line Type"::"Service Commitment" then
            exit;
        CustomerContractLine.TestField("Service Object No.");
        CustomerContractLine.TestField("Service Commitment Entry No.");

        // Check against Temp. Service Commitment since it might be changed
        if TempServiceCommitment."Entry No." <> CustomerContractLine."Service Commitment Entry No." then begin
            // find the temp. record and reset the position afterwards
            SavedServiceCommitment := TempServiceCommitment;
            TempServiceCommitment.Get(CustomerContractLine."Service Commitment Entry No.");
            ServiceCommitment := TempServiceCommitment;
            TempServiceCommitment := SavedServiceCommitment;
        end else
            ServiceCommitment := TempServiceCommitment; // not yet buffered
        if ServiceCommitment."Renewal Term" = EmptyDateFormula then
            exit;
        ServiceCommitment.TestField("Service End Date");

        CustomerContractLine.CalcFields("Planned Serv. Comm. exists");
        CustomerContractLine.TestField("Planned Serv. Comm. exists", false);
        if ContractRenewalLineExists(CustomerContractLine) then
            Error(ContractRenewalLineAlreadyExistsErr, CustomerContractLine.TableCaption, CustomerContractLine."Service Object No.",
                                                       CustomerContractLine.FieldCaption("Line No."), CustomerContractLine."Line No.");

        if ContractRenewalMgt.ExistsInSalesOrderOrSalesQuote(Enum::"Service Partner"::Customer, CustomerContractLine."Contract No.", CustomerContractLine."Line No.") then
            Error(ContractRenewalDocumentAlreadyExistsErr, CustomerContractLine.TableCaption, CustomerContractLine."Service Object No.",
                                                           CustomerContractLine.FieldCaption("Line No."), CustomerContractLine."Line No.");
        OnAfterCheckContractLine(CustomerContractLine);
    end;

    local procedure ContractRenewalLineExists(var CustomerContractLine: Record "Customer Contract Line"): Boolean
    var
        ContractRenewalLine: Record "Contract Renewal Line";
    begin
        ContractRenewalLine.Reset();
        ContractRenewalLine.SetCurrentKey("Linked to Contract No.", "Linked to Contract Line No.");
        ContractRenewalLine.SetRange("Linked to Contract No.", CustomerContractLine."Contract No.");
        ContractRenewalLine.SetRange("Linked to Contract Line No.", CustomerContractLine."Line No.");
        exit(not ContractRenewalLine.IsEmpty());
    end;

    procedure GetSalesQuoteCreated(): Boolean
    begin
        exit(SalesQuoteCreated);
    end;

    local procedure TransferChangedValuesFromBufferToServiceCommitment()
    var
        ServiceCommitment: Record "Service Commitment";
        ServiceCommitmentVend: Record "Service Commitment";
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
    begin
        TempServiceCommitment.Reset();
        if TempServiceCommitment.FindSet() then
            repeat
                TempServiceCommitment.TestField("Service Object No.");
                TempServiceCommitment.TestField("Entry No.");
                ServiceCommitment.Get(TempServiceCommitment."Entry No.");
                if ServiceCommitment."Renewal Term" <> TempServiceCommitment."Renewal Term" then begin
                    ServiceCommitment.Validate("Renewal Term", TempServiceCommitment."Renewal Term");
                    ServiceCommitment.Modify(true);
                end;

                // Transfer Renewal term from Customer-Service to Vendor-Service
                if AddVendorServices then begin
                    ContractRenewalMgt.FilterServCommVendFromServCommCust(TempServiceCommitment, TempServiceCommitmentVend);
                    if TempServiceCommitmentVend.FindSet() then
                        repeat
                            ServiceCommitmentVend.Get(TempServiceCommitmentVend."Entry No.");
                            if ServiceCommitmentVend."Renewal Term" <> TempServiceCommitment."Renewal Term" then begin
                                ServiceCommitmentVend.Validate("Renewal Term", TempServiceCommitment."Renewal Term");
                                ServiceCommitmentVend.Modify(true);
                            end;
                        until TempServiceCommitmentVend.Next() = 0;
                end;
                OnTransferChangedValuesFromBufferToServiceCommitment(ServiceCommitment, TempServiceCommitment);
            until TempServiceCommitment.Next() = 0;
    end;

    local procedure GetAddVendorServicesCaption(): Text
    var
        AddVendorContractLinesLbl: Label 'Add Vendor Contract Lines (%1)';
    begin
        exit(StrSubstNo(AddVendorContractLinesLbl, TempServiceCommitmentVend.Count()))
    end;

    local procedure InitTempServiceCommitment()
    var
        CustomerContractLine: Record "Customer Contract Line";
        ServiceCommitment: Record "Service Commitment";
    begin
        TempServiceCommitment.Reset();
        if not TempServiceCommitment.IsEmpty() then
            TempServiceCommitment.DeleteAll(false);
        CustomerContractLine.Copy(Rec);
        if CustomerContractLine.FindSet() then
            repeat
                if not TempServiceCommitment.Get(CustomerContractLine."Service Commitment Entry No.") then
                    if ServiceCommitment.Get(CustomerContractLine."Service Commitment Entry No.") then begin
                        TempServiceCommitment := ServiceCommitment;
                        TempServiceCommitment.Insert(false);
                        AddVendorServicesToBuffer();
                    end;
            until CustomerContractLine.Next() = 0;
        OnAfterInitTempServiceCommitment(TempServiceCommitment);
    end;

    [InternalEvent(false, false)]
    local procedure OnTransferChangedValuesFromBufferToServiceCommitment(var ServiceCommitment: Record "Service Commitment"; var ServiceCommitmentBuffer: Record "Service Commitment" temporary)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterInitTempServiceCommitment(var TempServiceCommitment: Record "Service Commitment" temporary)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCheckContractLine(var CustomerContractLine: Record "Customer Contract Line")
    begin
    end;

    var
        ServiceObject: Record "Service Object";
        ConfirmManagement: Codeunit "Confirm Management";
        RenewalTerm: DateFormula;
        LineCheckText: Text[250];
        AddVendorServices: Boolean;
        RenewalTermEnabled: Boolean;
        SalesQuoteCreated: Boolean;

    protected var
        TempServiceCommitment: Record "Service Commitment" temporary;
        TempServiceCommitmentVend: Record "Service Commitment" temporary;
        LineFormatStyleExpression: Text;
}