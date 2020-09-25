page 1940 "Additional Account Info"
{
    Caption = 'Additional Account Info';
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
                group("Map account numbers for the chart of accounts")
                {
                    field(Instructions1; Instructions)
                    {
                        ApplicationArea = Basic, Suite;
                        MultiLine = true;
                        ShowCaption = false;
                        Editable = false;
                    }
                    field(Instructions2; InstructionsTwo)
                    {
                        ApplicationArea = Basic, Suite;
                        MultiLine = true;
                        ShowCaption = false;
                        Editable = false;
                    }
                    field(Instructions3; InstructionsThree)
                    {
                        ApplicationArea = Basic, Suite;
                        MultiLine = true;
                        ShowCaption = false;
                        Editable = false;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(CreateExcelAccounts)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Download Excel Workbook';
                Tooltip = 'Create an Excel workbook containing the accounts from your Json file';
                Enabled = True;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction();
                var
                    ExcelGPDataUtilities: Codeunit "Excel GP Data Utilities";
                begin
                    ExcelGPDataUtilities.ExportExcelTemplate();
                end;
            }
            action(ImportFromExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Import Excel Workbook';
                Tooltip = 'Import the Excel workbook that contains your account information';
                Enabled = True;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction();
                var
                    ExcelGPDataUtilities: Codeunit "Excel GP Data Utilities";
                    AccountMigrator: Codeunit "MigrationGP Account Migrator";
                begin
                    if not ExcelGPDataUtilities.ImportExcelData() then
                        exit;
                    // after this point, we should be able to validate the new account numbers where the ImportExcelData() method 
                    // created in the 'Config Package Data' table.
                    if AccountMigrator.ValidateNewAccountNumbers() then
                        // Update account staging table with new account number and description.
                        if AccountMigrator.UpdateAccountStagingTable() then begin
                            AccountMigrator.UpdateDefaultAccounts();
                            AccountMigrator.UpdateGLTransactions();
                            CurrPage.Close();
                        end else
                            exit
                    else
                        exit;
                end;
            }
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
                    SetChartofAccountOption(UseExistingCOA, CreateNewCOA);
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage();
    var
        MigrationGPConfig: Record "MigrationGP Config";
        CRLF: Text[2];
    begin
        CRLF := '';
        CRLF[1] := 13;
        CRLF[2] := 10;

        BackEnabled := false;
        NextEnabled := false;
        ShowPage := true;
        Instructions := Instruction1Txt + CRLF + CRLF;
        InstructionsTwo := Instruction2Txt + CRLF + CRLF;
        InstructionsThree := Instruction3Txt;
        ShowButton := true;

        // When you first open the window, set the error state to true, clear if it everything passes.
        MigrationGPConfig.GetSingleInstance();
        MigrationGPConfig.SetAccountValidationError();
    end;

    var
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        UseExistingCOA: Boolean;
        CreateNewCOA: Boolean;
        ShowButton: Boolean;
        ShowPage: Boolean;
        Instruction1Txt: Label 'Download the Excel workbook, enter new account numbers to map the accounts, and then import the workbook.';
        Instructions: Text;
        InstructionsTwo: Text;
        Instruction2Txt: Label 'Tip: It is easier to assign new account number to accounts that belong to the same \category if you sort the worksheet by account category.';
        InstructionsThree: Text;
        Instruction3Txt: Label 'Note: Mapping accounts ensures that transactions migrate correctly. You must map accounts in the workbook before you import it.';

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
}
