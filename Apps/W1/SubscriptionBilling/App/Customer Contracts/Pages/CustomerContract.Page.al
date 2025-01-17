namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.Attachment;
using Microsoft.Foundation.Address;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Finance.Dimension;

page 8052 "Customer Contract"
{
    Caption = 'Customer Contract';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Customer Contract";
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    Visible = DocNoVisible;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    Caption = 'Customer No.';
                    Importance = Additional;
                    NotBlank = true;
                    ToolTip = 'Specifies the number of the customer who will receive the contractual services and be billed by default.';

                    trigger OnValidate()
                    begin
                        Rec.SelltoCustomerNoOnAfterValidate(Rec, xRec);
                        CurrPage.Update();
                    end;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    Caption = 'Customer Name';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the name of the customer who will receive the contractual services and be billed by default.';

                    trigger OnValidate()
                    begin
                        Rec.SelltoCustomerNoOnAfterValidate(Rec, xRec);
                        CurrPage.Update();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if Rec.LookupSellToCustomerName() then
                            CurrPage.Update();
                    end;
                }
                group("Sell-to")
                {
                    Caption = 'Sell-to';
                    field("Sell-to Address"; Rec."Sell-to Address")
                    {
                        Caption = 'Address';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the address where the customer is located.';
                    }
                    field("Sell-to Address 2"; Rec."Sell-to Address 2")
                    {
                        Caption = 'Address 2';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies additional address information.';
                    }
                    field("Sell-to City"; Rec."Sell-to City")
                    {
                        Caption = 'City';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the city of the customer on the customer contract.';
                    }
                    group(Control123)
                    {
                        ShowCaption = false;
                        Visible = IsSellToCountyVisible;
                        field("Sell-to County"; Rec."Sell-to County")
                        {
                            Caption = 'County';
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the state, province or county of the address.';
                        }
                    }
                    field("Sell-to Post Code"; Rec."Sell-to Post Code")
                    {
                        Caption = 'Post Code';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the postal code.';
                    }
                    field("Sell-to Country/Region Code"; Rec."Sell-to Country/Region Code")
                    {
                        Caption = 'Country/Region Code';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the country or region of the address.';

                        trigger OnValidate()
                        begin
                            IsSellToCountyVisible := FormatAddress.UseCounty(Rec."Sell-to Country/Region Code");
                        end;
                    }
                    field("Sell-to Contact No."; Rec."Sell-to Contact No.")
                    {
                        Caption = 'Contact No.';
                        Importance = Additional;
                        ToolTip = 'Specifies the number of the contact that receives the contractual services.';

                        trigger OnValidate()
                        begin
                            if Rec.GetFilter("Sell-to Contact No.") = xRec."Sell-to Contact No." then
                                if Rec."Sell-to Contact No." <> xRec."Sell-to Contact No." then
                                    Rec.SetRange("Sell-to Contact No.");
                        end;
                    }
                }
                field("Sell-to Contact"; Rec."Sell-to Contact")
                {
                    Caption = 'Contact';
                    Editable = SellToContactEditable;
                    ToolTip = 'Specifies the name of the person to contact at the customer.';
                }
                field("Your Reference"; Rec."Your Reference")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the customer''s reference. The content will be printed on contract invoice.';
                }
                field(Active; Rec.Active)
                {
                    ToolTip = 'Specifies whether the contract is active.';
                }
                field("Contract Type"; Rec."Contract Type")
                {
                    ToolTip = 'Specifies the classification of the contract.';
                }
                field("Dimension from Job No."; Rec."Dimension from Job No.")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the Project number from which the dimensions for the contract are transfered.';
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
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = Suite;
                    Importance = Additional;
                    QuickEntry = false;
                    ToolTip = 'Specifies the name of the salesperson who is assigned to the customer.';
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
            part(Lines; "Customer Contract Line Subp.")
            {
                Caption = 'Lines';
                SubPageLink = "Contract No." = field("No."), "Closed" = filter(false);
            }
            part("Closed Lines"; "Closed Cust. Cont. Line Subp.")
            {
                Caption = 'Closed Lines';
                SubPageLink = "Contract No." = field("No."), "Closed" = filter(true);
                UpdatePropagation = Both;
            }
            group("Invoice Details")
            {
                Caption = 'Invoice Details';
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the currency of amounts on the contract invoice.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies a formula that calculates the payment due date, payment discount date, and payment discount amount.';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies how to make payment, such as with bank transfer, cash, or check.';
                }
                field("Detail Overview"; Rec."Detail Overview")
                {
                    ToolTip = 'Specifies whether the billing details for this contract are automatically output with invoices and credit memos.';
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
                field("Contractor Name in coll. Inv."; Rec."Contractor Name in coll. Inv.")
                {
                    ToolTip = 'Specifies that the name of the contractor (Sell-to Customer) is transferred to collective invoices.';
                }
                field("Recipient Name in coll. Inv."; Rec."Recipient Name in coll. Inv.")
                {
                    ToolTip = 'Specifies that the recipient name (Ship-to Address) is transferred to collective invoices.';
                }
            }
            group("Shipping and Billing")
            {
                Caption = 'Shipping and Billing';
                group(Control91)
                {
                    ShowCaption = false;
                    group(Control90)
                    {
                        ShowCaption = false;
                        field(ShippingOptions; ShipToOptions)
                        {
                            Caption = 'Ship-to';
                            ToolTip = 'Specifies the address that the service commitments on the contract are delivered to. Default (Sell-to Address): The same as the customer''s sell-to address. Alternate Ship-to Address: One of the customer''s alternate ship-to addresses. Custom Address: Any ship-to address that you specify in the fields below.';

                            trigger OnValidate()
                            var
                                ShipToAddress: Record "Ship-to Address";
                                ShipToAddressList: Page "Ship-to Address List";
                                IsHandled: Boolean;
                            begin
                                IsHandled := false;
                                OnBeforeValidateShipToOptions(Rec, ShipToOptions, IsHandled);
                                if IsHandled then
                                    exit;

                                case ShipToOptions of
                                    ShipToOptions::"Default (Sell-to Address)":
                                        begin
                                            Rec.Validate("Ship-to Code", '');
                                            Rec.CopySellToAddressToShipToAddress();
                                        end;
                                    ShipToOptions::"Alternate Shipping Address":
                                        begin
                                            ShipToAddress.SetRange("Customer No.", Rec."Sell-to Customer No.");
                                            ShipToAddressList.LookupMode := true;
                                            ShipToAddressList.SetTableView(ShipToAddress);

                                            if ShipToAddressList.RunModal() = Action::LookupOK then begin
                                                ShipToAddressList.GetRecord(ShipToAddress);
                                                OnValidateShipToOptionsOnAfterShipToAddressListGetRecord(ShipToAddress, Rec);
                                                Rec.Validate("Ship-to Code", ShipToAddress.Code);
                                                IsShipToCountyVisible := FormatAddress.UseCounty(ShipToAddress."Country/Region Code");
                                            end else
                                                ShipToOptions := ShipToOptions::"Custom Address";
                                        end;
                                    ShipToOptions::"Custom Address":
                                        begin
                                            Rec.Validate("Ship-to Code", '');
                                            IsShipToCountyVisible := FormatAddress.UseCounty(Rec."Ship-to Country/Region Code");
                                        end;
                                end;

                                OnAfterValidateShippingOptions(Rec, ShipToOptions);
                            end;
                        }
                        group(Control4)
                        {
                            ShowCaption = false;
                            Visible = not (ShipToOptions = ShipToOptions::"Default (Sell-to Address)");
                            field("Ship-to Code"; Rec."Ship-to Code")
                            {
                                Caption = 'Code';
                                Editable = ShipToOptions = ShipToOptions::"Alternate Shipping Address";
                                Importance = Promoted;
                                ToolTip = 'Specifies the code for another shipment address than the customer''s own address, which is entered by default.';

                                trigger OnValidate()
                                var
                                    ShipToAddress: Record "Ship-to Address";
                                begin
                                    if (xRec."Ship-to Code" <> '') and (Rec."Ship-to Code" = '') then
                                        Error(EmptyShipToCodeErr);
                                    if Rec."Ship-to Code" <> '' then begin
                                        ShipToAddress.Get(Rec."Sell-to Customer No.", Rec."Ship-to Code");
                                        IsShipToCountyVisible := FormatAddress.UseCounty(ShipToAddress."Country/Region Code");
                                    end else
                                        IsShipToCountyVisible := false;
                                end;
                            }
                            field("Ship-to Name"; Rec."Ship-to Name")
                            {
                                Caption = 'Name';
                                Editable = ShipToOptions = ShipToOptions::"Custom Address";
                                ToolTip = 'Specifies the name of the one who receives or uses the contract service commitments.';
                            }
                            field("Ship-to Address"; Rec."Ship-to Address")
                            {
                                Caption = 'Address';
                                Editable = ShipToOptions = ShipToOptions::"Custom Address";
                                QuickEntry = false;
                                ToolTip = 'Specifies the address of the one who receives or uses the contract service commitments.';
                            }
                            field("Ship-to Address 2"; Rec."Ship-to Address 2")
                            {
                                Caption = 'Address 2';
                                Editable = ShipToOptions = ShipToOptions::"Custom Address";
                                QuickEntry = false;
                                ToolTip = 'Specifies additional address information.';
                            }
                            field("Ship-to City"; Rec."Ship-to City")
                            {
                                Caption = 'City';
                                Editable = ShipToOptions = ShipToOptions::"Custom Address";
                                QuickEntry = false;
                                ToolTip = 'Specifies the city of the customer on the contract.';
                            }
                            group(Control297)
                            {
                                ShowCaption = false;
                                Visible = IsShipToCountyVisible;
                                field("Ship-to County"; Rec."Ship-to County")
                                {
                                    Caption = 'County';
                                    Editable = ShipToOptions = ShipToOptions::"Custom Address";
                                    QuickEntry = false;
                                    ToolTip = 'Specifies the state, province or county of the address.';
                                }
                            }
                            field("Ship-to Post Code"; Rec."Ship-to Post Code")
                            {
                                Caption = 'Post Code';
                                Editable = ShipToOptions = ShipToOptions::"Custom Address";
                                QuickEntry = false;
                                ToolTip = 'Specifies the postal code.';
                            }
                            field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                            {
                                Caption = 'Country/Region';
                                Editable = ShipToOptions = ShipToOptions::"Custom Address";
                                Importance = Additional;
                                QuickEntry = false;
                                ToolTip = 'Specifies the customer''s country/region.';

                                trigger OnValidate()
                                begin
                                    IsShipToCountyVisible := FormatAddress.UseCounty(Rec."Ship-to Country/Region Code");
                                end;
                            }
                        }
                        field("Ship-to Contact"; Rec."Ship-to Contact")
                        {
                            Caption = 'Contact';
                            ToolTip = 'Specifies the name of the contact person at the address where contract service commitments are received or used.';
                        }
                    }
                }
                group(Control85)
                {
                    ShowCaption = false;
                    field(BillToOptions; BillToOptions)
                    {
                        Caption = 'Bill-to';
                        ToolTip = 'Specifies the customer that the contract invoice will be sent to. Default (Customer): The same as the customer on the contract. Another Customer: Any customer that you specify in the fields below.';

                        trigger OnValidate()
                        begin
                            if BillToOptions = BillToOptions::"Default (Customer)" then begin
                                Rec.Validate("Bill-to Customer No.", Rec."Sell-to Customer No.");
                                Rec.RecallModifyAddressNotification(Rec.GetModifyBillToCustomerAddressNotificationId());
                            end;

                            Rec.CopySellToAddressToBillToAddress();

                            UpdateBillToFieldsEnabled();
                        end;
                    }
                    group(Control82)
                    {
                        ShowCaption = false;
                        Visible = not (BillToOptions = BillToOptions::"Default (Customer)");
                        field("Bill-to Name"; Rec."Bill-to Name")
                        {
                            Caption = 'Name';
                            Editable = BillToOptions = BillToOptions::"Another Customer";
                            Enabled = BillToOptions = BillToOptions::"Another Customer";
                            Importance = Promoted;
                            ToolTip = 'Specifies the customer to whom you will send the contract invoice, when different from the contractor.';

                            trigger OnValidate()
                            begin
                                if Rec.GetFilter("Bill-to Customer No.") = xRec."Bill-to Customer No." then
                                    if Rec."Bill-to Customer No." <> xRec."Bill-to Customer No." then
                                        Rec.SetRange("Bill-to Customer No.");

                                CurrPage.SaveRecord();

                                CurrPage.Update(false);
                            end;
                        }
                        field("Bill-to Address"; Rec."Bill-to Address")
                        {
                            Caption = 'Address';
                            Editable = BillToFieldsEnabled;
                            Enabled = BillToFieldsEnabled;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the address of the customer that you will send the invoice to.';
                        }
                        field("Bill-to Address 2"; Rec."Bill-to Address 2")
                        {
                            Caption = 'Address 2';
                            Editable = BillToFieldsEnabled;
                            Enabled = BillToFieldsEnabled;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies additional address information.';
                        }
                        field("Bill-to City"; Rec."Bill-to City")
                        {
                            Caption = 'City';
                            Editable = BillToFieldsEnabled;
                            Enabled = BillToFieldsEnabled;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the city of the customer on the contract invoice.';
                        }
                        group(Control130)
                        {
                            ShowCaption = false;
                            Visible = IsBillToCountyVisible;
                            field("Bill-to County"; Rec."Bill-to County")
                            {
                                Caption = 'County';
                                Editable = BillToFieldsEnabled;
                                Enabled = BillToFieldsEnabled;
                                Importance = Additional;
                                QuickEntry = false;
                                ToolTip = 'Specifies the state, province or county of the address.';
                            }
                        }
                        field("Bill-to Post Code"; Rec."Bill-to Post Code")
                        {
                            Caption = 'Post Code';
                            Editable = BillToFieldsEnabled;
                            Enabled = BillToFieldsEnabled;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the postal code.';
                        }
                        field("Bill-to Country/Region Code"; Rec."Bill-to Country/Region Code")
                        {
                            Caption = 'Country/Region Code';
                            Editable = BillToFieldsEnabled;
                            Enabled = BillToFieldsEnabled;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the country or region of the address.';

                            trigger OnValidate()
                            begin
                                IsBillToCountyVisible := FormatAddress.UseCounty(Rec."Bill-to Country/Region Code");
                            end;
                        }
                        field("Bill-to Contact No."; Rec."Bill-to Contact No.")
                        {
                            Caption = 'Contact No.';
                            Editable = BillToFieldsEnabled;
                            Enabled = BillToFieldsEnabled;
                            Importance = Additional;
                            ToolTip = 'Specifies the number of the contact the invoice will be sent to.';
                        }
                        field("Bill-to Contact"; Rec."Bill-to Contact")
                        {
                            Caption = 'Contact';
                            Editable = BillToFieldsEnabled;
                            Enabled = BillToFieldsEnabled;
                            ToolTip = 'Specifies the name of the person you should contact at the customer who you are sending the invoice to.';
                        }
                    }
                    group("Harmonized Billing")
                    {
                        Caption = 'Harmonized Billing';
                        field("Billing Base Date"; Rec."Billing Base Date")
                        {
                            ToolTip = 'Specifies the billing base date for the contract. If a date is specified here, the billing of all services will be harmonized based on this date.';
                            Editable = ContractTypeSetAsHarmonizedBilling;
                        }
                        field("Default Billing Rhythm"; Rec."Default Billing Rhythm")
                        {
                            ToolTip = 'Specifies the billing rhythm of the contract. If a date formula is specified here, the billing of all services will be harmonized based on this billing rhythm.';
                            Editable = ContractTypeSetAsHarmonizedBilling;
                        }
                        field("Next Billing From"; Rec."Next Billing From")
                        {
                            ToolTip = 'Specifies the start date of the next billing period. The next billing of all services will be harmonized to this date.';
                        }
                        field("Next Billing To"; Rec."Next Billing To")
                        {
                            ToolTip = 'Specifies the end date of the next billing period. The next billing of all services will be harmonized to this date.';
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            part(Control1903720907; "Sales Hist. Sell-to FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("Sell-to Customer No.");
            }
            part(Control1902018507; "Customer Statistics FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("Bill-to Customer No.");
                Visible = false;
            }
            part(Control1900316107; "Customer Details FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("Sell-to Customer No.");
            }
            part(Control1907234507; "Sales Hist. Bill-to FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("Bill-to Customer No.");
                Visible = false;
            }
            part("Attached Documents"; "Doc. Attachment List Factbox")
            {
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::"Customer Contract"),
                              "No." = field("No.");
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Contract)
            {
                Caption = 'Customer Contract';
                Image = "Order";
                action(Customer)
                {
                    Caption = 'Customer';
                    Enabled = IsCustomerOrContactNotEmpty;
                    Image = Customer;
                    RunObject = page "Customer Card";
                    RunPageLink = "No." = field("Sell-to Customer No.");
                    ShortcutKey = 'Shift+F7';
                    ToolTip = 'View or edit detailed information about the customer on the customer contract.';
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
                action("Customer Contract Deferrals")
                {
                    Caption = 'Customer Contract Deferrals';
                    ToolTip = 'Customer Contract Deferrals.';
                    Image = LedgerEntries;
                    ShortcutKey = 'Ctrl+F7';
                    RunObject = page "Customer Contract Deferrals";
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
                action(GetServiceCommitmentsAction)
                {
                    Caption = 'Get Service Commitments';
                    Image = SelectLineToApply;
                    ToolTip = 'Get Service Commitments without Contract.';

                    trigger OnAction()
                    var
                        ServCommWOCustContract: Page "Serv. Comm. WO Cust. Contract";
                    begin
                        ServCommWOCustContract.SetCustomerContractNo(Rec."No.");
                        ServCommWOCustContract.Run();
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
                        Rec.CreateBillingProposal()
                    end;
                }
                action(ExtendContract)
                {
                    Caption = 'Extend Contract';
                    ToolTip = 'Opens the action for creating a service object with services that directly extend the specified contracts.';
                    Image = AddAction;

                    trigger OnAction()
                    var
                        ExtendContractPage: Page "Extend Contract";
                    begin
                        ExtendContractPage.SetParameters(Rec."Sell-to Customer No.", Rec."No.", WorkDate(), true);
                        ExtendContractPage.LookupMode(true);
                        ExtendContractPage.RunModal();
                    end;
                }
                action(CreateContractRenewalQuote)
                {
                    Caption = 'Create Contract Renewal Quote';
                    Image = CreateDocuments;
                    ToolTip = 'Creates a Sales Quote for all valid Contract Lines as a Contract Renewal Quote.';

                    trigger OnAction()
                    var
                        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
                    begin
                        Clear(ContractRenewalMgt);
                        ContractRenewalMgt.StartContractRenewalFromContract(Rec);
                    end;
                }
                action(ShowSalesInvoices)
                {
                    Caption = 'Sales Invoices';
                    Image = SalesInvoice;
                    ToolTip = 'Show sales invoices.';

                    trigger OnAction()
                    begin
                        ContractsGeneralMgt.ShowUnpostedSalesDocument(Enum::"Sales Document Type"::Invoice, Rec);
                    end;
                }
                action(ShowSalesCreditMemos)
                {
                    Caption = 'Sales Credit Memos';
                    Image = SalesCreditMemo;
                    ToolTip = 'Show sales credit memos.';

                    trigger OnAction()
                    begin
                        ContractsGeneralMgt.ShowUnpostedSalesDocument(Enum::"Sales Document Type"::"Credit Memo", Rec);
                    end;
                }
                action(ShowPostedSalesInvoices)
                {
                    Caption = 'Posted Sales Invoices';
                    Image = ViewPostedOrder;
                    ToolTip = 'Show posted sales invoices.';

                    trigger OnAction()
                    begin
                        ContractsGeneralMgt.ShowPostedSalesInvoices(Rec);
                    end;
                }
                action(ShowPostedSalesCreditMemos)
                {
                    Caption = 'Posted Sales Credit Memos';
                    Image = PostedCreditMemo;
                    ToolTip = 'Show posted credit memos.';

                    trigger OnAction()
                    begin
                        ContractsGeneralMgt.ShowPostedSalesCreditMemos(Rec);
                    end;
                }
                action(ShowRenewalQuote)
                {
                    Caption = 'Renewal Quotes';
                    Image = Quote;
                    ToolTip = 'Show Renewal Quotes.';

                    trigger OnAction()
                    var
                        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
                    begin
                        ContractRenewalMgt.ShowRenewalSalesDocumentForContract("Sales Document Type"::Quote, Rec."No.");
                    end;
                }
                action(ShowRenewalOrder)
                {
                    Caption = 'Renewal Order';
                    Image = Order;
                    ToolTip = 'Show Contract Renewal Sales Order.';

                    trigger OnAction()
                    var
                        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
                    begin
                        ContractRenewalMgt.ShowRenewalSalesDocumentForContract("Sales Document Type"::Order, Rec."No.");
                    end;
                }
            }
            group(Print)
            {
                Caption = 'Print';
                action(OverviewOfContractComponents)
                {
                    Caption = 'Overview of contract components';
                    ToolTip = 'Show a detailed list of services for the selected contract.';
                    Image = QualificationOverview;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        CustomerContract: Record "Customer Contract";
                        OverviewOfContractComponent: Report "Overview Of Contract Comp";
                    begin
                        CustomerContract.SetRange("No.", Rec."No.");
                        OverviewOfContractComponent.SetIncludeInactiveCustomerContracts(true);
                        OverviewOfContractComponent.SetTableView(CustomerContract);
                        OverviewOfContractComponent.Run();
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
                actionref(ExtendContract_Promoted; ExtendContract)
                {
                }
                actionref(CreateContractRenewalQuote_Promoted; CreateContractRenewalQuote)
                {
                }
            }
            group(Category_Category4)
            {
                Caption = 'Navigate';

                actionref(Customer_Promoted; Customer)
                {
                }
                actionref(ShowSalesInvoices_Promoted; ShowSalesInvoices)
                {
                }
                actionref(ShowSalesCreditMemos_Promoted; ShowSalesCreditMemos)
                {
                }
                actionref(ShowPostedSalesInvoices_Promoted; ShowPostedSalesInvoices)
                {
                }
                actionref(ShowPostedSalesCreditMemos_Promoted; ShowPostedSalesCreditMemos)
                {
                }
                actionref(ShowRenewalQuote_Promoted; ShowRenewalQuote)
                {
                }
                actionref(ShowRenewalOrder_Promoted; ShowRenewalOrder)
                {
                }
            }
            group(Category_Category5)
            {
                Caption = 'Contract';

                actionref(Dimensions_Promoted; Dimensions)
                {
                }
                actionref("Customer Contract Deferrals_Promoted"; "Customer Contract Deferrals")
                {
                }
                actionref(UpdateDimensionsInDeferrals_Promoted; UpdateDimensionsInDeferrals)
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Print';
                actionref(OverviewOfContractComponent; OverviewOfContractComponents) { }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetControlVisibility();
        UpdateShipToBillToGroupVisibility();
        DescriptionText := Rec.GetDescription();
        UpdateBillToFieldsEnabled();
        SellToContactEditable := Rec."Sell-to Customer No." <> '';
        UpdateDimensionsInDeferralsEnabled := Rec.NotReleasedCustomerContractDeferralsExists();
        ContractTypeSetAsHarmonizedBilling := Rec.IsContractTypeSetAsHarmonizedBilling();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if (Rec."Sell-to Customer No." = '') and (Rec.GetFilter("Sell-to Customer No.") <> '') then
            CurrPage.Update(false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        xRec.Init();
        if (not DocNoVisible) and (Rec."No." = '') then
            Rec.SetSellToCustomerFromFilter();

        UpdateShipToBillToGroupVisibility();
    end;

    trigger OnOpenPage()
    begin
        ActivateFields();

        SetDocNoVisible();
    end;

    var
        CustomerMgt: Codeunit "Customer Mgt.";
        FormatAddress: Codeunit "Format Address";
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
        DocNoVisible: Boolean;
        EmptyShipToCodeErr: Label 'The Code field can only be empty if you select Custom Address in the Ship-to field.';
        IsCustomerOrContactNotEmpty: Boolean;
        DescriptionText: Text;
        IsBillToCountyVisible: Boolean;
        IsSellToCountyVisible: Boolean;
        IsShipToCountyVisible: Boolean;
        BillToFieldsEnabled: Boolean;
        SellToContactEditable: Boolean;
        UpdateDimensionsInDeferralsEnabled: Boolean;

    protected var
        ShipToOptions: Enum "Sales Ship-to Options";
        ContractTypeSetAsHarmonizedBilling: Boolean;
        BillToOptions: Enum "Sales Bill-to Options";

    local procedure ActivateFields()
    begin
        IsBillToCountyVisible := FormatAddress.UseCounty(Rec."Bill-to Country/Region Code");
        IsSellToCountyVisible := FormatAddress.UseCounty(Rec."Sell-to Country/Region Code");
        IsShipToCountyVisible := FormatAddress.UseCounty(Rec."Ship-to Country/Region Code");
    end;

    local procedure SetDocNoVisible()
    begin
        DocNoVisible := Rec."No." = '';
    end;

    local procedure SetControlVisibility()
    begin
        IsCustomerOrContactNotEmpty := (Rec."Sell-to Customer No." <> '') or (Rec."Sell-to Contact No." <> '');
    end;

    local procedure UpdateShipToBillToGroupVisibility()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.TransferFields(Rec);
        CustomerMgt.CalculateShipBillToOptions(ShipToOptions, BillToOptions, SalesHeader);
    end;

    local procedure UpdateBillToFieldsEnabled()
    begin
        BillToFieldsEnabled := (BillToOptions = BillToOptions::"Custom Address") or (Rec."Bill-to Customer No." <> Rec."Sell-to Customer No.");
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeValidateShipToOptions(var CustomerContract: Record "Customer Contract"; ShipToOptions: Enum "Sales Ship-to Options"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterValidateShippingOptions(var CustomerContract: Record "Customer Contract"; ShipToOptions: Enum "Sales Ship-to Options")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnValidateShipToOptionsOnAfterShipToAddressListGetRecord(var ShipToAddress: Record "Ship-to Address"; var CustomerContract: Record "Customer Contract")
    begin
    end;
}

