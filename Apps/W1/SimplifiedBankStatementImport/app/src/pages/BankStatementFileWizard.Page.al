page 8850 "Bank Statement File Wizard"
{
    Caption = 'Bank Statement File Setup';
    PageType = NavigatePage;

    layout
    {
        area(content)
        {
            group(StandardBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStd; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(FinishedBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Step1)
            {
                Visible = Step1Visible;
                group("Welcome to Bank Statement File Setup")
                {
                    Caption = 'Welcome to Bank Statement File Setup';
                    InstructionalText = 'You can import bank statement files for use in bank account and payment reconciliations. Use this guide to define formats for the files.';
                }
                field(DownloadSample; DownloadSampleLbl)
                {
                    Caption = 'Download Sample';
                    ShowCaption = false;
                    Editable = false;
                    ApplicationArea = Suite;
                    Visible = IsDemoCompany;

                    trigger OnDrillDown()
                    begin
                        DownloadExampleBankFile();
                    end;
                }
                group("Let's go!")
                {
                    Caption = 'Let''s go!';
                    InstructionalText = 'Choose Next to upload your bank statement file. If you upload a file, we''ll detect it''s format and apply it for you. You can also skip this step and define the format yourself.';
                }
            }
            group(Step2)
            {
                Caption = '';
                InstructionalText = 'Upload a bank statement file so that we can detect the format and match the column definitions.';
                Visible = Step2Visible;
                ShowCaption = false;

                field(UploadFile; UploadFileLbl)
                {
                    Caption = 'Upload file';
                    ShowCaption = false;
                    Editable = false;
                    ApplicationArea = Suite;

                    trigger OnDrillDown()
                    var
                        BankStatementFileWizard: Codeunit "Bank Statement File Wizard";
                    begin
                        Clear(TempBlob);
                        Clear(FileLinesList);
                        Clear(FilePreviewHeaderTxt);
                        Clear(FilePreviewRestTxt);
                        Clear(FilePreviewColumnsTxt);
                        Clear(FilePreviewDateColumnTxt);
                        Clear(FilePreviewAmountColumnTxt);
                        Clear(FilePreviewDescriptionColumnTxt);
                        FileName := BankStatementFileWizard.UploadBankFile(TempBlob);
                        if FileName <> '' then begin
                            NextActionEnabled := true;
                            NewFileToRead := true;
                            NewFileToRetrieve := true;
                            NewFileToGetColumns := true;
                            NewFileToGetFormats := true;
                            FileUploaded := true;
                            Evaluate(DataExchangeCode, CopyStr(FileName.Replace('.csv', ''), 1, MaxStrLen(DataExchangeCode)));
                            CurrPage.Update(false);
                        end;
                    end;
                }

                group(Control14)
                {
                    Visible = FileUploaded;
                    ShowCaption = false;

                    field(FileSuccessfullyUploaded; FileSuccessfullyUploadedLbl)
                    {
                        ApplicationArea = Suite;
                        Editable = false;
                        ShowCaption = false;
                        Style = Favorable;
                    }
                }
                group("Skip Step2")
                {
                    Caption = 'Define the bank statement file layout yourself';
                    InstructionalText = 'By continuing without uploading a file, we will not be able to automatically determine formats, and you must specify file definitions yourself.';
                    Enabled = SkipStep2Enabled;
                    field(SkipStep2; SkipStep2)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Continue without uploading';
                        ShowCaption = false;

                        trigger OnValidate()
                        var
                            DataExchDef: Record "Data Exch. Def";
                            LastCodeNumber: Integer;
                            CurrentCodeNumber: Integer;
                            CurrCode: Text;
                        begin
                            LastCodeNumber := 0;
                            if SkipStep2 then begin
                                NextActionEnabled := true;
                                DataExchDef.SetFilter(Code, DataExchangeCodeLbl + '*');
                                if DataExchDef.FindSet() then
                                    repeat
                                        CurrCode := Format(DataExchDef.Code);
                                        CurrCode := CurrCode.Replace(DataExchangeCodeLbl, '');
                                        if Evaluate(CurrentCodeNumber, CurrCode) then
                                            if CurrentCodeNumber > LastCodeNumber then
                                                LastCodeNumber := CurrentCodeNumber;
                                    until DataExchDef.Next() = 0;
                                DataExchangeCode := DataExchangeCodeLbl + Format(LastCodeNumber + 1);
                                Clear(HeaderLines);
                                Clear(ColumnCount);
                                Clear(ColumnSeperator);
                                Clear(LineSeparator);
                                Clear(TransactionDateColumnNo);
                                Clear(TransactionAmountColumnNo);
                                Clear(DescriptionColumnNo);
                                Clear(DateFormat);
                                Clear(DecimalSeperator);
                                Clear(SelectBankAccountCode);
                            end else
                                NextActionEnabled := FileUploaded;
                            CurrPage.Update(false);
                        end;
                    }
                }
            }
            group(Step3)
            {
                Caption = '';
                InstructionalText = 'Specify the number of header lines in your bank statement file. Header lines contain information, such as the name of the bank and the column names, that is not relevant for reconciliations and should be skipped. Header lines are highlighted in the File Preview section and they will be skipped when importing bank statement file.';
                Visible = Step3Visible;
                ShowCaption = false;

                field(HeaderLines; HeaderLines)
                {
                    ApplicationArea = Suite;
                    Caption = 'Header Lines to Skip';
                    ToolTip = 'Specifies the number of header lines to skip in the bank statement file.';

                    trigger OnValidate()
                    var
                        TypeHelper: Codeunit "Type Helper";
                        FileLine: Text;
                        LineCount: Integer;
                        CRLF: Text[2];
                    begin
                        LineCount := 0;
                        if FileUploaded then begin
                            Clear(FilePreviewHeaderTxt);
                            Clear(FilePreviewRestTxt);
                            Clear(FilePreviewColumnsTxt);
                            NewFileToRetrieve := true;
                            NewFileToGetColumns := true;
                            NewFileToGetFormats := true;
                            CRLF := TypeHelper.CRLFSeparator();
                            foreach FileLine in FileLinesList do begin
                                if LineCount = 9 then
                                    break;
                                LineCount += 1;
                                if LineCount <= HeaderLines then
                                    FilePreviewHeaderTxt += Format(LineCount) + '.  ' + FileLine + CRLF
                                else
                                    FilePreviewRestTxt += Format(LineCount) + '.  ' + FileLine + CRLF;
                            end;
                            CurrPage.Update(false);
                        end;
                    end;
                }
                group("File Preview")
                {
                    Caption = 'File Preview';
                    Visible = FileUploaded;

                    group("File Preview Header")
                    {
                        Visible = FileUploaded and (FilePreviewHeaderTxt <> '');
                        ShowCaption = false;

                        field(FilePreviewHeader; FilePreviewHeaderTxt)
                        {
                            ApplicationArea = Suite;
                            Editable = false;
                            ShowCaption = false;
                            Style = StrongAccent;
                            MultiLine = true;
                        }
                    }
                    group("File Preview Rest")
                    {
                        Visible = FileUploaded and (FilePreviewRestTxt <> '');
                        ShowCaption = false;

                        field(FilePreviewRest; FilePreviewRestTxt)
                        {
                            ApplicationArea = Suite;
                            Editable = false;
                            ShowCaption = false;
                            Style = Subordinate;
                            MultiLine = true;
                        }
                    }
                }
            }
            group(Step4)
            {
                Caption = '';
                InstructionalText = 'Specify the column separator, the number of columns, and line separator for your bank statement file.';
                Visible = Step4Visible;
                ShowCaption = false;

                field(ColumnSeparator; ColumnSeperator)
                {
                    ApplicationArea = Suite;
                    Caption = 'Column Seperator';
                    ToolTip = 'Specifies the character that separates each column in the bank statement file.';
                    OptionCaption = ' ,Comma,Semicolon';

                    trigger OnValidate()
                    var
                        Matches: Record Matches;
                        Regex: Codeunit Regex;
                        FileLine: Text;
                    begin
                        if FileUploaded then begin
                            NewFileToGetColumns := true;
                            NewFileToGetFormats := true;
                            FileLine := FileLinesList.Get(HeaderLines + 1);
                            case ColumnSeperator of
                                ColumnSeperator::Comma:
                                    Regex.Match(FileLine, CommaSeperatorRegexLbl, Matches);
                                ColumnSeperator::Semicolon:
                                    Regex.Match(FileLine, SemicolonSeperatorRegexLbl, Matches);
                            end;
                            ColumnCount := Matches.Count();
                        end;
                        CurrPage.Update(false);
                    end;
                }
                field(ColumnCount; ColumnCount)
                {
                    ApplicationArea = Suite;
                    Caption = 'Column Count';
                    ToolTip = 'Specifies the number of columns in the bank statement file.';

                    trigger OnValidate()
                    begin
                        NewFileToGetColumns := true;
                        NewFileToGetFormats := true;
                    end;
                }
                field(LineSeparator; LineSeparator)
                {
                    ApplicationArea = Suite;
                    Caption = 'Line Separator';
                    ToolTip = 'Specifies the character that separates each line in the bank statement file.';
                    OptionCaption = 'CRLF,CR,LF';
                }
                group("File Preview Data")
                {
                    Caption = 'File Preview';
                    Visible = FileUploaded;

                    field(FilePreviewColumns; FilePreviewColumnsTxt)
                    {
                        ApplicationArea = Suite;
                        Editable = false;
                        ShowCaption = false;
                        MultiLine = true;
                    }
                }
            }
            group(Step5)
            {
                Caption = '';
                InstructionalText = 'Review and define the column definitions of your bank statement file. When you enter or change a value, the File Preview section will update accordingly.';
                Visible = Step5Visible;
                ShowCaption = false;

                field(TransactionDate; TransactionDateColumnNo)
                {
                    ApplicationArea = Suite;
                    Caption = 'Date Column No.';
                    ToolTip = 'Specifies the position of the Date column in the order of columns. For example, if the Date column is first in the order, the number should be 1.';

                    trigger OnValidate()
                    var
                        ErrorTxt: Text;
                    begin
                        NewFileToGetFormats := true;
                        if TransactionDateColumnNo > ColumnCount then begin
                            ErrorTxt := StrSubstNo(CannotBeGreaterThanColumCountErr, DateLbl);
                            Error(ErrorTxt);
                        end;
                        FillColumnPreviews();
                        CurrPage.Update(false);
                    end;
                }
                field(TransactionAmount; TransactionAmountColumnNo)
                {
                    ApplicationArea = Suite;
                    Caption = 'Amount Column No.';
                    ToolTip = 'Specifies the number of the column that contains the transaction amount in the bank statement file.';

                    trigger OnValidate()
                    var
                        ErrorTxt: Text;
                    begin
                        NewFileToGetFormats := true;
                        if TransactionAmountColumnNo > ColumnCount then begin
                            ErrorTxt := StrSubstNo(CannotBeGreaterThanColumCountErr, AmountLbl);
                            Error(ErrorTxt);
                        end;
                        FillColumnPreviews();
                        CurrPage.Update(false);
                    end;
                }
                field(Description; DescriptionColumnNo)
                {
                    ApplicationArea = Suite;
                    Caption = 'Description Column No.';
                    ToolTip = 'Specifies the number of the column that contains the description in the bank statement file.';

                    trigger OnValidate()
                    var
                        ErrorTxt: Text;
                    begin
                        NewFileToGetFormats := true;
                        if DescriptionColumnNo > ColumnCount then begin
                            ErrorTxt := StrSubstNo(CannotBeGreaterThanColumCountErr, DescriptionLbl);
                            Error(ErrorTxt);
                        end;
                        FillColumnPreviews();
                        CurrPage.Update(false);
                    end;
                }
                group("File Preview Columns")
                {
                    Caption = 'File Preview';
                    Visible = FileUploaded;

                    grid(ColumnGrids)
                    {
                        GridLayout = Columns;
                        group("Date Column")
                        {
                            Caption = 'Date';

                            field(FilePreviewDateColumn; FilePreviewDateColumnTxt)
                            {
                                ApplicationArea = Suite;
                                Editable = false;
                                ShowCaption = false;
                                MultiLine = true;
                            }

                        }
                        group("Amount Column")
                        {
                            Caption = 'Amount';

                            field(FilePreviewAmountColumn; FilePreviewAmountColumnTxt)
                            {
                                ApplicationArea = Suite;
                                Editable = false;
                                ShowCaption = false;
                                MultiLine = true;
                            }

                        }
                        group("Description Column")
                        {
                            Caption = 'Description';

                            field(FilePreviewDescriptionColumn; FilePreviewDescriptionColumnTxt)
                            {
                                ApplicationArea = Suite;
                                Editable = false;
                                ShowCaption = false;
                                MultiLine = true;
                            }

                        }
                    }
                    group("File Preview Data Rest")
                    {
                        Caption = 'File Preview';
                        Visible = FileUploaded;
                        ShowCaption = false;

                        field(FilePreviewColumnsRest; FilePreviewColumnsTxt)
                        {
                            ApplicationArea = Suite;
                            Editable = false;
                            ShowCaption = false;
                            MultiLine = true;
                        }
                    }
                }
            }
            group(Step6)
            {
                Caption = '';
                InstructionalText = 'Review and define the local formats that are used in your bank statement file.';
                Visible = Step6Visible;
                ShowCaption = false;

                field(DateFormat; DateFormat)
                {
                    ApplicationArea = Suite;
                    Caption = 'Date Format';
                    ToolTip = 'Specifies the format used for dates in the bank statement file. Note that the Microsoft standard date and time format requires capitalization for the month, for example, dd/MM/yyyy or d-M-y.';
                }
                field(DecimalSeperator; DecimalSeperator)
                {
                    ApplicationArea = Suite;
                    Caption = 'Decimal Separator';
                    ToolTip = 'Specifies the decimal separator for amounts in the bank statement file. Separators can be a comma (123,45) or a dot (123.45).';
                    OptionCaption = ' ,Dot,Comma';
                }
                group("File Preview Format")
                {
                    Caption = 'File Preview';
                    Visible = FileUploaded;

                    grid(ColumGrids)
                    {
                        GridLayout = Columns;
                        group("Date Format Column")
                        {
                            Caption = 'Date';

                            field(FileFormatPreviewDateColumn; FilePreviewDateColumnTxt)
                            {
                                ApplicationArea = Suite;
                                Editable = false;
                                ShowCaption = false;
                                MultiLine = true;
                            }

                        }
                        group("Amount Format Column")
                        {
                            Caption = 'Amount';

                            field(FileFormatPreviewAmountColumn; FilePreviewAmountColumnTxt)
                            {
                                ApplicationArea = Suite;
                                Editable = false;
                                ShowCaption = false;
                                MultiLine = true;
                            }

                        }
                    }
                }
            }
            group(Step7)
            {
                Caption = 'Try it out';
                InstructionalText = 'Test that your new format is correct. If you have already uploaded a bank statement file, just choose the link. If you are defining a format yourself, you will be asked to upload a file.';
                Visible = Step7Visible;

                field(InstructionalText; Step7InstructionLbl)
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                }


                field(TestFormat; TestFormatLbl)
                {
                    Caption = 'Upload file';
                    ShowCaption = false;
                    Editable = false;
                    ApplicationArea = Suite;

                    trigger OnDrillDown()
                    var
                        BankStatementImportPreview: Record "Bank Statement Import Preview";
                        BankStatementFileWizard: Codeunit "Bank Statement File Wizard";
                        FileUploaded2: Boolean;
                    begin
                        if not FileUploaded then begin
                            Clear(TempBlob);
                            Clear(FileLinesList);
                            Clear(FileName);
                            FileName := BankStatementFileWizard.UploadBankFile(TempBlob);
                            if FileName <> '' then begin
                                FileUploaded2 := true;
                                if not ReadTestBankFile() then
                                    exit;
                            end;
                        end;

                        if FileUploaded or FileUploaded2 then begin
                            GeneratePreviewData(BankStatementImportPreview);
                            Page.RunModal(Page::"Bank Statement Import Preview", BankStatementImportPreview);
                        end;
                    end;
                }
            }
            group(Finish)
            {
                Caption = 'One last thing';
                InstructionalText = 'You''re all set. Do you want to attach this format to a bank account now, so you can import bank transactions right away?';
                Visible = FinishStepVisible;
                field(DataExchangeCode; DataExchangeCode)
                {
                    ApplicationArea = Suite;
                    Caption = 'Format Code';
                    ToolTip = 'Specifies the name of the setup that will be used as the code for data exchange definitions and bank statement imports.';

                    trigger OnValidate()
                    var
                        DataExchDef: Record "Data Exch. Def";
                        ErrorTxt: Text;
                    begin
                        if DataExchDef.Get(DataExchangeCode) then begin
                            ErrorTxt := StrSubstNo(DataExchDefAlreadyExistsErr, DataExchangeCode);
                            Error(ErrorTxt);
                        end;
                    end;
                }
                field(SelectBankAccount; SelectBankAccountCode)
                {
                    ApplicationArea = Suite;
                    Lookup = true;
                    LookupPageID = "Bank Account List";
                    Caption = 'Bank Account';
                    ToolTip = 'Specifies the bank account that this setup is assigned to. You can assign the account at any time.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        BankAccount: Record "Bank Account";
                    begin
                        if Page.RunModal(Page::"Bank Account List", BankAccount) = Action::LookupOK then begin
                            if BankAccount."Bank Statement Import Format" <> '' then
                                if not Confirm(StrSubstNo(ChangeBankStatementImportFormatLbl, BankAccount."Bank Statement Import Format", BankAccount."No.")) then
                                    exit;
                            SelectBankAccountCode := BankAccount."No.";
                        end;
                    end;

                    trigger OnValidate()
                    var
                        BankAccount: Record "Bank Account";
                    begin
                        if SelectBankAccountCode = '' then
                            exit;
                        BankAccount.Get(SelectBankAccountCode);
                        if BankAccount."Bank Statement Import Format" <> '' then
                            if not Confirm(StrSubstNo(ChangeBankStatementImportFormatLbl, BankAccount."Bank Statement Import Format", BankAccount."No.")) then begin
                                Clear(SelectBankAccountCode);
                                exit;
                            end;
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
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                trigger OnAction();
                begin
                    FinishAction();
                end;
            }
        }
    }

    trigger OnInit();
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        LoadTopBanners();
        EnableControls();

        IsDemoCompany := CompanyInformationMgt.IsDemoCompany();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            if not SetupFinished then
                if not Confirm(SetupNotCompletedQst, false) then
                    Error('');
    end;

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        TempBlob: Codeunit "Temp Blob";
        TopBannerVisible: Boolean;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        Step1Visible: Boolean;
        Step2Visible: Boolean;
        Step3Visible: Boolean;
        Step4Visible: Boolean;
        Step5Visible: Boolean;
        Step6Visible: Boolean;
        Step7Visible: Boolean;
        FinishStepVisible: Boolean;
        SkipStep2: Boolean;
        SkipStep2Enabled: Boolean;
        FileUploaded: Boolean;
        NewFileToRead: Boolean;
        NewFileToRetrieve: Boolean;
        NewFileToGetColumns: Boolean;
        NewFileToGetFormats: Boolean;
        SetupFinished: Boolean;
        IsDemoCompany: Boolean;
        Step: Option Start,Step2,Step3,Step4,Step5,Step6,Step7,Finish;
        ColumnSeperator: Option " ",Comma,Semicolon;
        DecimalSeperator: Option " ","Dot","Comma";
        LineSeparator: Option "CRLF","CR","LF";
        UploadFileLbl: Label 'Upload a bank statement file';
        DownloadSampleLbl: Label 'Download a sample bank statement file';
        FileSuccessfullyUploadedLbl: Label 'Bank statement file successfully uploaded';
        SetupNotCompletedQst: Label 'The setup is not complete.\\Are you sure you want to exit?';
        TestFormatLbl: Label 'Test the bank statement file format';
        DateLbl: Label 'Date';
        AmountLbl: Label 'Amount';
        DescriptionLbl: Label 'Description';
        DetailLbl: Label 'Detail';
        DataExchDefLbl: Label 'Data Exchange Definition';
        LineDefLbl: Label 'Line Definition';
        BankPaymentFieldMappingLbl: Label 'Bank Payment Field Mapping';
        BankImportSetupLbl: Label 'Bank Import Setup';
        IncorrectLineSeparatorErr: Label 'The line separator in the uploaded file, %1, differs from your setup. To continue, go back a step or two and change your setup to use %1.', Comment = '%1 = Line separator';
        DataExchDefAlreadyExistsErr: Label 'A data exchange definition with the code %1 already exists.', Comment = '%1 = Data Exchange Definition Code';
        CannotBeGreaterThanColumCountErr: Label 'Column number for %1 cannot be greater than column count.', Comment = '%1 = Name of the column';
        Step7InstructionLbl: Label 'The preview will show the first 10 lines from the file, and any problems will be colored red. It''s a good idea to verify that the decimal separator is correct. Using the wrong separator will result in incorrect amounts.';
        ChangeBankStatementImportFormatLbl: Label 'Bank Statement Import Format %1 is already defined for the Bank Account %2. Do you want to overwrite it with the new format?', Comment = '%1 = Bank Statement Import Format, %2 = Bank Account';
        CommaSeperatorRegexLbl: Label '(,|\r?\n|^)([^",\r\n]+|"(?:[^"]|"")*")?', Locked = true;
        SemicolonSeperatorRegexLbl: Label '(;|\r?\n|^)([^";\r\n]+|"(?:[^"]|"")*")?', Locked = true;
        DateRegexLbl: Label '^((((0?[1-9]|[12]\d|3[01])[\.\-\/](0?[13578]|1[02])[\.\-\/]((1[6-9]|[2-9]\d)?\d{2}))|((0?[1-9]|[12]\d|30)[\.\-\/](0?[13456789]|1[012])[\.\-\/]((1[6-9]|[2-9]\d)?\d{2}))|((0?[1-9]|1\d|2[0-8])[\.\-\/]0?2[\.\-\/]((1[6-9]|[2-9]\d)?\d{2}))|(29[\.\-\/]0?2[\.\-\/]((1[6-9]|[2-9]\d)?(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00)|00)))|(((0[1-9]|[12]\d|3[01])(0[13578]|1[02])((1[6-9]|[2-9]\d)?\d{2}))|((0[1-9]|[12]\d|30)(0[13456789]|1[012])((1[6-9]|[2-9]\d)?\d{2}))|((0[1-9]|1\d|2[0-8])02((1[6-9]|[2-9]\d)?\d{2}))|(2902((1[6-9]|[2-9]\d)?(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00)|00))))$', Locked = true;
        DateWithMonthNameRegexLbl: Label '^((31(?![\.\-\/\ ](Feb(ruary)?|Apr(il)?|June?|(Sep(?=\b|t)t?|Nov)(ember)?)))|((30|29)(?!\ Feb(ruary)?))|(29(?=\ Feb(ruary)?\ (((1[6-9]|[2-9]\d)(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00)))))|(0?[1-9])|1\d|2[0-8])[\.\-\/\ ](Jan(uary)?|Feb(ruary)?|Ma(r(ch)?|y)|Apr(il)?|Ju((ly?)|(ne?))|Aug(ust)?|Oct(ober)?|(Sep(?=\b|t)t?|Nov|Dec)(ember)?)[\.\-\/\ ]((1[6-9]|[2-9]\d)\d{2})$', Locked = true;
        DateTimeMonthFirstRegexLbl: Label '^(?=\d)(?:(?:(?:(?:(?:0?[13578]|1[02])(\/|-|\.)31)\1|(?:(?:0?[1,3-9]|1[0-2])(\/|-|\.)(?:29|30)\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})|(?:0?2(\/|-|\.)29\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))|(?:(?:0?[1-9])|(?:1[0-2]))(\/|-|\.)(?:0?[1-9]|1\d|2[0-8])\4(?:(?:1[6-9]|[2-9]\d)?\d{2}))($|\ (?=\d)))?(((0?[1-9]|1[012])(:[0-5]\d){0,2}(\ [AP]M))|([01]\d|2[0-3])(:[0-5]\d){1,2})?$', Locked = true;
        DateTimeDayFirstRegexLbl: Label '^(?=\d)(?:(?:31(?!.(?:0?[2469]|11))|(?:30|29)(?!.0?2)|29(?=.0?2.(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00)))(?:\x20|$))|(?:2[0-8]|1\d|0?[1-9]))([-./])(?:1[012]|0?[1-9])\1(?:1[6-9]|[2-9]\d)?\d\d(?:(?=\x20\d)\x20|$))?(((0?[1-9]|1[012])(:[0-5]\d){0,2}(\x20[AP]M))|([01]\d|2[0-3])(:[0-5]\d){1,2})?$', Locked = true;
        AmountWithDotRegexLbl: Label '^([0-9]+\d{0,2}([\,'']\d{3})*|([1-9]+\d*))(\.[0-9]+)?$', Locked = true;
        AmountWithCommaRegexLbl: Label '^([0-9]+\d{0,2}([\.'']\d{3})*|([1-9]+\d*))(\,[0-9]+)?$', Locked = true;
        yyyyMMddDashRegexLbl: Label '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$', Locked = true;
        yyyyMMddDotRegexLbl: Label '^[0-9]{4}\.(0[1-9]|1[0-2])\.(0[1-9]|[1-2][0-9]|3[0-1])$', Locked = true;
        yyyyMMddSlashRegexLbl: Label '^[0-9]{4}\/(0[1-9]|1[0-2])\/(0[1-9]|[1-2][0-9]|3[0-1])$', Locked = true;
        ddMMyyyyDashRegexLbl: Label '^(0[1-9]|[1-2][0-9]|3[0-1])-(0[1-9]|1[0-2])-[0-9]{4}$', Locked = true;
        ddMMyyyyDotRegexLbl: Label '^(0[1-9]|[1-2][0-9]|3[0-1])\.(0[1-9]|1[0-2])\.[0-9]{4}$', Locked = true;
        ddMMyyyySlashRegexLbl: Label '^(0[1-9]|[1-2][0-9]|3[0-1])\/(0[1-9]|1[0-2])\/[0-9]{4}$', Locked = true;
        MMddyyyyDashRegexLbl: Label '^(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])-[0-9]{4}$', Locked = true;
        MMddyyyyDotRegexLbl: Label '^(0[1-9]|1[0-2])\.(0[1-9]|[1-2][0-9]|3[0-1])\.[0-9]{4}$', Locked = true;
        MMddyyyySlashRegexLbl: Label '^(0[1-9]|1[0-2])\/(0[1-9]|[1-2][0-9]|3[0-1])\/[0-9]{4}$', Locked = true;
        MddyyyyDashRegexLbl: Label '^(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])-\d{4}$', Locked = true;
        MddyyyyDotRegexLbl: Label '^(0?[1-9]|1[012])\.(0?[1-9]|[12][0-9]|3[01])\.\d{4}$', Locked = true;
        MddyyyySlashRegexLbl: Label '^(0?[1-9]|1[012])\/(0?[1-9]|[12][0-9]|3[01])\/\d{4}$', Locked = true;
        DataExchangeCodeLbl: Label 'BANKIMP', Locked = true;
        StoringRecordsTxt: Label 'Bank statement setup completed and started storing records.', Locked = true;
        StoredRecordsTxt: Label 'Records are stored and bank statement format is saved.', Locked = true;
        BankAccountSelectedTxt: Label 'A bank account has been specified in the setup.', Locked = true;
        BankStatementFileWizardCategoryTxt: Label 'AL Bank Statement File Wizard', Locked = true;
        DataExchangeCode: Code[20];
        SelectBankAccountCode: Code[20];
        TransactionAmountColumnNo: Integer;
        TransactionDateColumnNo: Integer;
        DescriptionColumnNo: Integer;
        ColumnCount: Integer;
        HeaderLines: Integer;
        DateFormat: Text;
        FilePreviewHeaderTxt: Text;
        FilePreviewRestTxt: Text;
        FilePreviewColumnsTxt: Text;
        FilePreviewDateColumnTxt: Text;
        FilePreviewAmountColumnTxt: Text;
        FilePreviewDescriptionColumnTxt: Text;
        FileName: Text;
        FileLinesList: List of [Text];

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png',
           Format(CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png',
           Format(CurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        if (Step = Step::Step3) and FileUploaded and not Backwards and not SkipStep2 and NewFileToRead then
            ReadBankFile();
        if (Step = Step::Step3) and not Backwards and SkipStep2 then begin
            Clear(FileName);
            Clear(TempBlob);
            Clear(FileUploaded);
            Clear(HeaderLines);
        end;
        if (Step = Step::Step4) and FileUploaded and not Backwards and not SkipStep2 and NewFileToRetrieve then
            RetrieveInformationFromBankFile();
        if (Step = Step::Step5) and FileUploaded and not Backwards and not SkipStep2 and NewFileToGetColumns then
            GetColumnsFromBankFile();
        if (Step = Step::Step6) and FileUploaded and not Backwards and not SkipStep2 and NewFileToGetFormats then
            GetFormatsFromBankFile();

        EnableControls();
    end;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowStep1();
            Step::Step2:
                ShowStep2();
            Step::Step3:
                ShowStep3();
            Step::Step4:
                ShowStep4();
            Step::Step5:
                ShowStep5();
            Step::Step6:
                ShowStep6();
            Step::Step7:
                ShowStep7();
            Step::Finish:
                ShowFinishStep();
        end;
    end;

    local procedure ShowStep1();
    begin
        Step1Visible := true;

        FinishActionEnabled := false;
        BackActionEnabled := false;
    end;

    local procedure ShowStep2();
    begin
        Step2Visible := true;
        if not FileUploaded and not SkipStep2 then
            NextActionEnabled := false;
    end;

    local procedure ShowStep3();
    begin
        Step3Visible := true;
    end;

    local procedure ShowStep4();
    begin
        Step4Visible := true;
    end;

    local procedure ShowStep5();
    begin
        Step5Visible := true;
    end;

    local procedure ShowStep6();
    begin
        Step6Visible := true;
    end;

    local procedure ShowStep7();
    begin
        Step7Visible := true;
    end;

    local procedure ShowFinishStep();
    begin
        FinishStepVisible := true;

        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ResetControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        Step1Visible := false;
        Step2Visible := false;
        Step3Visible := false;
        Step4Visible := false;
        Step5Visible := false;
        Step6Visible := false;
        Step7Visible := false;
        FinishStepVisible := false;
        SkipStep2Enabled := true;
    end;

    local procedure FinishAction();
    begin
        StoreRecords();
        SetupFinished := true;
        Commit();
        CurrPage.Close();
    end;

    local procedure StoreRecords()
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        DataExchColumnDef: Record "Data Exch. Column Def";
        BankExportImportSetup: Record "Bank Export/Import Setup";
        BankAccount: Record "Bank Account";
        AmountFormat: Text;
    begin
        Session.LogMessage('0000EBK', StoringRecordsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', BankStatementFileWizardCategoryTxt);

        DataExchDef.Init();
        DataExchDef.Code := DataExchangeCode;
        DataExchDef.Name := DataExchangeCode + ' ' + DataExchDefLbl;
        DataExchDef.Type := DataExchDef.Type::"Bank Statement Import";
        DataExchDef."File Type" := DataExchDef."File Type"::"Fixed Text";
        DataExchDef."Reading/Writing XMLport" := Xmlport::"Data Exch. Import - CSV";
        DataExchDef."Ext. Data Handling Codeunit" := Codeunit::"Read Data Exch. from File";
        DataExchDef."File Encoding" := DataExchDef."File Encoding"::WINDOWS;
        case ColumnSeperator of
            ColumnSeperator::Comma:
                DataExchDef."Column Separator" := DataExchDef."Column Separator"::Comma;
            ColumnSeperator::Semicolon:
                DataExchDef."Column Separator" := DataExchDef."Column Separator"::Semicolon;
        end;
        case LineSeparator of
            LineSeparator::CR:
                DataExchDef."Line Separator" := DataExchDef."Line Separator"::CR;
            LineSeparator::LF:
                DataExchDef."Line Separator" := DataExchDef."Line Separator"::LF;
            LineSeparator::CRLF:
                DataExchDef."Line Separator" := DataExchDef."Line Separator"::CRLF;
        end;
        DataExchDef."Header Lines" := HeaderLines;
        DataExchDef.Insert();

        DataExchLineDef.InsertRec(DataExchangeCode, DataExchangeCode, DataExchangeCode + ' ' + LineDefLbl, ColumnCount);
        DataExchMapping.InsertRec(DataExchangeCode, DataExchangeCode, Database::"Bank Acc. Reconciliation Line", DataExchangeCode + ' ' + BankPaymentFieldMappingLbl, Codeunit::"Process Bank Acc. Rec Lines", 0, 0);

        DataExchFieldMapping.InsertRec(DataExchangeCode, DataExchangeCode, Database::"Bank Acc. Reconciliation Line", TransactionDateColumnNo, 5, false, 1);
        DataExchFieldMapping.InsertRec(DataExchangeCode, DataExchangeCode, Database::"Bank Acc. Reconciliation Line", TransactionAmountColumnNo, 7, false, 1);
        DataExchFieldMapping.InsertRec(DataExchangeCode, DataExchangeCode, Database::"Bank Acc. Reconciliation Line", DescriptionColumnNo, 23, false, 1);

        case DecimalSeperator of
            DecimalSeperator::Dot:
                AmountFormat := 'en-US';
            DecimalSeperator::Comma:
                AmountFormat := 'es-ES';
        end;
        DataExchColumnDef.InsertRec(DataExchangeCode, DataExchangeCode, TransactionDateColumnNo, DateLbl, false, DataExchColumnDef."Data Type"::Date, CopyStr(DateFormat, 1, 100), CopyStr(AmountFormat, 1, 10), '');
        DataExchColumnDef.InsertRec(DataExchangeCode, DataExchangeCode, TransactionAmountColumnNo, AmountLbl, false, DataExchColumnDef."Data Type"::Decimal, '', CopyStr(AmountFormat, 1, 10), '');
        DataExchColumnDef.InsertRec(DataExchangeCode, DataExchangeCode, DescriptionColumnNo, DescriptionLbl, false, DataExchColumnDef."Data Type"::Text, '', '', '');

        BankExportImportSetup.Init();
        BankExportImportSetup.Code := DataExchangeCode;
        BankExportImportSetup.Name := DataExchangeCode + ' ' + BankImportSetupLbl;
        BankExportImportSetup.Direction := BankExportImportSetup.Direction::Import;
        BankExportImportSetup."Processing Codeunit ID" := Codeunit::"Exp. Launcher Gen. Jnl.";
        BankExportImportSetup."Preserve Non-Latin Characters" := true;
        BankExportImportSetup."Data Exch. Def. Code" := DataExchangeCode;
        BankExportImportSetup.Insert();

        if SelectBankAccountCode <> '' then begin
            Session.LogMessage('0000EBL', BankAccountSelectedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', BankStatementFileWizardCategoryTxt);
            BankAccount.Get(SelectBankAccountCode);
            BankAccount."Bank Statement Import Format" := DataExchangeCode;
            BankAccount.Modify();
        end;
        Session.LogMessage('0000ECE', StoredRecordsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', BankStatementFileWizardCategoryTxt);
    end;

    local procedure DownloadExampleBankFile()
    var
        FileManagement: Codeunit "File Management";
        SampleFileTempBlob: Codeunit "Temp Blob";
        SampleFileOutStream: OutStream;
        SampleFileName: Text;
        SampleTransactionDate: Text;
    begin
        SampleFileTempBlob.CreateOutStream(SampleFileOutStream);
        SampleFileOutStream.WriteText('Date,Sort & Account No.,Account Name,Type,Amount,Customer Reference,Transaction Details,Balance');
        SampleFileOutStream.WriteText();
        SampleTransactionDate := Format(WorkDate(), 0, '<Day,2>/<Month,2>/<Year4>');
        SampleFileOutStream.WriteText(SampleTransactionDate + ',12345678,MYACC,DEB,-307.48,TST,EASYJET,1136.12');
        SampleFileOutStream.WriteText();
        SampleFileOutStream.WriteText(SampleTransactionDate + ',12345678,MYACC,DEB,-24.98,TST,CITI BANK CD 432018,1443.6');
        SampleFileOutStream.WriteText();
        SampleFileOutStream.WriteText(SampleTransactionDate + ',12345678,MYACC,PFI,702,TST,FRANK SPENCER,1468.58');
        SampleFileOutStream.WriteText();
        SampleFileOutStream.WriteText(SampleTransactionDate + ',12345678,MYACC,DD,-36.66,TST,VITALITY HEALTH,766.58');
        SampleFileName := 'SampleBankFile.csv';
        FileManagement.BLOBExport(SampleFileTempBlob, SampleFileName, true);
    end;

    local procedure ReadBankFile()
    var
        Matches: Record Matches;
        CommaMatches: Record Matches;
        SemicolonMatches: Record Matches;
        TypeHelper: Codeunit "Type Helper";
        Regex: Codeunit Regex;
        FileInStream: InStream;
        FileSeparatorInStream: InStream;
        FileLine: Text;
        Seperator: Text;
        CRLF: Text[2];
        LineCount: Integer;
        HeaderLinesFound: Boolean;
    begin
        NewFileToRead := false;
        if not TempBlob.HasValue() then
            exit;
        TempBlob.CreateInStream(FileInStream);
        TempBlob.CreateInStream(FileSeparatorInStream);
        CRLF := TypeHelper.CRLFSeparator();

        ReadLineSeparator(FileSeparatorInStream, LineSeparator);

        while not FileInStream.EOS() do begin
            LineCount += 1;
            if LineCount = 50 then
                break;
            FileInStream.ReadText(FileLine);
            FileLinesList.Add(FileLine);
        end;

        FileLine := FileLinesList.Get(Round(FileLinesList.Count() / 2, 1, '>'));
        Regex.Match(FileLine, CommaSeperatorRegexLbl, CommaMatches);
        Regex.Match(FileLine, SemicolonSeperatorRegexLbl, SemicolonMatches);

        if CommaMatches.Count() > 2 then
            Seperator := CommaSeperatorRegexLbl;

        if SemicolonMatches.Count() > 2 then
            Seperator := SemicolonSeperatorRegexLbl;

        if Seperator = '' then begin
            HeaderLines := 0;
            HeaderLinesFound := true;
        end;

        for LineCount := 1 to FileLinesList.Count() do begin
            FileLine := FileLinesList.Get(LineCount);
            Regex.Match(FileLine, Seperator, Matches);
            if (Matches.Count() > 2) and not HeaderLinesFound then begin
                HeaderLines := LineCount;
                HeaderLinesFound := true;
            end;
            if LineCount < 10 then
                if HeaderLinesFound then begin
                    if LineCount <= HeaderLines then
                        FilePreviewHeaderTxt += Format(LineCount) + '.  ' + FileLine + CRLF
                    else
                        FilePreviewRestTxt += Format(LineCount) + '.  ' + FileLine + CRLF;
                end else
                    FilePreviewHeaderTxt += Format(LineCount) + '.  ' + FileLine + CRLF
        end;
    end;

    local procedure ReadTestBankFile(): Boolean
    var
        TypeHelper: Codeunit "Type Helper";
        FileInStream: InStream;
        FileSeparatorInStream: InStream;
        TestFileLineSeparator: Option "CRLF","CR","LF";
        FileLine: Text;
        LineCount: Integer;
        CRLF: Text[2];
    begin
        if not TempBlob.HasValue() then
            exit;
        TempBlob.CreateInStream(FileInStream);
        TempBlob.CreateInStream(FileSeparatorInStream);
        CRLF := TypeHelper.CRLFSeparator();

        ReadLineSeparator(FileSeparatorInStream, TestFileLineSeparator);

        if TestFileLineSeparator <> LineSeparator then begin
            Message(IncorrectLineSeparatorErr, TestFileLineSeparator);
            exit(false);
        end;

        while not FileInStream.EOS() do begin
            LineCount += 1;
            if LineCount = 20 then
                break;
            FileInStream.ReadText(FileLine);
            FileLinesList.Add(FileLine);
        end;
        exit(true);
    end;

    local procedure RetrieveInformationFromBankFile()
    var
        CommaMatches: Record Matches;
        SemicolonMatches: Record Matches;
        CurrentCommaMatches: Record Matches;
        CurrentSemicolonMatches: Record Matches;
        Regex: Codeunit Regex;
        FileLine: Text;
        i: Integer;
        IsComma: Boolean;
        IsSemicolon: Boolean;
    begin
        NewFileToRetrieve := false;
        FileLine := FileLinesList.Get(HeaderLines + 1);
        Regex.Match(FileLine, CommaSeperatorRegexLbl, CommaMatches);
        Regex.Match(FileLine, SemicolonSeperatorRegexLbl, SemicolonMatches);

        if CommaMatches.Count() > 2 then
            IsComma := true;

        if SemicolonMatches.Count() > 2 then
            IsSemicolon := true;

        for i := HeaderLines + 2 to FileLinesList.Count() do begin
            FileLine := FileLinesList.Get(i);
            if IsComma then begin
                Regex.Match(FileLine, CommaSeperatorRegexLbl, CurrentCommaMatches);
                if CurrentCommaMatches.Count() <> CommaMatches.Count() then
                    IsComma := false;
            end;

            if IsSemicolon then begin
                Regex.Match(FileLine, SemicolonSeperatorRegexLbl, CurrentSemicolonMatches);
                if CurrentSemicolonMatches.Count() <> SemicolonMatches.Count() then
                    IsSemicolon := false;
            end;

            if i = HeaderLines + 21 then
                break;
        end;

        if IsSemicolon then begin
            ColumnSeperator := ColumnSeperator::Semicolon;
            ColumnCount := SemicolonMatches.Count();
            FillPreviewColumns();
            exit;
        end;

        if IsComma then begin
            ColumnSeperator := ColumnSeperator::Comma;
            ColumnCount := CommaMatches.Count();
            FillPreviewColumns();
            exit;
        end;

        ColumnSeperator := ColumnSeperator::" ";
        ColumnCount := 0;
    end;

    local procedure FillPreviewColumns()
    var
        TypeHelper: Codeunit "Type Helper";
        FileLine: Text;
        i: Integer;
        LineCount: Integer;
        CRLF: Text[2];
    begin
        CRLF := TypeHelper.CRLFSeparator();
        for i := HeaderLines + 1 to FileLinesList.Count() do begin
            LineCount += 1;
            FileLine := FileLinesList.Get(i);
            FilePreviewColumnsTxt += Format(LineCount) + '.  ' + FileLine + CRLF;
            if i = HeaderLines + 9 then
                break;
        end;
    end;

    local procedure GetFormatsFromBankFile()
    var
        Matches: Record Matches;
        Regex: Codeunit Regex;
        FileLine: Text;
        CurrValue: Text;
        SeperatorChar: Char;
    begin
        NewFileToGetFormats := false;
        Clear(DateFormat);
        Clear(DecimalSeperator);

        FileLine := FileLinesList.Get(HeaderLines + 1);
        case ColumnSeperator of
            ColumnSeperator::Comma:
                begin
                    Regex.Match(FileLine, CommaSeperatorRegexLbl, Matches);
                    SeperatorChar := ',';
                end;
            ColumnSeperator::Semicolon:
                begin
                    Regex.Match(FileLine, SemicolonSeperatorRegexLbl, Matches);
                    SeperatorChar := ';';
                end;
        end;

        if TransactionAmountColumnNo <> 0 then begin
            Matches.Get(TransactionAmountColumnNo - 1);
            CurrValue := Matches.ReadValue().TrimStart(SeperatorChar).TrimStart('-');
            if Regex.IsMatch(CurrValue, AmountWithDotRegexLbl) and CurrValue.Contains('.') then
                DecimalSeperator := DecimalSeperator::Dot
            else
                if Regex.IsMatch(CurrValue, AmountWithCommaRegexLbl) and CurrValue.Contains(',') then
                    DecimalSeperator := DecimalSeperator::Comma;
        end;

        if TransactionDateColumnNo <> 0 then begin
            Matches.Get(TransactionDateColumnNo - 1);
            CurrValue := Matches.ReadValue().TrimStart(SeperatorChar);
            if Regex.IsMatch(CurrValue, ddMMyyyyDashRegexLbl) then
                DateFormat := 'dd-MM-yyyy';
            if Regex.IsMatch(CurrValue, ddMMyyyyDotRegexLbl) then
                DateFormat := 'dd.MM.yyyy';
            if Regex.IsMatch(CurrValue, ddMMyyyySlashRegexLbl) then
                DateFormat := 'dd/MM/yyyy';
            if Regex.IsMatch(CurrValue, MddyyyyDashRegexLbl) then
                DateFormat := 'M-dd-yyyy';
            if Regex.IsMatch(CurrValue, MddyyyyDotRegexLbl) then
                DateFormat := 'M.dd.yyyy';
            if Regex.IsMatch(CurrValue, MddyyyySlashRegexLbl) then
                DateFormat := 'M/dd/yyyy';
            if Regex.IsMatch(CurrValue, MMddyyyyDashRegexLbl) then
                DateFormat := 'MM-dd-yyyy';
            if Regex.IsMatch(CurrValue, MMddyyyyDotRegexLbl) then
                DateFormat := 'MM.dd.yyyy';
            if Regex.IsMatch(CurrValue, MMddyyyySlashRegexLbl) then
                DateFormat := 'MM/dd/yyyy';
            if Regex.IsMatch(CurrValue, yyyyMMddDashRegexLbl) then
                DateFormat := 'yyyy-MM-dd';
            if Regex.IsMatch(CurrValue, yyyyMMddDotRegexLbl) then
                DateFormat := 'yyyy.MM.dd';
            if Regex.IsMatch(CurrValue, yyyyMMddSlashRegexLbl) then
                DateFormat := 'yyyy/MM/dd';
            if Regex.IsMatch(CurrValue, DateWithMonthNameRegexLbl) then
                DateFormat := 'dd MMM yyyy';
        end;
    end;

    local procedure GetColumnsFromBankFile()
    var
        Matches: Record Matches;
        Regex: Codeunit Regex;
        DateColumnNoFound: Boolean;
        AmountColumnNoFound: Boolean;
        DescriptionColumnNoFound: Boolean;
        SeperatorRegex: Text;
        FileLine: Text;
        CurrValue: Text;
        i: Integer;
        j: Integer;
        SeperatorChar: Char;
    begin
        Clear(TransactionDateColumnNo);
        Clear(TransactionAmountColumnNo);
        Clear(DescriptionColumnNo);
        NewFileToGetColumns := false;
        case ColumnSeperator of
            ColumnSeperator::Comma:
                begin
                    SeperatorRegex := CommaSeperatorRegexLbl;
                    SeperatorChar := ',';
                end;
            ColumnSeperator::Semicolon:
                begin
                    SeperatorRegex := SemicolonSeperatorRegexLbl;
                    SeperatorChar := ';';
                end;
        end;

        if HeaderLines <> 0 then begin
            FileLine := FileLinesList.Get(HeaderLines);
            Regex.Match(FileLine, SeperatorRegex, Matches);

            for i := 0 to Matches.Count() - 1 do begin
                Matches.Get(i);
                if Matches.ReadValue().ToLower().Contains(Format(DateLbl).ToLower()) then begin
                    TransactionDateColumnNo := i + 1;
                    DateColumnNoFound := true;
                end;
                if Matches.ReadValue().ToLower().Contains(Format(AmountLbl).ToLower()) then begin
                    TransactionAmountColumnNo := i + 1;
                    AmountColumnNoFound := true;
                end;
                if Matches.ReadValue().ToLower().Contains(Format(DescriptionLbl).ToLower()) or Matches.ReadValue().ToLower().Contains(Format(DetailLbl).ToLower()) then begin
                    DescriptionColumnNo := i + 1;
                    DescriptionColumnNoFound := true;
                end;

                if DateColumnNoFound and AmountColumnNoFound and DescriptionColumnNoFound then
                    break;
            end;
        end;

        if not DateColumnNoFound or not AmountColumnNoFound then
            for i := HeaderLines + 1 to FileLinesList.Count() do begin
                FileLine := FileLinesList.Get(i);
                Regex.Match(FileLine, SeperatorRegex, Matches);
                for j := 0 to Matches.Count() - 1 do begin
                    Matches.Get(j);
                    CurrValue := Matches.ReadValue().TrimStart(SeperatorChar);

                    if not DateColumnNoFound then
                        if Regex.IsMatch(CurrValue, DateRegexLbl) or Regex.IsMatch(CurrValue, DateWithMonthNameRegexLbl) then begin
                            TransactionDateColumnNo := j + 1;
                            DateColumnNoFound := true;
                        end else
                            if Regex.IsMatch(CurrValue, DateTimeDayFirstRegexLbl) or Regex.IsMatch(CurrValue, DateTimeMonthFirstRegexLbl) then begin
                                TransactionDateColumnNo := j + 1;
                                DateColumnNoFound := true;
                            end;

                    if not AmountColumnNoFound then
                        if Regex.IsMatch(CurrValue.TrimStart('-'), AmountWithDotRegexLbl) and CurrValue.Contains('.') then begin
                            TransactionAmountColumnNo := j + 1;
                            AmountColumnNoFound := true;
                        end else
                            if Regex.IsMatch(CurrValue.TrimStart('-'), AmountWithCommaRegexLbl) and CurrValue.Contains(',') then begin
                                TransactionAmountColumnNo := j + 1;
                                AmountColumnNoFound := true;
                            end;
                end;

                if i = HeaderLines + 5 then
                    break;
            end;

        FillColumnPreviews();
    end;

    local procedure FillColumnPreviews()
    var
        Matches: Record Matches;
        Regex: Codeunit Regex;
        TypeHelper: Codeunit "Type Helper";
        FileLine: Text;
        SeperatorChar: Char;
        i: Integer;
        CRLF: Text[2];
    begin
        Clear(FilePreviewDateColumnTxt);
        Clear(FilePreviewAmountColumnTxt);
        Clear(FilePreviewDescriptionColumnTxt);
        CRLF := TypeHelper.CRLFSeparator();
        for i := HeaderLines + 1 to FileLinesList.Count() do begin
            FileLine := FileLinesList.Get(i);
            case ColumnSeperator of
                ColumnSeperator::Comma:
                    begin
                        Regex.Match(FileLine, CommaSeperatorRegexLbl, Matches);
                        SeperatorChar := ',';
                    end;
                ColumnSeperator::Semicolon:
                    begin
                        Regex.Match(FileLine, SemicolonSeperatorRegexLbl, Matches);
                        SeperatorChar := ';';
                    end;
            end;

            if TransactionDateColumnNo <> 0 then begin
                Matches.Get(TransactionDateColumnNo - 1);
                FilePreviewDateColumnTxt += Matches.ReadValue().TrimStart(SeperatorChar) + CRLF;
            end;
            if TransactionAmountColumnNo <> 0 then begin
                Matches.Get(TransactionAmountColumnNo - 1);
                FilePreviewAmountColumnTxt += Matches.ReadValue().TrimStart(SeperatorChar) + CRLF;
            end;
            if DescriptionColumnNo <> 0 then begin
                Matches.Get(DescriptionColumnNo - 1);
                FilePreviewDescriptionColumnTxt += Matches.ReadValue().TrimStart(SeperatorChar) + CRLF;
            end;

            if i = HeaderLines + 5 then
                break;
        end;
    end;

    local procedure GeneratePreviewData(var BankStatementImportPreview: Record "Bank Statement Import Preview")
    var
        Matches: Record Matches;
        Regex: Codeunit Regex;
        FileLine: Text;
        AmountFormat: Text;
        SeperatorChar: Char;
        i: Integer;
    begin
        for i := HeaderLines + 1 to FileLinesList.Count() do begin
            FileLine := FileLinesList.Get(i);
            case ColumnSeperator of
                ColumnSeperator::Comma:
                    begin
                        Regex.Match(FileLine, CommaSeperatorRegexLbl, Matches);
                        SeperatorChar := ',';
                    end;
                ColumnSeperator::Semicolon:
                    begin
                        Regex.Match(FileLine, SemicolonSeperatorRegexLbl, Matches);
                        SeperatorChar := ';';
                    end;
            end;

            BankStatementImportPreview.Init();
            BankStatementImportPreview."Primary Key" := i;
            Matches.Get(TransactionAmountColumnNo - 1);
            BankStatementImportPreview.Amount := CopyStr(Matches.ReadValue().TrimStart(SeperatorChar), 1, 1024);
            Matches.Get(TransactionDateColumnNo - 1);
            BankStatementImportPreview."Date" := CopyStr(Matches.ReadValue().TrimStart(SeperatorChar), 1, 1024);
            Matches.Get(DescriptionColumnNo - 1);
            BankStatementImportPreview.Description := CopyStr(Matches.ReadValue().TrimStart(SeperatorChar), 1, 1024);
            case DecimalSeperator of
                DecimalSeperator::Dot:
                    AmountFormat := 'en-US';
                DecimalSeperator::Comma:
                    AmountFormat := 'es-ES';
            end;
            BankStatementImportPreview."Amount Format" := CopyStr(AmountFormat, 1, 1024);
            BankStatementImportPreview."Date Format" := CopyStr(DateFormat, 1, 1024);
            BankStatementImportPreview.Insert();

            if i = HeaderLines + 10 then
                break;
        end;
    end;

    local procedure ReadLineSeparator(FileSeparatorInStream: InStream; var LineSeparator: Option "CRLF","CR","LF")
    var
        TypeHelper: Codeunit "Type Helper";
        FileStart: Text;
        CRLF: Text[2];
    begin
        CRLF := TypeHelper.CRLFSeparator();
        FileSeparatorInStream.Read(FileStart, 4000); // Read first 4000 characters to determine the line separator

        if FileStart.Contains(CRLF) then begin
            LineSeparator := LineSeparator::CRLF;
            exit;
        end;

        if FileStart.Contains(CRLF[1]) then begin
            LineSeparator := LineSeparator::CR;
            exit;
        end;

        if FileStart.Contains(CRLF[2]) then begin
            LineSeparator := LineSeparator::LF;
            exit;
        end;
    end;
}