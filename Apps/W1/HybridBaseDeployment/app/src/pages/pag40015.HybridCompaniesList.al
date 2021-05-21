page 40015 "Hybrid Companies List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Hybrid Company";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Companies)
            {
                ShowCaption = false;

                field("Name"; Rec."Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the company.';
                    Visible = true;
                    Editable = false;
                    StyleExpr = FieldStyleTxt;
                }
                field("Display Name"; Rec."Display Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the display name of the company.';
                    Visible = true;
                    Editable = false;
                }

                field("Replicate"; Rec."Replicate")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Replicate';
                    Visible = false;
                    Tooltip = 'Specifies whether to migrate the data from this company.';
                    Editable = true;
                }

                field("Company Initialization Status"; Rec."Company Initialization Status")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Company Initialization Status';
                    Tooltip = 'Specifies whether the company was successfully initialized or not.';
                    StyleExpr = FieldStyleTxt;
                    Editable = false;
                }

                field("Company Initialization Failure"; CompanyInitializationFailureTxt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Company Initialization Failure';
                    Tooltip = 'Specifies the failure message for the company initialization.';
                    StyleExpr = FieldStyleTxt;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(InitializeCompany)
            {
                ApplicationArea = All;
                Caption = 'Schedule company intialization';
                ToolTip = 'Creates a job to initialize the company. You cannot make any modifications to the company until the task completes.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Setup;

                trigger OnAction()
                var
                    HybridCompanyInitialize: Codeunit "Hybrid Company Initialize";
                begin
                    if not Confirm(RunCompanyInitQst) then
                        exit;

                    HybridCompanyInitialize.InitalizeCompany(Rec);
                    Message(CompanyInitializationScheduledMsg);
                end;
            }

            action(RefreshStatus)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Refresh Status';
                ToolTip = 'Get the latest information about how company initialization is going.';
                Promoted = true;
                PromotedCategory = Process;
                Image = RefreshLines;

                trigger OnAction()
                begin
                    CurrPage.Update();
                end;
            }

            action(MarkCompanyAsInitialized)
            {
                ApplicationArea = All;
                Caption = 'Mark company as initialized';
                ToolTip = 'Updates the company to mark it as initialized. Use this action if the company is already initialized.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Approve;

                trigger OnAction()
                var
                    HybridCompanyInitialize: Codeunit "Hybrid Company Initialize";
                begin
                    HybridCompanyInitialize.MarkCompanyAsInitialized(Rec);
                end;
            }

            action(MarkCompanyAsNotInitialized)
            {
                ApplicationArea = All;
                Caption = 'Mark company as not initialized';
                ToolTip = 'Updates the company to mark it as not yet initialized. Use this action if you want to schedule initialization again.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Reject;

                trigger OnAction()
                var
                    HybridCompanyInitialize: Codeunit "Hybrid Company Initialize";
                begin
                    HybridCompanyInitialize.MarkCompanyAsNotInitialized(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec."Company Initialization Status" = Rec."Company Initialization Status"::"Initialization Failed" then
            CompanyInitializationFailureTxt := Rec.GetCompanyInitFailureMessage();

        if Rec."Company Initialization Status" <> Rec."Company Initialization Status"::Initialized then
            FieldStyleTxt := 'Unfavorable'
        else
            FieldStyleTxt := 'Standard';
    end;

    var
        CompanyInitializationFailureTxt: Text;
        FieldStyleTxt: Text;
        CompanyInitializationScheduledMsg: Label 'Company initialization has been scheduled.';
        RunCompanyInitQst: Label 'This will start the process of company initialization. Do you want to continue?';
}