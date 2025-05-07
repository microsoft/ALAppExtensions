namespace Microsoft.SubscriptionBilling;

page 8025 "Contract Price Update"
{
    ApplicationArea = All;
    Caption = 'Subscription Contract Price Update';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Sub. Contr. Price Update Line";
    SourceTableTemporary = true;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(PriceUpdateTemplateFilter)
            {
                Caption = 'Filter';
                field(PriceUpdateTemplateCode; PriceUpdateTemplate.Code)
                {
                    Caption = 'Price Update Template';
                    ToolTip = 'Specifies the name of the template that is used to calculate the price updates.';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupPriceUpdateTemplate();
                    end;

                    trigger OnValidate()
                    begin
                        FindPriceUpdateTemplate();
                    end;
                }
                field(PerformUpdateOnDate; PerformUpdateOnDate)
                {
                    Caption = 'Perform Update On';
                    ToolTip = 'Specifies the date, the price update will take affect if no date is specified in the contract line. If empty the "Next Price Update" of the contract line is used.';
                }
                field(IncludeContractLinesUpToDate; IncludeServiceCommitmentUpToDate)
                {
                    Caption = 'Include Contract Lines Up To Date';
                    ToolTip = 'Specifies the date up to which contract lines are included. If the Next Price Update is before this date the contract line will be included in the price update.';
                }
            }
            repeater(General)
            {
                ShowAsTree = true;
                IndentationColumn = Rec.Indent;
                TreeInitialState = CollapseAll;
                field("Partner Name"; Rec."Partner Name")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the name of the partner who will receive the contract components and be billed by default.';
                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenPartnerCard(Rec.Partner, Rec."Partner No.");
                        InitTempTable();
                    end;
                }
                field("Contract No."; Rec."Subscription Contract No.")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the number of the Contract.';
                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenContractCard(Rec.Partner, Rec."Subscription Contract No.");
                        InitTempTable();
                    end;
                }
                field("Contract Description"; Rec."Sub. Contract Description")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the description of the Contract.';
                    trigger OnDrillDown()
                    begin
                        ContractsGeneralMgt.OpenContractCard(Rec.Partner, Rec."Subscription Contract No.");
                        InitTempTable();
                    end;
                }
                field("Service Commitment Description"; Rec."Subscription Line Description")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies a description of the Subscription Line.';
                }
                field(OldPrice; Rec."Old Price")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the current Price of the contract line.';
                }
                field(NewPrice; Rec."New Price")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the new price after the price update.';
                }
                field(AdditionalServiceAmount; Rec."Additional Amount")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the additional amount, which will be charged after the price update.';
                }
                field(OldServiceAmount; Rec."Old Amount")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the current Amount of the contract line.';
                }
                field(NewServiceAmount; Rec."New Amount")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the new Amount after the price update.';
                }
                field("Perform Update On"; Rec."Perform Update On")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the date, the price update will take affect.';
                }
                field("Service Object No."; Rec."Subscription Header No.")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the number of the Subscription.';
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the quantity from the Subscription.';
                    Visible = false;
                }
                field("Service Object Description"; Rec."Subscription Description")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies a description of the Subscription.';
                    Visible = false;
                }
                field("Discount %"; Rec."Discount %")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the Discount % for the subscription line billing period.';
                    Visible = false;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the amount of the discount for the Subscription Line.';
                    Visible = false;
                }
                field("Next Price Update"; Rec."Next Price Update")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the date for the next possible price update.';
                    Visible = false;
                }
                field(OldCalculationBase; Rec."Old Calculation Base")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the current base amount from which the price will be calculated.';
                    Visible = false;
                }
                field(NewCalculationBase; Rec."New Calculation Base")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the new base amount from which the price will be calculated.';
                    Visible = false;
                }
                field(OldCalculationBasePerc; Rec."Old Calculation Base %")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the old percent at which the price of the Subscription Line will be calculated. 100% means that the price corresponds to the Base Price.';
                    Visible = false;
                }
                field(NewCalculationBasePerc; Rec."New Calculation Base %")
                {
                    StyleExpr = LineStyleExpr;
                    ToolTip = 'Specifies the old percent at which the price of the Subscription Line will be calculated. 100% means that the price corresponds to the Base Price.';
                    Visible = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(CreateProposalAction)
            {
                Caption = 'Create Proposal';
                Image = Process;
                ToolTip = 'Creates a proposal for a price update based on the currently selected template.';
                trigger OnAction()
                begin
                    PriceUpdateManagement.CreatePriceUpdateProposal(PriceUpdateTemplate.Code, IncludeServiceCommitmentUpToDate, PerformUpdateOnDate);
                    InitTempTable();
                end;
            }
            action(DeleteProposalAction)
            {
                Caption = 'Delete Proposal';
                Image = CancelAllLines;
                ToolTip = 'Deletes all lines in the Contract Price Update page.';
                trigger OnAction()
                begin
                    PriceUpdateManagement.DeleteProposal(PriceUpdateTemplate.Code);
                    InitTempTable();
                end;
            }
            action(PerformPriceUpdateAction)
            {
                Caption = 'Perform Price Update';
                Image = Process;
                ToolTip = 'Performs the Price Update. If the contract line has been invoiced up to the "Next Price Update", the price will be changed directly. Otherwise a Planned Subscription Line will be created.';
                trigger OnAction()
                begin
                    PriceUpdateManagement.PerformPriceUpdate();
                    InitTempTable();
                end;
            }
            action(DeleteLineAction)
            {
                Caption = 'Delete Line';
                Image = Delete;
                Scope = Repeater;
                ToolTip = 'Deletes the selected line.';
                trigger OnAction()
                var
                    ContractPriceUpdateLine: Record "Sub. Contr. Price Update Line";
                begin
                    CurrPage.SetSelectionFilter(ContractPriceUpdateLine);
                    PriceUpdateManagement.DeleteContractPriceUpdateLines(ContractPriceUpdateLine);
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
        area(Promoted)
        {
            actionref(CreateProposalAction_Promoted; CreateProposalAction) { }
            actionref(PerformPriceUpdateAction_Promoted; PerformPriceUpdateAction) { }
            actionref(DeleteProposalAction_Promoted; DeleteProposalAction) { }
            actionref(DeleteLineAction_Promoted; DeleteLineAction) { }
        }

    }
    trigger OnOpenPage()
    begin
        FindPriceUpdateTemplate();
    end;

    trigger OnAfterGetRecord()
    begin
        SetLineStyleExpr();
    end;

    local procedure LookupPriceUpdateTemplate()
    var
        PriceUpdateTemplate2: Record "Price Update Template";
    begin
        PriceUpdateTemplate2 := PriceUpdateTemplate;
        if Page.RunModal(0, PriceUpdateTemplate2) = Action::LookupOK then begin
            PriceUpdateTemplate := PriceUpdateTemplate2;
            ApplyPriceUpdateTemplateFilter(PriceUpdateTemplate);
            InitTempTable();
        end;
    end;

    local procedure FindPriceUpdateTemplate()
    var
        SearchText: Text;
    begin
        SearchText := PriceUpdateTemplate.Code;
        if SearchText <> '' then begin
            PriceUpdateTemplate.SetRange(Code, SearchText);
            if not PriceUpdateTemplate.FindFirst() then begin
                SearchText := DelChr(SearchText, '<>', ' ');
                SearchText := DelChr(SearchText, '=', '()<>\');
                SearchText := '*' + SearchText + '*';
                PriceUpdateTemplate.SetFilter(Code, SearchText);
                if not PriceUpdateTemplate.FindFirst() then
                    Clear(PriceUpdateTemplate);
            end;
        end;
        if PriceUpdateTemplate.Get(PriceUpdateTemplate.Code) then
            ApplyPriceUpdateTemplateFilter(PriceUpdateTemplate);
        InitTempTable();
    end;

    local procedure InitTempTable()
    begin
        PriceUpdateManagement.InitTempTable(Rec, GroupBy);
        if Rec.FindFirst() then; //to enable CollapseAll
        CurrPage.Update(false);
    end;

    local procedure ApplyPriceUpdateTemplateFilter(var PriceUpdateTemplate2: Record "Price Update Template")
    begin
        if Format(PriceUpdateTemplate2.InclContrLinesUpToDateFormula) <> '' then
            IncludeServiceCommitmentUpToDate := CalcDate(PriceUpdateTemplate2.InclContrLinesUpToDateFormula, WorkDate())
        else
            IncludeServiceCommitmentUpToDate := 0D;

        PerformUpdateOnDate := CalcDate(PriceUpdateTemplate."Perform Update on Formula", WorkDate());

        Rec.SetRange(Partner, PriceUpdateTemplate2.Partner);
        GroupBy := PriceUpdateTemplate2."Group by";
    end;

    local procedure SetLineStyleExpr()
    begin
        if Rec.Indent = 0 then
            LineStyleExpr := 'Strong'
        else
            LineStyleExpr := '';
    end;

    var
        PriceUpdateTemplate: Record "Price Update Template";
        PriceUpdateManagement: Codeunit "Price Update Management";
        ContractsGeneralMgt: Codeunit "Sub. Contracts General Mgt.";
        IncludeServiceCommitmentUpToDate: Date;
        PerformUpdateOnDate: Date;
        GroupBy: Enum "Contract Billing Grouping";
        LineStyleExpr: Text;
}
