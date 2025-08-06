namespace Microsoft.SubscriptionBilling;

using System.Utilities;

page 8006 "Contract Renewal Selection"
{
    Caption = 'Select Subscription Contract Lines for Renewal';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Cust. Sub. Contract Line";
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
#pragma warning disable AA0219                    
                    ToolTip = 'Selecting this Option will also select and add the related Vendor Subscription Contract Lines.';
#pragma warning restore AA0219
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
                    field("Service Start Date"; TempServiceCommitment."Subscription Line Start Date")
                    {
                        Editable = false;
                        Caption = 'Subscription Line Start Date';
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the date from which the Subscription Line is valid and will be invoiced.';
                    }
                    field("Service End Date"; TempServiceCommitment."Subscription Line End Date")
                    {
                        Editable = false;
                        Caption = 'Subscription Line End Date';
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the date up to which the Subscription Line is valid.';
                    }
                    field(RenewalTermCtrl; RenewalTerm)
                    {
                        Caption = 'Renewal Term';
                        Enabled = RenewalTermEnabled;
                        ShowMandatory = true;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies a date formula by which the Contract Line is renewed and the end of the Contract Line is extended. It is automatically preset with the initial term of the Subscription Line and can be changed manually.';

                        trigger OnValidate()
                        begin
                            Rec.TestField("Subscription Header No.");
                            Rec.TestField("Subscription Line Entry No.");

                            TempServiceCommitment."Renewal Term" := RenewalTerm;
                            TempServiceCommitment.Modify(false);
                            OnValidateRenewalTermOnBeforeCurrPageUpdate(Rec, TempServiceCommitment, RenewalTerm);
                            CurrPage.Update(false);
                        end;
                    }
                    field("Service Object No."; Rec."Subscription Header No.")
                    {
                        Editable = false;
                        Visible = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the number of the Subscription.';

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
                        ToolTip = 'Specifies the Serial No. assigned to the Subscription.';
                    }
                    field("Service Object Description"; Rec."Subscription Description")
                    {
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies a description of the Subscription.';

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
                        ToolTip = 'Specifies the reference by which the customer identifies the Subscription.';
                    }
                    field("Service Commitment Description"; Rec."Subscription Line Description")
                    {
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the description of the Subscription Line.';
                    }
                    field("Service Object Quantity"; Rec."Service Object Quantity")
                    {
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the number of units of Subscription.';

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
                        ToolTip = 'Specifies the price of the Subscription Line with quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                        Visible = false;
                    }
                    field("Discount %"; TempServiceCommitment."Discount %")
                    {
                        Caption = 'Discount %';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the percent of the discount for the Subscription Line.';
                        BlankZero = true;
                        Visible = false;
                    }
                    field("Discount Amount"; TempServiceCommitment."Discount Amount")
                    {
                        Caption = 'Discount Amount';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the amount of the discount for the Subscription Line.';
                        BlankZero = true;
                        Visible = false;
                    }
                    field("Service Amount"; TempServiceCommitment.Amount)
                    {
                        Caption = 'Amount';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the amount for the Subscription Line including discount.';
                        BlankZero = true;
                    }
                    field("Price (LCY)"; TempServiceCommitment."Price (LCY)")
                    {
                        Caption = 'Price (LCY)';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the price of the Subscription Line in client currency related to quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                        Visible = false;
                        BlankZero = true;
                    }
                    field("Discount Amount (LCY)"; TempServiceCommitment."Discount Amount (LCY)")
                    {
                        Caption = 'Discount Amount (LCY)';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the discount amount in client currency that is granted on the Subscription Line.';
                        Visible = false;
                        BlankZero = true;
                    }
                    field("Service Amount (LCY)"; TempServiceCommitment."Amount (LCY)")
                    {
                        Caption = 'Amount (LCY)';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the amount in client currency for the Subscription Line including discount.';
                        Visible = false;
                        BlankZero = true;
                    }
                    field("Currency Code"; TempServiceCommitment."Currency Code")
                    {
                        Caption = 'Currency Code';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the currency of amounts in the Subscription Line.';
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
                        ToolTip = 'Specifies the percent at which the price of the Subscription Line will be calculated. 100% means that the price corresponds to the Base Price.';
                        BlankZero = true;
                    }
                    field("Term Until"; TempServiceCommitment."Term Until")
                    {
                        Caption = 'Term Until';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies the earliest regular date for the end of the Subscription Line, taking into account the initial term, extension term and a notice period. An initial term of 24 months results in a fixed term of 2 years. An extension period of 12 months postpones this date by 12 months.';
                    }
                    field("Initial Term"; TempServiceCommitment."Initial Term")
                    {
                        Caption = 'Initial Term';
                        Editable = false;
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies a date formula for calculating the minimum term of the Subscription Line. If the minimum term is filled and no extension term is entered, the end of Subscription Line is automatically set to the end of the initial term.';
                        Visible = false;
                    }
                    field("Planned Serv. Comm. exists"; Rec."Planned Sub. Line exists")
                    {
                        StyleExpr = LineFormatStyleExpression;
                        ToolTip = 'Specifies if a planned Renewal exists for the Subscription Line.';
                    }
                    field(LineCheckTextCtrl; LineCheckText)
                    {
                        Caption = 'Line verification';
                        Editable = false;
                        Style = StandardAccent;
                        StyleExpr = true;
                        ToolTip = 'Specifies the result of a preliminary check to see if the line is valid for a Contract Renewal.';
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        ContractRenewalMgt: Codeunit "Sub. Contract Renewal Mgt.";
    begin
        InitTempServiceCommitment();
        if Rec.FindFirst() then
            ContractRenewalMgt.NotifyIfLinesNotShown(Rec);
    end;

    trigger OnAfterGetRecord()
    begin
        InitializePageVariables();
        Rec.LoadServiceCommitmentForContractLine(TempServiceCommitment);

        LineCheckText := '';
        if not CheckContractLine(Rec) then begin
            LineCheckText := CopyStr(GetLastErrorText(), 1, MaxStrLen(LineCheckText));
            LineFormatStyleExpression := 'Attention';
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ContractRenewalMgt: Codeunit "Sub. Contract Renewal Mgt.";
        DataIncompleteCloseAnywayQst: Label 'At least one check failed. Do you want to close the page and abort the process?\\The following error was found:\%1', Comment = '%1=Error Text';
        ErrorDuringProcessingMsg: Label 'The following  error occured while processing:\\%1', Comment = '%1=Error Text';
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

    procedure SelectLinesWithRenewalTerm(var CustomerContractLine: Record "Cust. Sub. Contract Line")
    begin
        CustomerContractLine.Reset();
        CustomerContractLine.Copy(Rec);
        if CustomerContractLine.FindSet() then
            repeat
                CustomerContractLine.Mark(ServiceHasRenewalTerm(CustomerContractLine));
            until CustomerContractLine.Next() = 0;
        CustomerContractLine.MarkedOnly(true);
    end;

    local procedure ServiceHasRenewalTerm(var CustomerContractLine: Record "Cust. Sub. Contract Line"): Boolean
    var
        ServiceCommitment: Record "Subscription Line";
        TempServiceCommitment2: Record "Subscription Line" temporary;
        EmptyDateFormula: DateFormula;
    begin
        CustomerContractLine.TestField("Subscription Header No.");
        CustomerContractLine.TestField("Subscription Line Entry No.");

        TempServiceCommitment2 := TempServiceCommitment;
        if TempServiceCommitment.Get(CustomerContractLine."Subscription Line Entry No.") then begin
            ServiceCommitment := TempServiceCommitment;
            TempServiceCommitment := TempServiceCommitment2;
        end else
            ServiceCommitment.Get(CustomerContractLine."Subscription Line Entry No.");
        exit(ServiceCommitment."Renewal Term" <> EmptyDateFormula);
    end;


    local procedure InitializePageVariables()
    begin
        if not TempServiceCommitment.Get(Rec."Subscription Line Entry No.") then
            Clear(TempServiceCommitment);
        RenewalTerm := TempServiceCommitment."Renewal Term";
        RenewalTermEnabled := TempServiceCommitment."Subscription Header No." <> '';
        if not ServiceObject.Get(Rec."Subscription Header No.") then
            Clear(ServiceObject);
    end;

    local procedure AddVendorServicesToBuffer()
    var
        ServiceCommitmentVend: Record "Subscription Line";
        ContractRenewalMgt: Codeunit "Sub. Contract Renewal Mgt.";
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
    local procedure CheckContractLine(var CustomerContractLine: Record "Cust. Sub. Contract Line")
    var
        SavedServiceCommitment: Record "Subscription Line";
        ServiceCommitment: Record "Subscription Line";
        ContractRenewalMgt: Codeunit "Sub. Contract Renewal Mgt.";
        EmptyDateFormula: DateFormula;
        ContractRenewalDocumentAlreadyExistsErr: Label 'A Sales document already exists for %1 %2, %3 %4.', Comment = '%1=Table Caption, %2=Subscription Header No., %3=Field Caption, %4=Line No.';
        ContractRenewalLineAlreadyExistsErr: Label 'A Contract Renewal Line already exists for %1 %2, %3 %4.', Comment = '%1=Table Caption, %2=Subscription Header No., %3=Field Caption, %4=Line No.';
    begin
        if CustomerContractLine.IsCommentLine() then
            exit;
        CustomerContractLine.TestField("Subscription Header No.");
        CustomerContractLine.TestField("Subscription Line Entry No.");

        // Check against Temp. Subscription Line since it might be changed
        if TempServiceCommitment."Entry No." <> CustomerContractLine."Subscription Line Entry No." then begin
            // find the temp. record and reset the position afterwards
            SavedServiceCommitment := TempServiceCommitment;
            TempServiceCommitment.Get(CustomerContractLine."Subscription Line Entry No.");
            ServiceCommitment := TempServiceCommitment;
            TempServiceCommitment := SavedServiceCommitment;
        end else
            ServiceCommitment := TempServiceCommitment; // not yet buffered
        if ServiceCommitment."Renewal Term" = EmptyDateFormula then
            exit;
        ServiceCommitment.TestField("Subscription Line End Date");

        CustomerContractLine.CalcFields("Planned Sub. Line exists");
        CustomerContractLine.TestField("Planned Sub. Line exists", false);
        if ContractRenewalLineExists(CustomerContractLine) then
            Error(ContractRenewalLineAlreadyExistsErr, CustomerContractLine.TableCaption, CustomerContractLine."Subscription Header No.",
                                                       CustomerContractLine.FieldCaption("Line No."), CustomerContractLine."Line No.");

        if ContractRenewalMgt.ExistsInSalesOrderOrSalesQuote(Enum::"Service Partner"::Customer, CustomerContractLine."Subscription Contract No.", CustomerContractLine."Line No.") then
            Error(ContractRenewalDocumentAlreadyExistsErr, CustomerContractLine.TableCaption, CustomerContractLine."Subscription Header No.",
                                                           CustomerContractLine.FieldCaption("Line No."), CustomerContractLine."Line No.");
        OnAfterCheckContractLine(CustomerContractLine);
    end;

    local procedure ContractRenewalLineExists(var CustomerContractLine: Record "Cust. Sub. Contract Line"): Boolean
    var
        ContractRenewalLine: Record "Sub. Contract Renewal Line";
    begin
        ContractRenewalLine.Reset();
        ContractRenewalLine.SetCurrentKey("Linked to Sub. Contract No.", "Linked to Sub. Contr. Line No.");
        ContractRenewalLine.SetRange("Linked to Sub. Contract No.", CustomerContractLine."Subscription Contract No.");
        ContractRenewalLine.SetRange("Linked to Sub. Contr. Line No.", CustomerContractLine."Line No.");
        exit(not ContractRenewalLine.IsEmpty());
    end;

    procedure GetSalesQuoteCreated(): Boolean
    begin
        exit(SalesQuoteCreated);
    end;

    local procedure TransferChangedValuesFromBufferToServiceCommitment()
    var
        ServiceCommitment: Record "Subscription Line";
        ServiceCommitmentVend: Record "Subscription Line";
        ContractRenewalMgt: Codeunit "Sub. Contract Renewal Mgt.";
    begin
        TempServiceCommitment.Reset();
        if TempServiceCommitment.FindSet() then
            repeat
                TempServiceCommitment.TestField("Subscription Header No.");
                TempServiceCommitment.TestField("Entry No.");
                ServiceCommitment.Get(TempServiceCommitment."Entry No.");
                if ServiceCommitment."Renewal Term" <> TempServiceCommitment."Renewal Term" then begin
                    ServiceCommitment.Validate("Renewal Term", TempServiceCommitment."Renewal Term");
                    ServiceCommitment.Modify(true);
                end;

                // Transfer Renewal term from Customer-Subscription to Vendor-Subscription
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
                OnTransferChangedValuesFromBufferToSubscriptionLine(ServiceCommitment, TempServiceCommitment);
            until TempServiceCommitment.Next() = 0;
    end;

    local procedure GetAddVendorServicesCaption(): Text
    var
        AddVendorContractLinesLbl: Label 'Add Vendor Subscription Contract Lines (%1)', Comment = '%1=Number of Vendor Subscription Contract Lines';
    begin
        exit(StrSubstNo(AddVendorContractLinesLbl, TempServiceCommitmentVend.Count()))
    end;

    local procedure InitTempServiceCommitment()
    var
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
    begin
        TempServiceCommitment.Reset();
        if not TempServiceCommitment.IsEmpty() then
            TempServiceCommitment.DeleteAll(false);
        CustomerContractLine.Copy(Rec);
        if CustomerContractLine.FindSet() then
            repeat
                if not TempServiceCommitment.Get(CustomerContractLine."Subscription Line Entry No.") then
                    if ServiceCommitment.Get(CustomerContractLine."Subscription Line Entry No.") then begin
                        TempServiceCommitment := ServiceCommitment;
                        TempServiceCommitment.Insert(false);
                        AddVendorServicesToBuffer();
                    end;
            until CustomerContractLine.Next() = 0;
        OnAfterInitTempSubscriptionLine(TempServiceCommitment);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTransferChangedValuesFromBufferToSubscriptionLine(var SubscriptionLine: Record "Subscription Line"; var SubscriptionLineBuffer: Record "Subscription Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitTempSubscriptionLine(var TempSubscriptionLine: Record "Subscription Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckContractLine(var CustSubContractLine: Record "Cust. Sub. Contract Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateRenewalTermOnBeforeCurrPageUpdate(var CustSubContractLine: Record "Cust. Sub. Contract Line"; var TempSubscriptionLine: Record "Subscription Line" temporary; RenewalTerm: DateFormula)
    begin
    end;

    var
        ServiceObject: Record "Subscription Header";
        ConfirmManagement: Codeunit "Confirm Management";
        RenewalTerm: DateFormula;
        AddVendorServices: Boolean;
        RenewalTermEnabled: Boolean;
        SalesQuoteCreated: Boolean;

    protected var
        TempServiceCommitment: Record "Subscription Line" temporary;
        TempServiceCommitmentVend: Record "Subscription Line" temporary;
        LineFormatStyleExpression: Text;
        LineCheckText: Text[250];
}