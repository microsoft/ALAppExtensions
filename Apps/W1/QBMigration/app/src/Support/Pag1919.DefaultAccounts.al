page 1919 "MigrationQB Default Accounts"
{
    Caption = 'QuickBooks Migration Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    ShowFilter = false;

    layout
    {
        area(content)
        {
#if not CLEAN18
            group("Instructions")
            {
                Visible = false;
                ShowCaption = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'Instruction field is moved inside groups below. This group is no longer in use.';
                ObsoleteTag = '18.0';
            }
#endif
            group("Group2")
            {
                Visible = FirstGroupVisible;
                ShowCaption = false;
                field(Instructions1; Instruction1Txt)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    MultiLine = true;
                    ShowCaption = false;
                }
                field("Sales Account"; SalesAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Account';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Sales Credit Memo Account"; SalesCreditMemoAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Credit Memo Account';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Sales Line Disc. Account"; SalesLineDiscAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Line Disc. Account';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Sales Inv. Disc. Account"; SalesInvDiscAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Inv. Disc. Account';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("1"; '')
                {
                    Caption = '';
                    ShowCaption = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Purch. Account"; PurchAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purch. Account';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Purch. Credit Memo Account"; PurchCreditMemoAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purch. Credit Memo Account';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Purch. Line Disc. Account"; PurchLineDiscAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purch. Line Disc. Account';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Purch. Inv. Disc. Account"; PurchInvDiscAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purch. Inv. Disc. Account';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("2"; '')
                {
                    Caption = '';
                    ShowCaption = true;
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Group3")
            {
                Visible = SecondGroupVisible;
                ShowCaption = false;
                field(Instructions2; Instruction2Txt)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    MultiLine = true;
                    ShowCaption = false;
                }
                field("COGS Account"; COGSAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'COGS Account';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Inventory Adjmt. Account"; InventoryAdjmtAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory Adjmt. Account';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Inventory Account"; InventoryAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory Account';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("3"; '')
                {
                    Caption = '';
                    ShowCaption = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Receivables Account"; ReceivablesAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Receivables Account';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Service Charge Acc."; ServiceChargeAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Service Charge Acc.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("4"; '')
                {
                    Caption = '';
                    ShowCaption = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Payables Account"; PayablesAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payables Account';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Purch. Service Charge Acc."; PurchServiceChargeAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purch. Service Charge Acc.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
            }
            group("UofM")
            {
                Visible = ThirdGroupVisible;
                ShowCaption = false;
                field(Instructions3; Instruction3Txt)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    MultiLine = true;
                    ShowCaption = false;
                }
                field("Unit Of Measure"; UnitOfMeasure)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Unit of Measure';
                    TableRelation = "Unit of Measure";

                    trigger OnValidate();
                    var
                    begin
                        if (UnitOfMeasure <> '') then
                            NextEnabled := true
                        else
                            NextEnabled := false;
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Back';
                Enabled = BackEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Next';
                Enabled = NextEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
        }
    }

    trigger OnClosePage();
    begin
        SetAccountNumbers();
    end;

    trigger OnOpenPage();
    begin
        ShowPageOne();
    end;

    var
        SalesAccount: Code[20];
        SalesCreditMemoAccount: Code[20];
        SalesLineDiscAccount: Code[20];
        SalesInvDiscAccount: Code[20];
        PurchAccount: Code[20];
        PurchCreditMemoAccount: Code[20];
        PurchLineDiscAccount: Code[20];
        PurchInvDiscAccount: Code[20];
        COGSAccount: Code[20];
        InventoryAdjmtAccount: Code[20];
        InventoryAccount: Code[20];
        ReceivablesAccount: Code[20];
        ServiceChargeAccount: Code[20];
        PayablesAccount: Code[20];
        PurchServiceChargeAccount: Code[20];
        UnitOfMeasure: Code[20];
        FirstGroupVisible: Boolean;
        SecondGroupVisible: Boolean;
        ThirdGroupVisible: Boolean;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        Step: Option PageOne,PageTwo,PageThree,Done;
        Instruction1Txt: Label 'Enter the accounts to use when you post sales and purchase transactions to the general ledger.';
        Instruction2Txt: Label 'Enter the accounts to use when you post transactions for items, and for the sale or purchase of services.';
        Instruction3Txt: Label 'Choose the unit of measure to assign to all inventory and service items that you import.';

    local procedure ShowPageOne()
    begin
        Step := Step::PageOne;
        BackEnabled := true;
        NextEnabled := true;
        FirstGroupVisible := true;
        SecondGroupVisible := false;
        ThirdGroupVisible := false;
    end;

    local procedure ShowPageTwo()
    begin
        BackEnabled := true;
        NextEnabled := true;
        FirstGroupVisible := false;
        SecondGroupVisible := true;
        ThirdGroupVisible := false;
    end;

    local procedure ShowPageThree()
    begin
        if not UofMRequired() then
            NextStep(false);

        if (UnitOfMeasure <> '') then
            NextEnabled := true
        else
            NextEnabled := false;

        BackEnabled := true;
        FirstGroupVisible := false;
        SecondGroupVisible := false;
        ThirdGroupVisible := true;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        case Step of
            Step::PageOne:
                ShowPageOne();
            Step::PageTwo:
                ShowPageTwo();
            Step::PageThree:
                ShowPageThree();
            Step::Done:
                CurrPage.Close();
        end;
        CurrPage.Update(true);
    end;

    procedure SetAccountNumbers();
    var
        MigrationQBAccountSetup: Record "MigrationQB Account Setup";
    begin
        MigrationQBAccountSetup.DeleteAll();

        MigrationQBAccountSetup.Init();
        MigrationQBAccountSetup.SalesAccount := SalesAccount;
        MigrationQBAccountSetup.SalesCreditMemoAccount := SalesCreditMemoAccount;
        MigrationQBAccountSetup.SalesInvDiscAccount := SalesInvDiscAccount;
        MigrationQBAccountSetup.SalesLineDiscAccount := SalesLineDiscAccount;

        MigrationQBAccountSetup.PurchAccount := PurchAccount;
        MigrationQBAccountSetup.PurchCreditMemoAccount := PurchCreditMemoAccount;
        MigrationQBAccountSetup.PurchLineDiscAccount := PurchLineDiscAccount;
        MigrationQBAccountSetup.PurchInvDiscAccount := PurchInvDiscAccount;

        MigrationQBAccountSetup.COGSAccount := COGSAccount;
        MigrationQBAccountSetup.InventoryAdjmtAccount := InventoryAdjmtAccount;
        MigrationQBAccountSetup.InventoryAccount := InventoryAccount;

        MigrationQBAccountSetup.ReceivablesAccount := ReceivablesAccount;
        MigrationQBAccountSetup.ServiceChargeAccount := ServiceChargeAccount;

        MigrationQBAccountSetup.PayablesAccount := PayablesAccount;
        MigrationQBAccountSetup.PurchServiceChargeAccount := PurchServiceChargeAccount;

        MigrationQBAccountSetup.UnitOfMeasure := UnitOfMeasure;

        MigrationQBAccountSetup.Insert();
        Commit();
    end;

    local procedure UofMRequired(): Boolean
    var
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        Number: Integer;
    begin
        HelperFunctions.GetObjectCount('Item', Number);
        if Number > 0 then
            exit(true);

        exit(false);
    end;
}

