namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;

page 8005 "Contract Renewal"
{
    ApplicationArea = All;
    Caption = 'Contract Renewal';
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Contract Renewal Line";
    SourceTableView = sorting("Linked to Contract No.", "Linked to Contract Line No.");
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            repeater(RenewalLines)
            {
                field("Linked to Contract No."; Rec."Linked to Contract No.")
                {
                    ToolTip = 'Specifies the number of the Customer Contract from which the entry originates. This also includes vendor-related services.';

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenContractCard(Rec.Partner, Rec."Contract No.");
                    end;
                }
                field("Service Object Description"; Rec."Service Object Description")
                {
                    ToolTip = 'Specifies a description of the service object.';
                }
                field("Service Commitment Description"; Rec."Service Commitment Description")
                {
                    ToolTip = 'Specifies the description of the service.';
                }
                field("Service Object No."; Rec."Service Object No.")
                {
                    ToolTip = 'Specifies the number of the service object.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        ServiceObject: Record "Service Object";
                    begin
                        ServiceObject.OpenServiceObjectCard(Rec."Service Object No.");
                    end;
                }
                field("Service End Date"; Rec."Service End Date")
                {
                    ToolTip = 'Specifies the date up to which the service is valid.';
                }
                field("Renewal Term"; Rec."Renewal Term")
                {
                    ToolTip = 'Specifies a date formula by which the Contract Line is renewed and the end of the Contract Line is extended. It is automatically preset with the initial term of the service and can be changed manually.';
                }
                field("Agreed Serv. Comm. Start Date"; Rec."Agreed Serv. Comm. Start Date")
                {
                    ToolTip = 'Specifies the individually agreed start of the service.';
                }
                field(Price; Rec.Price)
                {
                    ToolTip = 'Specifies the price of the service with quantity of 1 in the billing period. The price is calculated from Base Price and Base Price %.';
                }
                field("Service Amount"; Rec."Service Amount")
                {
                    ToolTip = 'Specifies the amount for the service including discount.';
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for the rhythm in which the service is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                }
                field("Contract No."; Rec."Contract No.")
                {
                    ToolTip = 'Specifies the number of the Contract.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenContractCard(Rec.Partner, Rec."Contract No.");
                    end;
                }
                field(ContractDescriptionField; ContractDescriptionTxt)
                {
                    Caption = 'Contract Description';
                    ToolTip = 'Specifies the products or service being offered.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenContractCard(Rec.Partner, Rec."Contract No.");
                    end;
                }
                field(Partner; Rec.Partner)
                {
                    ToolTip = 'Determines whether the template applies to customer or vendor contracts.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ToolTip = 'Shows the last error that occured when processing the line.';

                    trigger OnAssistEdit()
                    begin
                        if Rec."Error Message" <> '' then
                            Message(Rec."Error Message");
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetContractLines)
            {
                Caption = 'Get Contract Lines';
                Image = Process;
                ToolTip = 'Allows to filter contract lines in order to create Contract Renewal lines.';

                trigger OnAction()
                begin
                    Report.RunModal(Report::"Select Contract Renewal");
                end;
            }
            action(CreateContractRenewal)
            {
                Caption = 'Create Quotes';
                Image = CreateDocuments;
                Scope = Page;
                ToolTip = 'The action creates Contract Renewal Quotes (Sales Quotes) based on the lines.';

                trigger OnAction()
                var
                    ContractRenewalLine: Record "Contract Renewal Line";
                    CreateContractRenewal: Codeunit "Create Contract Renewal";
                    SelectionTxt: Text;
                    Selection: Integer;
                    Counter: array[2] of Integer;
                    SelectionLbl: Label 'All Lines (%1),Selected Lines (%2)';
                begin
                    ContractRenewalLine.Reset();
                    ContractRenewalLine.CopyFilters(Rec);
                    Counter[1] := ContractRenewalLine.Count();
                    ContractRenewalLine.Reset();
                    CurrPage.SetSelectionFilter(ContractRenewalLine);
                    Counter[2] := ContractRenewalLine.Count();
                    SelectionTxt := StrSubstNo(SelectionLbl, Counter[1], Counter[2]);

                    Selection := StrMenu(SelectionTxt, 1);
                    ContractRenewalLine.Reset();
                    ContractRenewalLine.CopyFilters(Rec);
                    case Selection of
                        0:
                            exit;
                        2:
                            CurrPage.SetSelectionFilter(ContractRenewalLine);
                    end;
                    Clear(CreateContractRenewal);
                    CreateContractRenewal.ClearCollectedSalesQuotes();
                    CreateContractRenewal.BatchCreateContractRenewal(ContractRenewalLine);
                end;
            }
            action(OpenContractAction)
            {
                Caption = 'Contract';
                Image = Document;
                Scope = Repeater;
                ToolTip = 'Opens the Contract card.';

                trigger OnAction()
                begin
                    ContractsGeneralMgt.OpenContractCard(Rec.Partner, Rec."Contract No.");
                end;
            }
            action(OpenServiceObjectAction)
            {
                Caption = 'Service Object';
                Image = ServiceAgreement;
                Scope = Repeater;
                ToolTip = 'Opens the Service object card.';

                trigger OnAction()
                var
                    ServiceObject: Record "Service Object";
                begin
                    ServiceObject.OpenServiceObjectCard(Rec."Service Object No.");
                end;
            }
            action(OpenSalesQuotes)
            {
                Caption = 'Sales Quotes';
                Image = ServiceAgreement;
                ToolTip = 'Opens the List of Sales Quotes.';
                RunObject = page "Sales Quotes";
            }
            action(OpenPlannedServiceCommitments)
            {
                Caption = 'Planned Service Commitments';
                Image = EntriesList;
                ToolTip = 'Opens the List of planned Service Commitments.';
                RunObject = page "Planned Service Commitments";
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(GetContractLines_Promoted; GetContractLines)
                {
                }
                actionref(CreateContractRenewal_Promoted; CreateContractRenewal)
                {
                }
                actionref(OpenContractAction_Promoted; OpenContractAction)
                {
                }
                actionref(OpenServiceObjectAction_Promoted; OpenServiceObjectAction)
                {
                }
                actionref(OpenSalesQuotes_Promoted; OpenSalesQuotes)
                {
                }
                actionref(OpenPlannedServiceCommitments_Promoted; OpenPlannedServiceCommitments)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ContractDescriptionTxt := ContractsGeneralMgt.GetContractDescription(Rec.Partner, Rec."Contract No.");
    end;

    var
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
        ContractDescriptionTxt: Text;
}