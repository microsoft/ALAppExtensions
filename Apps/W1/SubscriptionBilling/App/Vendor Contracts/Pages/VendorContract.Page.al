namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.Address;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Finance.Dimension;

page 8070 "Vendor Contract"
{
    Caption = 'Vendor Contract';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Vendor Contract";
    UsageCategory = None;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    Visible = DocNoVisible;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = Suite;
                    Caption = 'Vendor No.';
                    Importance = Additional;
                    NotBlank = true;
                    ToolTip = 'Specifies the number of the vendor who delivers the products.';

                    trigger OnValidate()
                    begin
                        Rec.OnAfterValidateBuyFromVendorNo(Rec, xRec);
                        CurrPage.Update();
                    end;
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = Suite;
                    Caption = 'Vendor Name';
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the name of the vendor who delivers the products.';

                    trigger OnValidate()
                    begin
                        Rec.OnAfterValidateBuyFromVendorNo(Rec, xRec);
                        CurrPage.Update();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if Rec.LookupBuyfromVendorName() then
                            CurrPage.Update();
                    end;
                }
                group("Buy-from")
                {
                    Caption = 'Buy-from';
                    field("Buy-from Address"; Rec."Buy-from Address")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Address';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the vendor''s buy-from address.';
                    }
                    field("Buy-from Address 2"; Rec."Buy-from Address 2")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Address 2';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies an additional part of the vendor''s buy-from address.';
                    }
                    field("Buy-from City"; Rec."Buy-from City")
                    {
                        ApplicationArea = Suite;
                        Caption = 'City';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the city of the vendor on the purchase document.';
                    }
                    group(Control122)
                    {
                        ShowCaption = false;
                        Visible = IsBuyFromCountyVisible;
                        field("Buy-from County"; Rec."Buy-from County")
                        {
                            ApplicationArea = Suite;
                            Caption = 'County';
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the state, province or county of the address.';
                        }
                    }
                    field("Buy-from Post Code"; Rec."Buy-from Post Code")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Post Code';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the postal code.';
                    }
                    field("Buy-from Country/Region Code"; Rec."Buy-from Country/Region Code")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Country/Region';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the country or region of the address.';

                        trigger OnValidate()
                        begin
                            IsBuyFromCountyVisible := FormatAddress.UseCounty(Rec."Buy-from Country/Region Code");
                        end;
                    }
                    field("Buy-from Contact No."; Rec."Buy-from Contact No.")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Contact No.';
                        Importance = Additional;
                        ToolTip = 'Specifies the number of contact person of the vendor''s buy-from.';
                    }
                }
                field("Buy-from Contact"; Rec."Buy-from Contact")
                {
                    ApplicationArea = Suite;
                    Caption = 'Contact';
                    Editable = Rec."Buy-from Vendor No." <> '';
                    ToolTip = 'Specifies the name of the person to contact about an order from this vendor.';
                }
                field(Active; Rec.Active)
                {
                    ToolTip = 'Specifies whether the contract is active.';
                }
                field("Contract Type"; Rec."Contract Type")
                {
                    ToolTip = 'Specifies the classification of the contract.';
                }
                group(Description)
                {
                    Caption = 'Description';
                    field(DescriptionText; DescriptionText)
                    {
                        MultiLine = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the products or service being offered.';

                        trigger OnValidate()
                        begin
                            Rec.SetDescription(DescriptionText);
                        end;
                    }
                }
                field("Your Reference"; Rec."Your Reference")
                {
                    ApplicationArea = Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the vendor''s reference.';
                }
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    ApplicationArea = Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies which purchaser is assigned to the vendor contract.';
                }
                field("Assigned User ID"; Rec."Assigned User ID")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the ID of the user who is responsible for the document.';
                }
                field("Without Contract Deferrals"; Rec."Without Contract Deferrals")
                {
                    ApplicationArea = Suite;
                    Importance = Additional;
                    QuickEntry = false;
                    ToolTip = 'Specifies whether deferrals should be generated for the contract. If the field is activated, no deferrals are generated and the invoices are posted directly to profit or loss.';
                }
                field("Exclude from Price Update"; Rec.DefaultExcludeFromPriceUpdate)
                {
                    Importance = Additional;
                    ToolTip = 'Specifies whether new contract lines will be set to be allowed in price updates by default, when they are assigned to the contract.';
                }
            }

            part(Lines; "Vendor Contract Line Subpage")
            {
                Caption = 'Lines';
                SubPageLink = "Contract No." = field("No."), Closed = filter(false);
            }
            part("Closed Lines"; "Closed Vend. Cont. Line Subp.")
            {
                Caption = 'Closed Lines';
                SubPageLink = "Contract No." = field("No."), Closed = filter(true);
            }
            group(Payment)
            {
                Caption = 'Payment';
                field(PayToOptions; PayToOptions)
                {
                    Caption = 'Pay-to';
                    OptionCaption = 'Default (Vendor),Another Vendor,Custom Address';
                    ToolTip = 'Specifies the vendor that the purchase document will be paid to. Default (Vendor): The same as the vendor on the purchase document. Another Vendor: Any vendor that you specify in the fields below.';

                    trigger OnValidate()
                    begin
                        if PayToOptions = PayToOptions::"Default (Vendor)" then
                            Rec.Validate("Pay-to Vendor No.", Rec."Buy-from Vendor No.");
                    end;
                }
                group(Control95)
                {
                    ShowCaption = false;
                    Visible = not (PayToOptions = PayToOptions::"Default (Vendor)");
                    field("Pay-to Name"; Rec."Pay-to Name")
                    {
                        Caption = 'Name';
                        Editable = PayToOptions = PayToOptions::"Another Vendor";
                        Enabled = PayToOptions = PayToOptions::"Another Vendor";
                        Importance = Promoted;
                        ToolTip = 'Specifies the name of the vendor sending the invoice.';

                        trigger OnValidate()
                        begin
                            if Rec.GetFilter("Pay-to Vendor No.") = xRec."Pay-to Vendor No." then
                                if Rec."Pay-to Vendor No." <> xRec."Pay-to Vendor No." then
                                    Rec.SetRange("Pay-to Vendor No.");

                            CurrPage.Update();
                        end;
                    }
                    field("Pay-to Address"; Rec."Pay-to Address")
                    {
                        Caption = 'Address';
                        Editable = (PayToOptions = PayToOptions::"Custom Address") or (Rec."Buy-from Vendor No." <> Rec."Pay-to Vendor No.");
                        Enabled = (PayToOptions = PayToOptions::"Custom Address") or (Rec."Buy-from Vendor No." <> Rec."Pay-to Vendor No.");
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the address of the vendor sending the invoice.';
                    }
                    field("Pay-to Address 2"; Rec."Pay-to Address 2")
                    {
                        Caption = 'Address 2';
                        Editable = (PayToOptions = PayToOptions::"Custom Address") or (Rec."Buy-from Vendor No." <> Rec."Pay-to Vendor No.");
                        Enabled = (PayToOptions = PayToOptions::"Custom Address") or (Rec."Buy-from Vendor No." <> Rec."Pay-to Vendor No.");
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies additional address information.';
                    }
                    field("Pay-to City"; Rec."Pay-to City")
                    {
                        Caption = 'City';
                        Editable = (PayToOptions = PayToOptions::"Custom Address") or (Rec."Buy-from Vendor No." <> Rec."Pay-to Vendor No.");
                        Enabled = (PayToOptions = PayToOptions::"Custom Address") or (Rec."Buy-from Vendor No." <> Rec."Pay-to Vendor No.");
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the city of the vendor on the purchase document.';
                    }
                    group(Control123)
                    {
                        ShowCaption = false;
                        Visible = IsPayToCountyVisible;
                        field("Pay-to County"; Rec."Pay-to County")
                        {
                            Caption = 'County';
                            Editable = (PayToOptions = PayToOptions::"Custom Address") or (Rec."Buy-from Vendor No." <> Rec."Pay-to Vendor No.");
                            Enabled = (PayToOptions = PayToOptions::"Custom Address") or (Rec."Buy-from Vendor No." <> Rec."Pay-to Vendor No.");
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the state, province or county of the address.';
                        }
                    }
                    field("Pay-to Post Code"; Rec."Pay-to Post Code")
                    {
                        Caption = 'Post Code';
                        Editable = (PayToOptions = PayToOptions::"Custom Address") or (Rec."Buy-from Vendor No." <> Rec."Pay-to Vendor No.");
                        Enabled = (PayToOptions = PayToOptions::"Custom Address") or (Rec."Buy-from Vendor No." <> Rec."Pay-to Vendor No.");
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the postal code.';
                    }
                    field("Pay-to Country/Region Code"; Rec."Pay-to Country/Region Code")
                    {
                        Caption = 'Country/Region';
                        Editable = (PayToOptions = PayToOptions::"Custom Address") or (Rec."Buy-from Vendor No." <> Rec."Pay-to Vendor No.");
                        Enabled = (PayToOptions = PayToOptions::"Custom Address") or (Rec."Buy-from Vendor No." <> Rec."Pay-to Vendor No.");
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the country/region code of the vendor on the purchase document.';

                        trigger OnValidate()
                        begin
                            IsPayToCountyVisible := FormatAddress.UseCounty(Rec."Pay-to Country/Region Code");
                        end;
                    }
                    field("Pay-to Contact No."; Rec."Pay-to Contact No.")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Contact No.';
                        Editable = (PayToOptions = PayToOptions::"Custom Address") or (Rec."Buy-from Vendor No." <> Rec."Pay-to Vendor No.");
                        Enabled = (PayToOptions = PayToOptions::"Custom Address") or (Rec."Buy-from Vendor No." <> Rec."Pay-to Vendor No.");
                        Importance = Additional;
                        ToolTip = 'Specifies the number of contact person of the vendor''s buy-from.';
                    }
                    field("Pay-to Contact"; Rec."Pay-to Contact")
                    {
                        Caption = 'Contact';
                        Editable = (PayToOptions = PayToOptions::"Custom Address") or (Rec."Buy-from Vendor No." <> Rec."Pay-to Vendor No.");
                        Enabled = (PayToOptions = PayToOptions::"Custom Address") or (Rec."Buy-from Vendor No." <> Rec."Pay-to Vendor No.");
                        ToolTip = 'Specifies the name of the person to contact about an order from this vendor.';
                    }
                }
            }
            group("Invoice Details")
            {
                Caption = 'Invoice Details';
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the currency of amounts on the vendor contract invoice.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies a formula that calculates the payment due date, payment discount date, and payment discount amount.';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies how to make payment, such as with bank transfer, cash, or check.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Contract)
            {
                Caption = 'Vendor Contract';
                Image = "Order";
                action(Vendor)
                {
                    Caption = 'Vendor';
                    Enabled = IsVendorOrContactNotEmpty;
                    Image = Vendor;
                    RunObject = page "Vendor Card";
                    RunPageLink = "No." = field("Pay-to Vendor No.");
                    ShortcutKey = 'Shift+F7';
                    ToolTip = 'View or edit detailed information about the vendor on the vendor contract.';
                }
                action(Dimensions)
                {
                    AccessByPermission = tabledata Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortcutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
                    end;
                }
                action(GetServiceCommitmentsAction)
                {
                    Caption = 'Get Service Commitments';
                    Image = SelectLineToApply;
                    ToolTip = 'Get Service Commitments without Contract.';

                    trigger OnAction()
                    var
                        ServCommWOVendContract: Page "Serv. Comm. WO Vend. Contract";
                    begin
                        ServCommWOVendContract.SetVendorContractNo(Rec."No.");
                        ServCommWOVendContract.Run();
                    end;
                }
                action(UpdateServicesDatesAction)
                {
                    Caption = 'Update Service Dates';
                    Image = ChangeDates;
                    ToolTip = 'The function updates the dates in the service commitments.';

                    trigger OnAction()
                    var
                    begin
                        Rec.UpdateServicesDates();
                    end;
                }
                action(UpdateExchangeRates)
                {
                    Caption = 'Update Exchange Rates';
                    Image = ChangeDates;
                    ToolTip = 'Starts the update of the exchange rate.';

                    trigger OnAction()
                    begin
                        Rec.UpdateAndRecalculateServiceCommitmentCurrencyData()
                    end;
                }
                action(CreateContractInvoice)
                {
                    Caption = 'Create Contract Invoice';
                    Image = CreateDocuments;
                    ToolTip = 'The action creates a contract invoice for the current contract.';

                    trigger OnAction()
                    begin
                        Rec.CreateBillingProposal();
                    end;
                }
                action(ShowPurchaseInvoices)
                {
                    Caption = 'Purchase Invoices';
                    Image = SalesInvoice;
                    ToolTip = 'Show purchase invoices.';

                    trigger OnAction()
                    begin
                        ContractsGeneralMgt.ShowUnpostedPurchDocument(Enum::"Purchase Document Type"::Invoice, Rec);
                    end;
                }
                action(ShowPurchaseCreditMemos)
                {
                    Caption = 'Purchase Credit Memos';
                    Image = SalesCreditMemo;
                    ToolTip = 'Show purchase credit memos.';

                    trigger OnAction()
                    begin
                        ContractsGeneralMgt.ShowUnpostedPurchDocument(Enum::"Purchase Document Type"::"Credit Memo", Rec);
                    end;
                }
                action(ShowPostedPurchaseInvoices)
                {
                    Caption = 'Posted Purchase Invoices';
                    Image = ViewPostedOrder;
                    ToolTip = 'Show posted purchase invoices.';

                    trigger OnAction()
                    begin
                        ContractsGeneralMgt.ShowPostedPurchaseInvoices(Rec);
                    end;
                }
                action(ShowPostedSalesCreditMemos)
                {
                    Caption = 'Posted Purchase Credit Memos';
                    Image = PostedCreditMemo;
                    ToolTip = 'Show posted credit memos.';

                    trigger OnAction()
                    begin
                        ContractsGeneralMgt.ShowPostedPurchaseCreditMemos(Rec);
                    end;
                }
                action("Vendor Contract Deferrals")
                {
                    Caption = 'Vendor Contract Deferrals';
                    ToolTip = 'Vendor Contract Deferrals.';
                    Image = LedgerEntries;
                    ShortcutKey = 'Ctrl+F7';
                    RunObject = page "Vendor Contract Deferrals";
                    RunPageView = sorting("Contract No.");
                    RunPageLink = "Contract No." = field("No.");

                }
                action(UpdateDimensionsInDeferrals)
                {
                    Caption = 'Update Dimensions in Deferrals';
                    ToolTip = 'Updates the dimensions in all contract deferrals that have not yet been released for this contract.';
                    Image = ChangeDimensions;
                    Enabled = UpdateDimensionsInDeferralsEnabled;
                    trigger OnAction()
                    begin
                        Rec.UpdateDimensionsInDeferrals();
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(GetServiceCommitmentsAction_Promoted; GetServiceCommitmentsAction)
                {
                }
                actionref(UpdateServicesDatesAction_Promoted; UpdateServicesDatesAction)
                {
                }
                actionref(UpdateExchangeRates_Promoted; UpdateExchangeRates)
                {
                }
                actionref(CreateContractInvoice_Promoted; CreateContractInvoice)
                {
                }
            }
            group(Category_Category4)
            {
                Caption = 'Navigate';

                actionref(Vendor_Promoted; Vendor)
                {
                }
                actionref(ShowPurchaseInvoices_Promoted; ShowPurchaseInvoices)
                {
                }
                actionref(ShowPurchaseCreditMemos_Promoted; ShowPurchaseCreditMemos)
                {
                }
                actionref(ShowPostedPurchaseInvoices_Promoted; ShowPostedPurchaseInvoices)
                {
                }
                actionref(ShowPostedSalesCreditMemos_Promoted; ShowPostedSalesCreditMemos)
                {
                }
            }
            group(Category_Category5)
            {
                Caption = 'Contract';

                actionref(Dimensions_Promoted; Dimensions)
                {
                }
                actionref("Vendor Contract Deferrals_Promoted"; "Vendor Contract Deferrals")
                {
                }
                actionref(UpdateDimensionsInDeferrals_Promoted; UpdateDimensionsInDeferrals)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetControlVisibility();
        CalculateCurrentPayToOption();
        DescriptionText := Rec.GetDescription();
        UpdateDimensionsInDeferralsEnabled := Rec.NotReleasedVendorContractDeferralsExists();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if (not DocNoVisible) and (Rec."No." = '') then
            Rec.SetBuyFromVendorFromFilter();

        CalculateCurrentPayToOption();
    end;

    trigger OnOpenPage()
    begin
        SetDocNoVisible();

        ActivateFields();
    end;

    var
        FormatAddress: Codeunit "Format Address";
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
        DocNoVisible: Boolean;
        DescriptionText: Text;
        IsBuyFromCountyVisible: Boolean;
        IsPayToCountyVisible: Boolean;
        IsVendorOrContactNotEmpty: Boolean;
        UpdateDimensionsInDeferralsEnabled: Boolean;

    protected var
        PayToOptions: Option "Default (Vendor)","Another Vendor","Custom Address";

    local procedure ActivateFields()
    begin
        IsBuyFromCountyVisible := FormatAddress.UseCounty(Rec."Buy-from Country/Region Code");
        IsPayToCountyVisible := FormatAddress.UseCounty(Rec."Pay-to Country/Region Code");
    end;

    local procedure SetControlVisibility()
    begin
        IsVendorOrContactNotEmpty := (Rec."Pay-to Vendor No." <> '') or (Rec."Buy-from Contact No." <> '');
    end;

    local procedure CalculateCurrentPayToOption()
    begin
        case true of
            (Rec."Pay-to Vendor No." = Rec."Buy-from Vendor No.") and Rec.BuyFromAddressEqualsPayToAddress():
                PayToOptions := PayToOptions::"Default (Vendor)";
            (Rec."Pay-to Vendor No." = Rec."Buy-from Vendor No.") and (not Rec.BuyFromAddressEqualsPayToAddress()):
                PayToOptions := PayToOptions::"Custom Address";
            Rec."Pay-to Vendor No." <> Rec."Buy-from Vendor No.":
                PayToOptions := PayToOptions::"Another Vendor";
        end;
    end;

    local procedure SetDocNoVisible()
    begin
        DocNoVisible := Rec."No." = '';
    end;
}
