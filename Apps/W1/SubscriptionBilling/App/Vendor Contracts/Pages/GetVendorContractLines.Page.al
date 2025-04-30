namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Document;

page 8095 "Get Vendor Contract Lines"
{
    Caption = 'Get Vendor Subscription Contract Lines';
    ApplicationArea = All;
    UsageCategory = None;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Worksheet;
    SourceTable = "Subscription Line";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(VendorContractFilter)
            {
                Caption = 'Filter';
                field(VendorContractNoFilter; VendorContractFilterText)
                {
                    Caption = 'Vendor Contract No.';
                    ToolTip = 'Specifies the name of the template that is used to calculate billable Subscription Lines.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupVendorContract();
                    end;

                    trigger OnValidate()
                    begin
                        LoadVendorServiceCommitments();
                    end;
                }
            }
            repeater(General)
            {
                ShowAsTree = true;
                IndentationColumn = Rec.Indent;
                TreeInitialState = ExpandAll;
                field("Contract No."; Rec."Subscription Contract No.")
                {
                    ToolTip = 'Specifies in which contract the Subscription Line will be calculated.';
                    Editable = false;
                    StyleExpr = LineStyleExpr;
                }
                field(Selected; Rec.Selected)
                {
                    ToolTip = 'Specifies that the Subscription Line is to be called up in the purchase invoice.';
                    StyleExpr = LineStyleExpr;
                    Enabled = IsContractLine;
                    trigger OnValidate()
                    begin
                        Rec.TestField(Indent, 1);
                        if not Rec.Selected then
                            ResetServiceCommitment();

                        if Rec.Selected and (RunningMode = RunningMode::"Assign Purchase Line to Contract Line") then begin
                            UpdateWithVendorInvoiceAmount();
                            CurrPage.SaveRecord();
                            ResetPreviouslySelectedServiceCommitment();
                        end;
                        CurrPage.Update(false);
                    end;
                }
                field("Your Reference"; VendorContract."Your Reference")
                {
                    ToolTip = 'Specifies the vendor''s reference.';
                    Editable = false;
                    StyleExpr = LineStyleExpr;
                }
                field("Service Object Description"; Rec."Subscription Description")
                {
                    ToolTip = 'Specifies a description of the Subscription.';
                    Editable = false;
                    StyleExpr = LineStyleExpr;
                }
                field("Service Commitment Description"; Rec."Description")
                {
                    ToolTip = 'Specifies the description of the Subscription Line.';
                    Editable = false;
                    StyleExpr = LineStyleExpr;
                }
                field("Next Billing Date"; Rec."Next Billing Date")
                {
                    Caption = 'Next Billing Date';
                    ToolTip = 'Specifies the date of the next billing possible.';
                    Editable = false;
                    StyleExpr = LineStyleExpr;
                }
                field("Billing to Date"; BillingToDate)
                {
                    Caption = 'Billing to Date';
                    ToolTip = 'Specifies the optional date up to which the billable Subscription Lines should be charged.';
                    StyleExpr = LineStyleExpr;
                    Editable = IsContractLine;
                    trigger OnValidate()
                    begin
                        Rec.Selected := true;
                        Evaluate(Rec."Billing Base Period", Format(BillingToDate - Rec."Next Billing Date" + 1) + 'D');
                        Rec."Billing Rhythm" := Rec."Billing Base Period";
                    end;
                }
                field("Vendor Invoice Amount"; VendorInvoiceAmount)
                {
                    Caption = 'Vendor Invoice Amount ';
                    ToolTip = ' Specifies the amount to be charged.';
                    StyleExpr = LineStyleExpr;
                    Editable = IsContractLine and VendorInvoiceAmountEditable;

                    trigger OnValidate()
                    begin
                        Rec.Selected := true;
                        if RunningMode = RunningMode::"Create Purch. Line from Contract Line" then
                            UpdateWithVendorInvoiceAmount();
                    end;
                }
                field("Service Object Quantity"; Rec.Quantity)
                {
                    ToolTip = 'Specifies the number of units of Subscription.';
                    Editable = false;
                    StyleExpr = LineStyleExpr;
                }
                field(Price; Rec.Price)
                {
                    Caption = 'Price';
                    ToolTip = 'Specifies the price of the Subscription Line with quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                    Editable = false;
                    BlankZero = true;
                    StyleExpr = LineStyleExpr;
                }
                field("Service Amount"; Rec.Amount)
                {
                    ToolTip = 'Specifies the amount for the Subscription Line including discount.';
                    Editable = false;
                    StyleExpr = LineStyleExpr;
                }
                field("Calculation Base Amount"; Rec."Calculation Base Amount")
                {
                    ToolTip = 'Specifies the base amount from which the price will be calculated.';
                    Editable = false;
                    StyleExpr = LineStyleExpr;
                }
                field("Calculation Base %"; Rec."Calculation Base %")
                {
                    ToolTip = 'Specifies the percent at which the price of the Subscription Line will be calculated. 100% means that the price corresponds to the Base Price.';
                    Editable = false;
                    StyleExpr = LineStyleExpr;
                }
                field("Billing Base Period"; Rec."Billing Base Period")
                {
                    ToolTip = 'Specifies for which period the Amount is valid. If you enter 1M here, a period of one month, or 12M, a period of 1 year, to which Amount refers to.';
                    Editable = false;
                    StyleExpr = LineStyleExpr;
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Date formula for Rhythm in which the Subscription Line is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    Editable = false;
                    StyleExpr = LineStyleExpr;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        LoadVendorServiceCommitments();
    end;

    trigger OnAfterGetRecord()
    begin
        IsContractLine := Rec.Indent = 1;
        SetLineStyleExpr();

        if VendorContract.Get(Rec."Subscription Contract No.") then;
        SetDefaultValues();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not CurrPage.LookupMode then
            exit(true);
        if not (CloseAction = Action::LookupOK) then
            exit(true);
        LinkSelectedVendorContractLines();
    end;

    local procedure LoadVendorServiceCommitments()
    var
        ServiceCommitment: Record "Subscription Line";
        TextManagement: Codeunit "Text Management";
    begin
        Rec.Reset();
        Rec.DeleteAll(false);
        LastContractNo := '';

        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        ServiceCommitment.SetRange("Invoicing via", Enum::"Invoicing Via"::Contract);
        ServiceCommitment.SetFilter("Subscription Contract No.", '<>%1', '');
        TextManagement.ReplaceInvalidFilterChar(VendorContractFilterText);
        if VendorContractFilterText <> '' then
            ServiceCommitment.SetFilter("Subscription Contract No.", VendorContractFilterText);
        ServiceCommitment.SetCurrentKey("Subscription Contract No.");
        ServiceCommitment.SetRange(Closed, false);
        if ServiceCommitment.FindSet() then
            repeat
                LoadVendorServiceCommitmentIfRelevant(ServiceCommitment);
            until ServiceCommitment.Next() = 0;
        Rec.SetCurrentKey("Subscription Contract No.");
        CurrPage.Update(false);
    end;

    local procedure LoadVendorServiceCommitmentIfRelevant(ServiceCommitment: Record "Subscription Line")
    var
        VendorContract: Record "Vendor Subscription Contract";
    begin
        if ServiceCommitment.BillingLineExists() then
            exit;
        VendorContract.Get(ServiceCommitment."Subscription Contract No.");
        if VendorContract."Buy-from Vendor No." = PurchaseHeader."Buy-from Vendor No." then
            if not Rec.Get(ServiceCommitment."Entry No.") then begin
                CreateGroupingLine(ServiceCommitment);
                Rec.Init();
                Rec := ServiceCommitment;
                Rec.Indent := 1;
                Rec.Insert(false);
            end;
    end;

    local procedure CreateGroupingLine(ServiceCommitment: Record "Subscription Line")
    begin
        if GroupingLineShouldBeInserted(ServiceCommitment) then begin
            NextEntryNo -= 1;
            Rec.Init();
            Rec."Entry No." := NextEntryNo;
            Rec.Partner := ServiceCommitment.Partner;
            Rec."Subscription Contract No." := ServiceCommitment."Subscription Contract No.";
            Rec.Amount := GetContractTotalServiceAmount(ServiceCommitment);
            Rec.Indent := 0;
            Rec.Insert(false);
        end;
    end;

    local procedure GetContractTotalServiceAmount(ServiceCommitment: Record "Subscription Line"): Decimal
    var
        ServiceCommitment2: Record "Subscription Line";
    begin
        ServiceCommitment2.CopyFilters(Rec);
        ServiceCommitment2.SetRange("Subscription Contract No.", ServiceCommitment."Subscription Contract No.");
        ServiceCommitment2.CalcSums(Amount);
        exit(ServiceCommitment2.Amount);
    end;

    local procedure GroupingLineShouldBeInserted(ServiceCommitment: Record "Subscription Line") InsertLine: Boolean
    var
        NewContractNo: Code[20];
    begin
        NewContractNo := ServiceCommitment."Subscription Contract No.";

        InsertLine := LastContractNo <> NewContractNo;
        if InsertLine then
            LastContractNo := NewContractNo;
    end;

    local procedure LookupVendorContract()
    var
        VendorContract2: Record "Vendor Subscription Contract";
        VendorContracts: Page "Vendor Contracts";
    begin
        VendorContract2.SetRange("Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.");
        VendorContracts.SetTableView(VendorContract2);
        VendorContracts.LookupMode(true);
        if VendorContracts.RunModal() = Action::LookupOK then begin
            VendorContractFilterText := VendorContracts.GetVendorContractSelection();
            LoadVendorServiceCommitments();
        end;
    end;

    local procedure LinkSelectedVendorContractLines()
    begin
        Rec.SetRange(Selected, true);

        case RunningMode of
            RunningMode::"Assign Purchase Line to Contract Line":
                BillingProposal.CreateBillingProposalForPurchaseLine("Service Partner"::Vendor, Rec, BillingToDate, BillingToDate, PurchaseLine);
            RunningMode::"Create Purch. Line from Contract Line":
                begin
                    BillingProposal.CreateBillingProposalForPurchaseHeader("Service Partner"::Vendor, Rec, BillingToDate, BillingToDate);
                    BillingProposal.CreatePurchaseLines(PurchaseHeader);
                end;
        end;
    end;

    local procedure SetLineStyleExpr()
    begin
        if IsContractLine then
            LineStyleExpr := ''
        else
            LineStyleExpr := 'Strong';
    end;

    local procedure SetDefaultValues()
    begin
        if Rec.Selected then
            exit;
        BillingToDate := 0D;
        if (Rec."Next Billing Date" <> 0D) and IsContractLine then
            BillingToDate := BillingProposal.CalculateNextBillingToDateForServiceCommitment(Rec, Rec."Next Billing Date");
        if VendorInvoiceAmountEditable then
            VendorInvoiceAmount := Rec.Amount
    end;

    local procedure ResetPreviouslySelectedServiceCommitment()
    begin
        Rec.SetRange(Selected, true);
        Rec.SetFilter("Entry No.", '<>%1', Rec."Entry No.");
        if Rec.FindFirst() then  //Only one line can be selected
            ResetServiceCommitment();
        Rec.SetRange(Selected);
        Rec.SetRange("Entry No.");
    end;

    local procedure ResetServiceCommitment()
    var
        SourceServiceCommitment: Record "Subscription Line";
    begin
        SourceServiceCommitment.Get(Rec."Entry No.");
        Rec := SourceServiceCommitment;
        Rec.Indent := 1;
        Rec.Modify(false);
    end;

    local procedure UpdateWithVendorInvoiceAmount()
    begin
        Rec.Validate("Calculation Base %", 100);
        Rec.Validate("Calculation Base Amount", VendorInvoiceAmount);
        Rec.Validate(Amount, VendorInvoiceAmount);
    end;

    local procedure TestPurchaseDocument(PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader.TestField("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.TestField(Status, PurchaseHeader.Status::Open);
    end;

    internal procedure SetPurchaseHeader(NewPurchaseHeader: Record "Purchase Header")
    begin
        VendorInvoiceAmount := 0;
        RunningMode := RunningMode::"Create Purch. Line from Contract Line";
        VendorInvoiceAmountEditable := true;
        PurchaseHeader := NewPurchaseHeader;
        TestPurchaseDocument(PurchaseHeader);
    end;

    internal procedure SetPurchaseLine(NewPurchaseLine: Record "Purchase Line")
    var
        AssignVendorContractLinePageLbl: Label 'Link Purchase Line with Contract Line';
    begin
        CurrPage.Caption(AssignVendorContractLinePageLbl);
        RunningMode := RunningMode::"Assign Purchase Line to Contract Line";
        VendorInvoiceAmountEditable := false;
        PurchaseHeader.Get(NewPurchaseLine."Document Type", NewPurchaseLine."Document No.");
        TestPurchaseDocument(PurchaseHeader);
        PurchaseLine := NewPurchaseLine;
        VendorInvoiceAmount := PurchaseLine."Line Amount";
    end;

    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VendorContract: Record "Vendor Subscription Contract";
        BillingProposal: Codeunit "Billing Proposal";
        NextEntryNo: Integer;
        BillingToDate: Date;
        VendorInvoiceAmount: Decimal;
        IsContractLine: Boolean;
        VendorInvoiceAmountEditable: Boolean;
        LastContractNo: Code[20];
        LineStyleExpr: Text;
        VendorContractFilterText: Text;
        RunningMode: Option "Assign Purchase Line to Contract Line","Create Purch. Line from Contract Line";
}
