page 1937 "GP Account Options"
{
    Caption = 'Chart of Account Options';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    ShowFilter = false;

    layout
    {
        area(content)
        {
            group("ParentDescription")
            {
                Visible = ShowButton;
                group("Specify the chart of accounts to use")
                {
                    field(Instruction1; Instruction1Txt)
                    {
                        ApplicationArea = Basic, Suite;
                        MultiLine = true;
                        ShowCaption = false;
                        Editable = false;
                    }
                    field(BlankLine; BlankLineTxt)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        Caption = '';
                    }
                    field(UseExistingCOA; UseExistingAccounts)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Use the Existing Chart of Accounts';
                        ToolTip = 'Use the Chart of Accounts from Dynamics GP (Segments will migrate as dimensions)';
                        trigger OnValidate();
                        var
                        begin
                            if UseExistingAccounts then begin
                                CreateNewAccounts := false;
                                NextEnabled := true;
                            end;
                            if not UseExistingAccounts and not CreateNewAccounts then
                                NextEnabled := false;
                            SetCOAOption();
                        end;
                    }
                    field(CreateNewCOA; CreateNewAccounts)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Create a New Chart of Accounts';
                        ToolTip = 'Create a New Chart of Accounts in Business Central';
                        trigger OnValidate();
                        var
                        begin
                            if CreateNewAccounts then begin
                                UseExistingAccounts := false;
                                NextEnabled := true;
                            end;
                            if not UseExistingAccounts and not CreateNewAccounts then
                                NextEnabled := false;
                            SetCOAOption();
                        end;
                    }

                    field(BlankLine2; BlankLine2Txt)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        Caption = '';
                    }

                }
                group("Specify your posting option")
                {
                    Visible = ShowButton;
                    field(Instruction2; Instruction2Txt)
                    {
                        ApplicationArea = Basic, Suite;
                        MultiLine = true;
                        ShowCaption = false;
                        Editable = false;
                    }
                    field(PostTransactions; PostJournalTransactions)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Post General Journal Transactions';
                        ToolTip = 'Post General Journal Transactions when the migration has successfully completed';
                        trigger OnValidate();
                        var
                        begin

                        end;
                    }
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
                    CurrPage.Close();
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
                    SetChartofAccountOption(UseExistingAccounts, CreateNewAccounts);
                    SetPostingOption(PostJournalTransactions);
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage();
    var
        MigrationGPConfig: Record "MigrationGP Config";
    begin
        MigrationGPConfig.GetSingleInstance();
        if MigrationGPConfig."Chart of Account Option" = MigrationGPConfig."Chart of Account Option"::" " then begin
            UseExistingAccounts := false;
            CreateNewAccounts := false;
        end;
        if MigrationGPConfig."Chart of Account Option" = MigrationGPConfig."Chart of Account Option"::Existing then begin
            UseExistingAccounts := true;
            CreateNewAccounts := false;
        end;
        if MigrationGPConfig."Chart of Account Option" = MigrationGPConfig."Chart of Account Option"::New then begin
            UseExistingAccounts := false;
            CreateNewAccounts := true;
        end;

        BackEnabled := false;
        NextEnabled := false;
        ShowPage := true;
        ShowButton := true;
        Instruction1Txt := 'Use the chart of accounts from Dynamics GP, or create a new one and use an Excel worksheet to map the account numbers. The worksheet is available in the next step.\\Note: If you use the chart of accounts from Dynamics GP, we will convert some of the segments to dimensions. For more information, see Dynamics GP Data Migration Extension.';
        Instruction2Txt := 'You can post general journal transactions to the general ledger right away, or do it later if you want to review them in Business Central first.';
    end;

    var
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        UseExistingAccounts: Boolean;
        CreateNewAccounts: Boolean;
        ShowPage: Boolean;
        ShowButton: Boolean;
        BlankLineTxt: Text;
        BlankLine2Txt: Text;
        Instruction1Txt: Text;
        Instruction2Txt: Text;
        PostJournalTransactions: Boolean;

    local procedure SetChartofAccountOption(Existing: Boolean; New: Boolean)
    var
        MigrationGPConfig: Record "MigrationGP Config";
    begin
        MigrationGPConfig.GetSingleInstance();
        If Existing then
            MigrationGPConfig."Chart of Account Option" := MigrationGPConfig."Chart of Account Option"::Existing;
        If New then
            MigrationGPConfig."Chart of Account Option" := MigrationGPConfig."Chart of Account Option"::New;
        MigrationGPConfig.Modify();
    end;

    local procedure SetPostingOption(PostTrxs: Boolean)
    var
        MigrationGPConfig: Record "MigrationGP Config";
    begin
        MigrationGPConfig.GetSingleInstance();
        MigrationGPConfig."Post Transactions" := PostTrxs;
        MigrationGPConfig.Modify();
    end;

    local procedure SetCOAOption()
    var
        MigrationGPConfig: Record "MigrationGP Config";
    begin
        if not UseExistingAccounts and not CreateNewAccounts then
            MigrationGPConfig."Chart of Account Option" := MigrationGPConfig."Chart of Account Option"::" ";
        if UseExistingAccounts then
            MigrationGPConfig."Chart of Account Option" := MigrationGPConfig."Chart of Account Option"::Existing;
        if CreateNewAccounts then
            MigrationGPConfig."Chart of Account Option" := MigrationGPConfig."Chart of Account Option"::New;

        MigrationGPConfig.Modify();
    end;
}