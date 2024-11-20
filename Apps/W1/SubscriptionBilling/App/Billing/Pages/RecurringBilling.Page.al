namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using Microsoft.Finance.Dimension;

page 8067 "Recurring Billing"
{
    ApplicationArea = All;
    Caption = 'Recurring Billing';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Billing Line";
    SourceTableTemporary = true;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(BillingTemplateFilter)
            {
                Caption = 'Filter';
                field(BillingTemplateField; BillingTemplate.Code)
                {
                    Caption = 'Billing Template';
                    ToolTip = 'Specifies the name of the template that is used to calculate billable services.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupBillingTemplate();
                    end;

                    trigger OnValidate()
                    begin
                        FindBillingTemplate();
                    end;
                }
                field(BillingDateField; BillingDate)
                {
                    Caption = 'Billing Date';
                    ToolTip = 'Specifies the date up to which the billable services will be taken into account.';
                }
                field(BillingToDateField; BillingToDate)
                {
                    Caption = 'Billing to Date';
                    ToolTip = 'Specifies the optional date up to which the billable services should be charged.';
                }
            }
            repeater(BillingLines)
            {
                ShowAsTree = true;
                IndentationColumn = Rec.Indent;
                TreeInitialState = CollapseAll;

                field("Partner No."; Rec."Partner No.")
                {
                    ToolTip = 'Specifies the number of the partner who will receive the contractual services and be billed by default.';
                    StyleExpr = LineStyleExpr;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenPartnerCard(Rec.Partner, Rec."Partner No.");
                        InitTempTable();
                    end;
                }
                field("Partner Name"; PartnerNameTxt)
                {
                    Caption = 'Partner Name';
                    ToolTip = 'Specifies the name of the partner who will receive the contractual services and be billed by default.';
                    StyleExpr = LineStyleExpr;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenPartnerCard(Rec.Partner, Rec."Partner No.");
                        InitTempTable();
                    end;
                }
                field("Contract No."; Rec."Contract No.")
                {
                    ToolTip = 'Specifies the number of the Contract No.';
                    StyleExpr = LineStyleExpr;

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenContractCard(Rec.Partner, Rec."Contract No.");
                        InitTempTable();
                    end;
                }
                field(ContractDescriptionField; ContractDescriptionTxt)
                {
                    Caption = 'Contract Description';
                    ToolTip = 'Specifies the products or service being offered.';
                    Editable = false;
                    StyleExpr = LineStyleExpr;

                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenContractCard(Rec.Partner, Rec."Contract No.");
                        InitTempTable();
                    end;
                }
                field("Billing from"; Rec."Billing from")
                {
                    ToolTip = 'Specifies the date from which the service is billed.';
                    StyleExpr = LineStyleExpr;
                }
                field("Billing to"; Rec."Billing to")
                {
                    ToolTip = 'Specifies the date to which the service is billed.';
                    StyleExpr = LineStyleExpr;
                }
                field("Service Amount"; Rec."Service Amount")
                {
                    ToolTip = 'Specifies the amount for the service including discount.';
                    StyleExpr = LineStyleExpr;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the Unit Price for the service billing period without discount.';
                    StyleExpr = LineStyleExpr;
                    BlankZero = true;
                }
                field("Service Object Quantity"; Rec."Service Obj. Quantity Decimal")
                {
                    ToolTip = 'Quantity from service object.';
                    StyleExpr = LineStyleExpr;
                    BlankZero = true;
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the Discount % for the service billing period.';
                    StyleExpr = LineStyleExpr;
                }
                field("Service Commitment Description"; Rec."Service Commitment Description")
                {
                    ToolTip = 'Specifies the description of the service.';
                    StyleExpr = LineStyleExpr;
                }
                field("Billing Rhythm"; Rec."Billing Rhythm")
                {
                    ToolTip = 'Specifies the Dateformula for rhythm in which the service is invoiced. Using a Dateformula rhythm can be, for example, a monthly, a quarterly or a yearly invoicing.';
                    StyleExpr = LineStyleExpr;
                }
                field("Update Required"; Rec."Update Required")
                {
                    ToolTip = 'Specifies whether the associated service has been changed. The "Create Billing Proposal" function must be called up again before the billing document is created.';
                    StyleExpr = LineStyleExpr;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Shows the document type of the document created for posting.';
                    StyleExpr = LineStyleExpr;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Shows the document number of the document created for posting.';
                    StyleExpr = LineStyleExpr;

                    trigger OnDrillDown()
                    begin
                        Rec.OpenDocumentCard();
                        InitTempTable();
                    end;
                }
                field("Service Start Date"; Rec."Service Start Date")
                {
                    ToolTip = 'Specifies the date from which the service is valid and will be invoiced.';
                    StyleExpr = LineStyleExpr;
                }
                field("Service End Date"; Rec."Service End Date")
                {
                    ToolTip = 'Specifies the date up to which the service is valid.';
                    StyleExpr = LineStyleExpr;
                }
                field("Service Object No."; Rec."Service Object No.")
                {
                    ToolTip = 'Specifies the number of the service object no.';
                    StyleExpr = LineStyleExpr;

                    trigger OnDrillDown()
                    begin
                        ServiceObject.OpenServiceObjectCard(Rec."Service Object No.");
                        InitTempTable();
                    end;
                }
                field("Service Object Description"; Rec."Service Object Description")
                {
                    ToolTip = 'Specifies a description of the service object.';
                    StyleExpr = LineStyleExpr;
                }
                field("Billing Template Code"; Rec."Billing Template Code")
                {
                    ToolTip = 'Specifies the template code.';
                    StyleExpr = LineStyleExpr;
                    Visible = false;
                }
                field(Discount; Rec.Discount)
                {
                    ToolTip = 'Specifies whether the Service Commitment is used as a basis for periodic invoicing or discounts.';
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Shows the user who created the line.';
                    StyleExpr = LineStyleExpr;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateBillingProposalAction)
            {
                Caption = 'Create Billing Proposal';
                Image = Process;
                ToolTip = 'Suggests the services to be billed based on the selected billing template. The billing proposal can be supplemented by changing the billing template and calling it up again.';

                trigger OnAction()
                begin
                    BillingProposal.CreateBillingProposal(BillingTemplate.Code, BillingDate, BillingToDate);
                    InitTempTable();
                end;
            }
            action(CreateDocuments)
            {
                Caption = 'Create Documents';
                Image = CreateDocuments;
                Scope = Page;
                ToolTip = 'The action creates contract invoices or credit memos for the billing lines displayed on this page.';

                trigger OnAction()
                var
                    ErrorMessageMgt: Codeunit "Error Message Management";
                    ErrorMessageHandler: Codeunit "Error Message Handler";
                    ErrorContextElement: Codeunit "Error Context Element";
                    IsSuccess: Boolean;
                begin
                    ErrorMessageMgt.Activate(ErrorMessageHandler);
                    ErrorMessageMgt.PushContext(ErrorContextElement, 0, 0, '');
                    Commit(); //commit to database before processing
                    IsSuccess := Codeunit.Run(Codeunit::"Create Billing Documents", Rec);
                    if not IsSuccess then
                        ErrorMessageHandler.ShowErrors();
                    InitTempTable();
                end;
            }
            action(ClearBillingProposalAction)
            {
                Caption = 'Clear Billing Proposal';
                Image = CancelAllLines;
                ToolTip = 'Deletes the current billing proposal in whole or in part.';

                trigger OnAction()
                begin
                    BillingProposal.DeleteBillingProposal(BillingTemplate.Code);
                    InitTempTable();
                end;
            }
            action(DeleteDocuments)
            {
                Caption = 'Delete Documents';
                Image = Delete;
                ToolTip = 'Deletes all contract invoices und credit memos.';

                trigger OnAction()
                begin
                    BillingProposal.DeleteBillingDocuments();
                    InitTempTable();
                end;
            }
            action(ChangeBillingToAction)
            {
                Caption = 'Change Billing To Date';
                Image = ChangeDate;
                Scope = Repeater;
                ToolTip = 'This can be used to change the end of billing.';

                trigger OnAction()
                var
                    BillingLine: Record "Billing Line";
                    ChangeDate: Page "Change Date";
                    NewBillingToDate: Date;
                begin
                    if BillingDate <> 0D then
                        ChangeDate.SetDate(BillingDate);
                    if ChangeDate.RunModal() = Action::OK then
                        NewBillingToDate := ChangeDate.GetDate()
                    else
                        exit;
                    CurrPage.SetSelectionFilter(BillingLine);
                    BillingProposal.UpdateBillingToDate(BillingLine, NewBillingToDate);
                    InitTempTable();
                end;
            }
            action(DeleteBillingLineAction)
            {
                Caption = 'Delete Billing Line';
                Image = Delete;
                Scope = Page;
                ToolTip = 'This can be used to delete selected billing lines.';

                trigger OnAction()
                var
                    BillingLine: Record "Billing Line";
                begin
                    CurrPage.SetSelectionFilter(BillingLine);
                    BillingProposal.DeleteBillingLines(BillingLine);
                    InitTempTable();
                end;
            }
            action(Refresh)
            {
                Caption = 'Refresh';
                Image = Refresh;
                Scope = Page;
                ToolTip = 'Refreshes the current view.';
                ShortcutKey = 'F5';

                trigger OnAction()
                begin
                    InitTempTable();
                end;
            }
        }

        area(Navigation)
        {
            action(OpenPartnerAction)
            {
                Caption = 'Customer/Vendor';
                Image = Customer;
                Scope = Repeater;
                ToolTip = 'Opens the Customer/Vendor card.';

                trigger OnAction()
                begin
                    ContractsGeneralMgt.OpenPartnerCard(Rec.Partner, Rec."Partner No.");
                    InitTempTable();
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
                    InitTempTable();
                end;
            }
            action(OpenServiceObjectAction)
            {
                Caption = 'Service Object';
                Image = ServiceAgreement;
                Scope = Repeater;
                ToolTip = 'Opens the Service object card.';

                trigger OnAction()
                begin
                    ServiceObject.OpenServiceObjectCard(Rec."Service Object No.");
                    InitTempTable();
                end;
            }
            action(UsageData)
            {
                ApplicationArea = All;
                Caption = 'Usage Data';
                Image = DataEntry;
                Scope = Repeater;
                ToolTip = 'Shows the related usage data.';

                trigger OnAction()
                var
                    UsageDataBilling: Record "Usage Data Billing";
                begin
                    UsageDataBilling.SetRange("Billing Line Entry No.", Rec."Entry No.");
                    Page.RunModal(Page::"Usage Data Billings", UsageDataBilling);
                end;
            }
            action(Dimensions)
            {
                AccessByPermission = tabledata Dimension = R;
                ApplicationArea = Dimensions;
                Caption = 'Contract Line Dimensions';
                Image = Dimensions;
                Scope = Repeater;
                ShortcutKey = 'Shift+Ctrl+D';
                ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                trigger OnAction()
                begin
                    UpdateServiceCommitmentDimension();
                end;
            }
        }

        area(Promoted)
        {
            actionref(CreateBillingProposalAction_Promoted; CreateBillingProposalAction) { }
            actionref(CreateDocuments_Promoted; CreateDocuments) { }
            actionref(ClearBillingProposalAction_Promoted; ClearBillingProposalAction) { }
            actionref(DeleteDocuments_Promoted; DeleteDocuments) { }
            actionref(ChangeBillingToAction_Promoted; ChangeBillingToAction) { }
            actionref(DeleteBillingLineAction_Promoted; DeleteBillingLineAction) { }
            actionref(Refresh_Promoted; Refresh) { }

            group(Navigate_Promoted)
            {
                Caption = 'Navigate';

                actionref("UsageData_Promoted"; UsageData) { }
                actionref(OpenPartnerAction_Promoted; OpenPartnerAction) { }
                actionref(OpenContractAction_Promoted; OpenContractAction) { }
                actionref(OpenServiceObjectAction_Promoted; OpenServiceObjectAction) { }
                actionref(Dimensions_Promoted; Dimensions) { }
            }
        }
    }

    trigger OnOpenPage()
    begin
        FindBillingTemplate();
    end;

    trigger OnAfterGetRecord()
    begin
        ContractDescriptionTxt := ContractsGeneralMgt.GetContractDescription(Rec.Partner, Rec."Contract No.");
        PartnerNameTxt := ContractsGeneralMgt.GetPartnerName(Rec.Partner, Rec."Partner No.");
        SetLineStyleExpr();
    end;

    var
        BillingTemplate: Record "Billing Template";
        ServiceObject: Record "Service Object";
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
        BillingProposal: Codeunit "Billing Proposal";
        ContractDescriptionTxt: Text;
        PartnerNameTxt: Text;
        GroupBy: Enum "Contract Billing Grouping";

    protected var
        BillingDate: Date;
        BillingToDate: Date;
        LineStyleExpr: Text;

    local procedure LookupBillingTemplate()
    var
        BillingTemplate2: Record "Billing Template";
    begin
        BillingTemplate2 := BillingTemplate;
        if Page.RunModal(0, BillingTemplate2) = Action::LookupOK then begin
            BillingTemplate := BillingTemplate2;
            ApplyBillingTemplateFilter(BillingTemplate);
            InitTempTable();
        end;
    end;

    local procedure FindBillingTemplate()
    var
        SearchText: Text;
    begin
        SearchText := BillingTemplate.Code;
        if SearchText <> '' then begin
            BillingTemplate.SetRange(Code, SearchText);
            if not BillingTemplate.FindFirst() then begin
                SearchText := DelChr(SearchText, '<>', ' ');
                SearchText := DelChr(SearchText, '=', '()<>\');
                SearchText := '*' + SearchText + '*';
                BillingTemplate.SetFilter(Code, SearchText);
                if not BillingTemplate.FindFirst() then
                    Clear(BillingTemplate);
            end;
        end;
        if BillingTemplate.Get(BillingTemplate.Code) then
            ApplyBillingTemplateFilter(BillingTemplate);
        InitTempTable();
    end;

    local procedure ApplyBillingTemplateFilter(var BillingTemplate2: Record "Billing Template")
    begin
        if Format(BillingTemplate2."Billing Date Formula") <> '' then
            BillingDate := CalcDate(BillingTemplate2."Billing Date Formula", WorkDate())
        else
            BillingDate := WorkDate();

        if Format(BillingTemplate2."Billing to Date Formula") <> '' then
            BillingToDate := CalcDate(BillingTemplate2."Billing to Date Formula", WorkDate())
        else
            BillingToDate := 0D;

        if BillingTemplate2."My Suggestions Only" then
            Rec.SetRange("User ID", UserId())
        else
            Rec.SetRange("User ID");

        Rec.SetRange(Partner, BillingTemplate2.Partner);
        GroupBy := BillingTemplate2."Group by";
        OnAfterApplyBillingTemplateFilter(BillingTemplate2);
    end;

    local procedure SetLineStyleExpr()
    begin
        case true of
            Rec."Update Required":
                LineStyleExpr := 'Unfavorable';
            Rec.Indent = 0:
                LineStyleExpr := 'Strong';
            else
                LineStyleExpr := '';
        end;
    end;

    procedure InitTempTable()
    begin
        BillingProposal.InitTempTable(Rec, GroupBy);
        if Rec.FindFirst() then; //to enable CollapseAll
        CurrPage.Update(false);
    end;

    local procedure UpdateServiceCommitmentDimension()
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        ServiceCommitment.Get(Rec."Service Commitment Entry No.");
        ServiceCommitment.EditDimensionSet();
        CurrPage.Update();
    end;

    [InternalEvent(true, false)]
    local procedure OnAfterApplyBillingTemplateFilter(var SelectedBillingTemplate: Record "Billing Template")
    begin
    end;
}