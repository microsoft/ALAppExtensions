#pragma warning disable AA0232
table 11732 "Cash Document Header CZP"
{
    Caption = 'Cash Document Header';
    DataCaptionFields = "Cash Desk No.", "Document Type", "No.", "Pay-to/Receive-from Name";
    DrillDownPageID = "Cash Document List CZP";
    LookupPageID = "Cash Document List CZP";

    fields
    {
        field(1; "Cash Desk No."; Code[20])
        {
            Caption = 'Cash Desk No.';
            Editable = false;
            TableRelation = "Cash Desk CZP";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Cash Desk No.");
                TestField("No.", '');
                GetCashDeskCZP("Cash Desk No.");
                CashDeskCZP.TestField(Blocked, false);
            end;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if xRec."No." <> '' then
                    TestField("No.", "No.");

                if "No." <> xRec."No." then begin
                    NoSeriesManagement.TestManual(GetNoSeriesCode());
                    "No. Series" := '';
                end;
            end;
        }
        field(3; "Pay-to/Receive-from Name"; Text[100])
        {
            Caption = 'Pay-to/Receive-from Name';
            DataClassification = CustomerContent;
        }
        field(4; "Pay-to/Receive-from Name 2"; Text[50])
        {
            Caption = 'Pay-to/Receive-from Name 2';
            DataClassification = CustomerContent;
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Currency Code" <> '' then begin
                    UpdateCurrencyFactor();
                    if "Currency Factor" <> xRec."Currency Factor" then
                        ConfirmUpdateCurrencyFactor();
                end;

                "Document Date" := "Posting Date";
                "VAT Date" := "Posting Date";
            end;
        }
        field(7; Amount; Decimal)
        {
            Caption = 'Amount';
            CalcFormula = Sum("Cash Document Line CZP".Amount where("Cash Desk No." = field("Cash Desk No."), "Cash Document No." = field("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            CalcFormula = Sum("Cash Document Line CZP"."Amount (LCY)" where("Cash Desk No." = field("Cash Desk No."), "Cash Document No." = field("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; Status; Enum "Cash Document Status CZP")
        {
            Caption = 'Status';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(15; "No. Printed"; Integer)
        {
            Caption = 'No. Printed';
            DataClassification = CustomerContent;
        }
        field(17; "Created ID"; Code[50])
        {
            Caption = 'Created ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(18; "Released ID"; Code[50])
        {
            Caption = 'Released ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(20; "Document Type"; Enum "Cash Document Type CZP")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Document Type" <> xRec."Document Type" then
                    TestField("No.", '');
            end;
        }
        field(21; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(22; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not (CurrFieldNo in [0, FieldNo("Posting Date")]) then;
                if CurrFieldNo <> FieldNo("Currency Code") then
                    UpdateCurrencyFactor()
                else
                    if "Currency Code" <> xRec."Currency Code" then
                        UpdateCurrencyFactor()
                    else
                        if "Currency Code" <> '' then begin
                            UpdateCurrencyFactor();
                            if "Currency Factor" <> xRec."Currency Factor" then
                                ConfirmUpdateCurrencyFactor();
                        end;
            end;
        }
        field(23; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(24; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(25; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateCashDocumentLinesByFieldNo(FieldNo("Currency Factor"), false);
            end;
        }
        field(30; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(35; "VAT Date"; Date)
        {
            Caption = 'VAT Date';
            DataClassification = CustomerContent;
        }
        field(38; "Created Date"; Date)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
        }
        field(40; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(42; "Salespers./Purch. Code"; Code[20])
        {
            Caption = 'Salespers./Purch. Code';
            TableRelation = "Salesperson/Purchaser";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CreateDim(
                  Database::"Responsibility Center", "Responsibility Center",
                  Database::"Salesperson/Purchaser", "Salespers./Purch. Code",
                  Database::"Cash Desk CZP", "Cash Desk No.",
                  GetPartnerTableNo(), "Partner No.");
            end;
        }
        field(45; "Amounts Including VAT"; Boolean)
        {
            Caption = 'Amounts Including VAT';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateCashDocumentLinesByFieldNo(FieldNo("Amounts Including VAT"), true);
            end;
        }
        field(50; "Released Amount"; Decimal)
        {
            Caption = 'Released Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(51; "VAT Base Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Cash Document Line CZP"."VAT Base Amount" where("Cash Desk No." = field("Cash Desk No."), "Cash Document No." = field("No.")));
            Caption = 'VAT Base Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(52; "Amount Including VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Cash Document Line CZP"."Amount Including VAT" where("Cash Desk No." = field("Cash Desk No."), "Cash Document No." = field("No.")));
            Caption = 'Amount Including VAT';
            Editable = false;
            FieldClass = FlowField;
        }
        field(55; "VAT Base Amount (LCY)"; Decimal)
        {
            CalcFormula = Sum("Cash Document Line CZP"."VAT Base Amount (LCY)" where("Cash Desk No." = field("Cash Desk No."), "Cash Document No." = field("No.")));
            Caption = 'VAT Base Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(56; "Amount Including VAT (LCY)"; Decimal)
        {
            CalcFormula = Sum("Cash Document Line CZP"."Amount Including VAT (LCY)" where("Cash Desk No." = field("Cash Desk No."), "Cash Document No." = field("No.")));
            Caption = 'Amount Including VAT (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(60; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
            DataClassification = CustomerContent;
        }
        field(61; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateCashDocumentLinesByFieldNo(FieldNo("External Document No."), CurrFieldNo <> 0);
            end;
        }
        field(62; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not UserSetupManagement.CheckRespCenter(3, "Responsibility Center") then
                    Error(RespCenterErr, FieldCaption("Responsibility Center"), CashDeskManagementCZP.GetUserCashResponsibilityFilter(CopyStr(UserId(), 1, 50)));

                CreateDim(
                  Database::"Responsibility Center", "Responsibility Center",
                  Database::"Salesperson/Purchaser", "Salespers./Purch. Code",
                  Database::"Cash Desk CZP", "Cash Desk No.",
                  GetPartnerTableNo(), "Partner No.");
            end;
        }
        field(65; "Payment Purpose"; Text[100])
        {
            Caption = 'Payment Purpose';
            DataClassification = CustomerContent;
        }
        field(70; "Received By"; Text[100])
        {
            Caption = 'Received By';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
                TestField("Document Type", "Document Type"::Receipt);
            end;
        }
        field(71; "Identification Card No."; Code[10])
        {
            Caption = 'Identification Card No.';
            DataClassification = CustomerContent;
        }
        field(72; "Paid By"; Text[100])
        {
            Caption = 'Paid By';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
                TestField("Document Type", "Document Type"::Withdrawal);
            end;
        }
        field(73; "Received From"; Text[100])
        {
            Caption = 'Received From';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Document Type", "Document Type"::Receipt);
            end;
        }
        field(74; "Paid To"; Text[100])
        {
            Caption = 'Paid To';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Document Type", "Document Type"::Withdrawal);
            end;
        }
        field(80; "Registration No."; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;
        }
        field(81; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            DataClassification = CustomerContent;
        }
        field(90; "Partner Type"; Enum "Cash Document Partner Type CZP")
        {
            Caption = 'Partner Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Partner Type" <> xRec."Partner Type" then
                    Validate("Partner No.", '');
            end;
        }
        field(91; "Partner No."; Code[20])
        {
            Caption = 'Partner No.';
            TableRelation = if ("Partner Type" = const(Customer)) Customer else
            if ("Partner Type" = const(Vendor)) Vendor else
            if ("Partner Type" = const(Contact)) Contact else
            if ("Partner Type" = const("Salesperson/Purchaser")) "Salesperson/Purchaser" else
            if ("Partner Type" = const(Employee)) Employee;
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                case "Partner Type" of
                    "Partner Type"::Customer:
                        begin
                            Clear(Customer);
                            if Page.RunModal(0, Customer) = Action::LookupOK then
                                Validate("Partner No.", Customer."No.");
                        end;
                    "Partner Type"::Vendor:
                        begin
                            Clear(Vendor);
                            if Page.RunModal(0, Vendor) = Action::LookupOK then
                                Validate("Partner No.", Vendor."No.");
                        end;
                    "Partner Type"::Contact:
                        begin
                            Clear(Contact);
                            if Page.RunModal(0, Contact) = Action::LookupOK then
                                Validate("Partner No.", Contact."No.");
                        end;
                    "Partner Type"::"Salesperson/Purchaser":
                        begin
                            Clear(SalespersonPurchaser);
                            if Page.RunModal(0, SalespersonPurchaser) = Action::LookupOK then
                                Validate("Partner No.", SalespersonPurchaser.Code);
                        end;
                    "Partner Type"::Employee:
                        begin
                            Clear(Employee);
                            if Page.RunModal(0, Employee) = Action::LookupOK then
                                Validate("Partner No.", Employee."No.");
                        end;
                end;
            end;

            trigger OnValidate()
            begin
                if "Partner No." = '' then begin
                    case "Document Type" of
                        "Document Type"::Receipt:
                            "Received From" := '';
                        "Document Type"::Withdrawal:
                            "Paid To" := '';
                    end;
                    "Registration No." := '';
                    "VAT Registration No." := '';
                end else
                    case "Partner Type" of
                        "Partner Type"::" ":
                            begin
                                case "Document Type" of
                                    "Document Type"::Receipt:
                                        "Received From" := '';
                                    "Document Type"::Withdrawal:
                                        "Paid To" := '';
                                end;
                                "Registration No." := '';
                                "VAT Registration No." := '';
                            end;
                        "Partner Type"::Customer:
                            begin
                                Customer.Get("Partner No.");
                                case "Document Type" of
                                    "Document Type"::Receipt:
                                        "Received From" := Customer.Name;
                                    "Document Type"::Withdrawal:
                                        "Paid To" := Customer.Name;
                                end;
                                "VAT Registration No." := Customer."VAT Registration No.";
                                "Registration No." := Customer."Registration No. CZL";
                            end;
                        "Partner Type"::Vendor:
                            begin
                                Vendor.Get("Partner No.");
                                case "Document Type" of
                                    "Document Type"::Receipt:
                                        "Received From" := Vendor.Name;
                                    "Document Type"::Withdrawal:
                                        "Paid To" := Vendor.Name;
                                end;
                                "VAT Registration No." := Vendor."VAT Registration No.";
                                "Registration No." := Vendor."Registration No. CZL";
                            end;
                        "Partner Type"::Contact:
                            begin
                                Contact.Get("Partner No.");
                                case "Document Type" of
                                    "Document Type"::Receipt:
                                        "Received From" := Contact.Name;
                                    "Document Type"::Withdrawal:
                                        "Paid To" := Contact.Name;
                                end;
                                "VAT Registration No." := Contact."VAT Registration No.";
                                "Registration No." := Contact."Registration No. CZL";
                            end;
                        "Partner Type"::"Salesperson/Purchaser":
                            begin
                                SalespersonPurchaser.Get("Partner No.");
                                case "Document Type" of
                                    "Document Type"::Receipt:
                                        "Received From" := SalespersonPurchaser.Name;
                                    "Document Type"::Withdrawal:
                                        "Paid To" := SalespersonPurchaser.Name;
                                end;
                            end;
                        "Partner Type"::Employee:
                            begin
                                Employee.Get("Partner No.");
                                case "Document Type" of
                                    "Document Type"::Receipt:
                                        "Received From" := CopyStr(Employee.FullName(), 1, MaxStrLen("Received From"));
                                    "Document Type"::Withdrawal:
                                        "Paid To" := CopyStr(Employee.FullName(), 1, MaxStrLen("Paid To"));
                                end;
                            end;
                    end;

                CreateDim(
                  GetPartnerTableNo(), "Partner No.",
                  Database::"Responsibility Center", "Responsibility Center",
                  Database::"Salesperson/Purchaser", "Salespers./Purch. Code",
                  Database::"Cash Desk CZP", "Cash Desk No.");
            end;
        }
        field(98; "Canceled Document"; Boolean)
        {
            Caption = 'Canceled Document';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(100; "EET Cash Register"; Boolean)
        {
            CalcFormula = Exist("EET Cash Register CZL" where("Cash Register Type" = const("Cash Desk"),
                                                           "Cash Register No." = field("Cash Desk No.")));
            Caption = 'EET Cash Register';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101; "EET Transaction"; Boolean)
        {
            CalcFormula = Exist("Cash Document Line CZP" where("Cash Desk No." = field("Cash Desk No."),
                                                            "Cash Document No." = field("No."),
                                                            "EET Transaction" = const(true)));
            Caption = 'EET Transaction';
            Editable = false;
            FieldClass = FlowField;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                ShowDocDim();
            end;

            trigger OnValidate()
            begin
                DimensionManagement.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
    }

    keys
    {
        key(Key1; "Cash Desk No.", "No.")
        {
            Clustered = true;
        }
        key(Key2; "Cash Desk No.", "Posting Date")
        {
        }
        key(Key3; "External Document No.")
        {
        }
        key(Key4; "No.", "Posting Date")
        {
        }
        key(Key5; "Cash Desk No.", "Document Type", Status, "Posting Date")
        {
            SumIndexFields = "Released Amount";
        }
        key(Key6; "Document Type", "No.")
        {
        }
    }

    var
        PaymentTxt: Label 'Payment %1', Comment = '%1 = Document No.';
        RefundTxt: Label 'Refund %1', Comment = '%1 = Document No.';

    trigger OnDelete()
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        CashDocumentPostCZP: Codeunit "Cash Document-Post CZP";
    begin
        TestField(Status, Status::Open);
        if not ConfirmManagement.GetResponseOrDefault(DeleteQst, false) then
            Error('');

        DeleteRecordInApprovalRequest();

        CashDeskManagementCZP.CheckCashDesks();
        if not UserSetupManagement.CheckRespCenter(3, "Responsibility Center") then
            Error(RespCenterDeleteErr, FieldCaption("Responsibility Center"), CashDeskManagementCZP.GetUserCashResponsibilityFilter(CopyStr(UserId(), 1, 50)));

        CashDocumentPostCZP.DeleteCashDocumentHeader(Rec);

        CashDocumentLineCZP.SetRange("Cash Desk No.", "Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", "No.");
        CashDocumentLineCZP.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        CashDeskUserCZP: Record "Cash Desk User CZP";
        CashDocumentActionCZP: Enum "Cash Document Action CZP";
    begin
        TestField("Cash Desk No.");
        TestField("Document Type");

        GetCashDeskCZP("Cash Desk No.");
        CashDeskCZP.TestField(Blocked, false);
        if CashDeskCZP."Responsibility ID (Release)" <> '' then
            if CashDeskCZP."Responsibility ID (Release)" <> UserId then
                Error(RespCreateErr, TableCaption, CashDeskCZP.TableCaption, "Cash Desk No.");

        CashDeskManagementCZP.CheckUserRights("Cash Desk No.", CashDocumentActionCZP::Create);

        if CashDeskCZP."Confirm Inserting of Document" then
            if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(CreateQst, "Document Type", "Cash Desk No."), true) then
                Error('');

        if "No." = '' then
            case "Document Type" of
                "Document Type"::Receipt:
                    begin
                        CashDeskCZP.TestField("Cash Document Receipt Nos.");
                        NoSeriesManagement.InitSeries(CashDeskCZP."Cash Document Receipt Nos.", xRec."No. Series", WorkDate(), "No.", "No. Series");
                    end;
                "Document Type"::Withdrawal:
                    begin
                        CashDeskCZP.TestField("Cash Document Withdrawal Nos.");
                        NoSeriesManagement.InitSeries(CashDeskCZP."Cash Document Withdrawal Nos.", xRec."No. Series", WorkDate(), "No.", "No. Series");
                    end;
            end;

        "Posting Date" := WorkDate();
        "Document Date" := "Posting Date";
        "VAT Date" := "Posting Date";
        "Created ID" := CopyStr(UserId, 1, MaxStrLen("Created ID"));
        "Created Date" := WorkDate();

        "Responsibility Center" := CashDeskCZP."Responsibility Center";
        "Amounts Including VAT" := CashDeskCZP."Amounts Including VAT";
        "Reason Code" := CashDeskCZP."Reason Code";
        Validate("Currency Code", CashDeskCZP."Currency Code");

        case "Document Type" of
            "Document Type"::Receipt:
                "Received By" := CashDeskUserCZP."User Full Name";
            "Document Type"::Withdrawal:
                "Paid By" := CashDeskUserCZP."User Full Name";
        end;

        CreateDim(
          Database::"Responsibility Center", "Responsibility Center",
          Database::"Salesperson/Purchaser", "Salespers./Purch. Code",
          Database::"Cash Desk CZP", "Cash Desk No.",
          GetPartnerTableNo(), "Partner No.");
    end;

    trigger OnModify()
    begin
        if not UserSetupManagement.CheckRespCenter(3, "Responsibility Center") then
            Error(RespCenterModifyErr, FieldCaption("Responsibility Center"), CashDeskManagementCZP.GetUserCashResponsibilityFilter(CopyStr(UserId(), 1, 50)));
    end;

    trigger OnRename()
    begin
        Error(RenameErr, TableCaption);
    end;

    var
        CashDeskCZP: Record "Cash Desk CZP";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Contact: Record Contact;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Employee: Record Employee;
        NoSeriesManagement: Codeunit NoSeriesManagement;
        DimensionManagement: Codeunit DimensionManagement;
        UserSetupManagement: Codeunit "User Setup Management";
        ConfirmManagement: Codeunit "Confirm Management";
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";
        RenameErr: Label 'You cannot rename a %1.', Comment = '%1 = TableCaption';
        UpdateExchRateQst: Label 'Do you want to update the exchange rate?';
        UpdateLinesQst: Label 'You have modified %1.\Do you want to update lines?', Comment = '%1=Changed Field Name';
        UpdateLinesDimQst: Label 'You may have changed a dimension.\\Do you want to update the lines?';
        RespCenterErr: Label 'Your identification is set up to process from %1 %2 only.', Comment = '%1 = fieldcaption of Responsibility Center; %2 = Responsibility Center';
        RespCenterModifyErr: Label 'You cannot modify this document. Your identification is set up to process from %1 %2 only.', Comment = '%1 = fieldcaption of Responsibility Center; %2 = Responsibility Center';
        RespCenterDeleteErr: Label 'You cannot delete this document. Your identification is set up to process from %1 %2 only.', Comment = '%1 = fieldcaption of Responsibility Center; %2 = Responsibility Center';
        RespCreateErr: Label 'You are not allowed create %1 on %2 %3.', Comment = '%1 = TableCaption, %2 = Cash Desk TableCaption, %3= Cash Desk No.';
        CreateQst: Label 'Do you want to create %1 at Cash Desk %2?', Comment = '%1 = Cash Document Type, %2 = Cash Desk No.';
        DeleteQst: Label 'Deleting this document will cause a gap in the number series for posted cash documents.\Do you want continue?';
        CurrencyDate: Date;
        SkipLineNo: Integer;
        HideValidationDialog: Boolean;

    procedure AssistEdit(OldCashDocumentHeaderCZP: Record "Cash Document Header CZP"): Boolean
    begin
        OldCashDocumentHeaderCZP.Copy(Rec);
        TestNoSeries();
        if NoSeriesManagement.SelectSeries(GetNoSeriesCode(), OldCashDocumentHeaderCZP."No. Series", OldCashDocumentHeaderCZP."No. Series") then begin
            NoSeriesManagement.SetSeries(OldCashDocumentHeaderCZP."No.");
            Rec := OldCashDocumentHeaderCZP;
            exit(true);
        end;
    end;

    local procedure TestNoSeries()
    begin
        GetCashDeskCZP("Cash Desk No.");
        case "Document Type" of
            "Document Type"::Receipt:
                CashDeskCZP.TestField("Cash Document Receipt Nos.");
            "Document Type"::Withdrawal:
                CashDeskCZP.TestField("Cash Document Withdrawal Nos.");
        end;
    end;

    local procedure GetNoSeriesCode(): Code[20]
    begin
        GetCashDeskCZP("Cash Desk No.");
        case "Document Type" of
            "Document Type"::Receipt:
                exit(CashDeskCZP."Cash Document Receipt Nos.");
            "Document Type"::Withdrawal:
                exit(CashDeskCZP."Cash Document Withdrawal Nos.");
        end;
    end;

    local procedure UpdateCurrencyFactor()
    begin
        if "Currency Code" <> '' then begin
            if "Posting Date" = 0D then
                CurrencyDate := WorkDate()
            else
                CurrencyDate := "Posting Date";
            "Currency Factor" := CurrencyExchangeRate.ExchangeRate(CurrencyDate, "Currency Code");
        end else
            "Currency Factor" := 0;

        Validate("Currency Factor");
    end;

    local procedure ConfirmUpdateCurrencyFactor()
    begin
        if ConfirmManagement.GetResponseOrDefault(UpdateExchRateQst, false) then
            Validate("Currency Factor")
        else
            Validate("Currency Factor", xRec."Currency Factor")
    end;

    procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20]; Type3: Integer; No3: Code[20]; Type4: Integer; No4: Code[20])
    var
        SourceCodeSetup: Record "Source Code Setup";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        OldDimSetID: Integer;
    begin
        SourceCodeSetup.Get();
        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        TableID[3] := Type3;
        No[3] := No3;
        TableID[4] := Type4;
        No[4] := No4;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimensionManagement.GetRecDefaultDimID(
            Rec, CurrFieldNo, TableID, No, SourceCodeSetup."Cash Desk CZP",
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);

        if (OldDimSetID <> "Dimension Set ID") and CashDocLinesExist() then begin
            Modify();
            UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        DimensionManagement.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        if "No." <> '' then
            Modify();

        if OldDimSetID <> "Dimension Set ID" then begin
            Modify();
            if CashDocLinesExist() then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    procedure ShowDocDim()
    var
        OldDimSetID: Integer;
        IsHandled: Boolean;
        TwoPlaceholdersTok: Label '%1 %2', Locked = true;
    begin
        IsHandled := false;
        OnBeforeShowDocDim(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimensionManagement.EditDimensionSet(
            "Dimension Set ID", StrSubstNo(TwoPlaceholdersTok, TableCaption, "No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        OnShowDocDimOnBeforeUpdateCashDocumentLines(Rec, xRec);
        if OldDimSetID <> "Dimension Set ID" then begin
            Modify();
            if CashDocLinesExist() then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    local procedure UpdateAllLineDim(NewParentDimSetID: Integer; OldParentDimSetID: Integer)
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        NewDimSetID: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateAllLineDim(Rec, NewParentDimSetID, OldParentDimSetID, IsHandled, xRec);
        if IsHandled then
            exit;
        if NewParentDimSetID = OldParentDimSetID then
            exit;

        CashDocumentLineCZP.SetRange("Cash Desk No.", "Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", "No.");
        if SkipLineNo <> 0 then
            CashDocumentLineCZP.SetFilter("Line No.", '<>%1', SkipLineNo);
        if CashDocumentLineCZP.IsEmpty() then
            exit;
        if not GetHideValidationDialog() and GuiAllowed then
            if not ConfirmManagement.GetResponseOrDefault(UpdateLinesDimQst, true) then
                exit;

        CashDocumentLineCZP.LockTable();
        if CashDocumentLineCZP.FindSet() then
            repeat
                NewDimSetID := DimensionManagement.GetDeltaDimSetID(CashDocumentLineCZP."Dimension Set ID", NewParentDimSetID, OldParentDimSetID);
                if CashDocumentLineCZP."Dimension Set ID" <> NewDimSetID then begin
                    CashDocumentLineCZP."Dimension Set ID" := NewDimSetID;
                    DimensionManagement.UpdateGlobalDimFromDimSetID(
                      CashDocumentLineCZP."Dimension Set ID", CashDocumentLineCZP."Shortcut Dimension 1 Code", CashDocumentLineCZP."Shortcut Dimension 2 Code");
                    CashDocumentLineCZP.Modify();
                end;
            until CashDocumentLineCZP.Next() = 0;
    end;

    procedure UpdateCashDocumentLinesByFieldNo(ChangedFieldNo: Integer; AskQuestion: Boolean)
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        "Field": Record "Field";
        Question: Text[250];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateCashDocumentLinesByFieldNo(Rec, ChangedFieldNo, AskQuestion, IsHandled);
        if IsHandled then
            exit;

        if not CashDocLinesExist() then
            exit;

        if not Field.Get(Database::"Cash Document Header CZP", ChangedFieldNo) then
            Field.Get(Database::"Cash Document Line CZP", ChangedFieldNo);

        if AskQuestion then begin
            Question := StrSubstNo(UpdateLinesQst, Field."Field Caption");
            if GuiAllowed and not GetHideValidationDialog() then
                if not Dialog.Confirm(Question, true) then
                    exit;
        end;

        CashDocumentLineCZP.LockTable();
        Modify();

        CashDocumentLineCZP.SetRange("Cash Desk No.", "Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", "No.");
        if CashDocumentLineCZP.FindSet(true) then
            repeat
                case ChangedFieldNo of
                    FieldNo("External Document No."):
                        CashDocumentLineCZP.Validate("External Document No.", "External Document No.");
                    FieldNo("Currency Factor"):
                        if CashDocumentLineCZP.Amount <> 0 then
                            CashDocumentLineCZP.Validate(Amount);
                    FieldNo("Amounts Including VAT"):
                        if CashDocumentLineCZP.Amount <> 0 then
                            CashDocumentLineCZP.Validate(Amount);
                end;
                CashDocumentLineCZP.Modify(true);
            until CashDocumentLineCZP.Next() = 0;
        CalcFields("VAT Base Amount", "Amount Including VAT", "VAT Base Amount (LCY)", "Amount Including VAT (LCY)");
    end;

    procedure VATRounding()
    var
        RoundingMethod: Record "Rounding Method";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        Direction: Text[1];
        RoundedAmount: Decimal;
        LineNo: Integer;
    begin
        if not CashDocLinesExist() then
            exit;

        GetCashDeskCZP("Cash Desk No.");
        CashDeskCZP.TestField("Rounding Method Code");
        CashDeskCZP.TestField("Debit Rounding Account");
        CashDeskCZP.TestField("Credit Rounding Account");

        CalcFields("Amount Including VAT");
        CashDocumentLineCZP.SetRange("Cash Desk No.", "Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", "No.");
        CashDocumentLineCZP.SetRange("Account Type", CashDocumentLineCZP."Account Type"::"G/L Account");
        CashDocumentLineCZP.SetFilter("Account No.", '%1|%2', CashDeskCZP."Debit Rounding Account", CashDeskCZP."Credit Rounding Account");
        CashDocumentLineCZP.SetRange("System-Created Entry", true);
        if CashDocumentLineCZP.FindFirst() then
            "Amount Including VAT" -= CashDocumentLineCZP."Amount Including VAT";

        RoundingMethod.SetRange(Code, CashDeskCZP."Rounding Method Code");
        RoundingMethod.SetFilter("Minimum Amount", '..%1', Abs("Amount Including VAT"));
        RoundingMethod.FindLast();
        RoundingMethod.TestField(Precision);
        case RoundingMethod.Type of
            RoundingMethod.Type::Nearest:
                Direction := '=';
            RoundingMethod.Type::Up:
                Direction := '>';
            RoundingMethod.Type::Down:
                Direction := '<';
        end;
        RoundedAmount := Round("Amount Including VAT", RoundingMethod.Precision, Direction) - "Amount Including VAT";

        if (RoundedAmount <> 0) and (CashDocumentLineCZP."Amount Including VAT" <> RoundedAmount) then begin
            CashDocumentLineCZP.DeleteAll(true);

            CashDocumentLineCZP.Reset();
            CashDocumentLineCZP.SetRange("Cash Desk No.", "Cash Desk No.");
            CashDocumentLineCZP.SetRange("Cash Document No.", "No.");
            if CashDocumentLineCZP.FindLast() then
                LineNo := CashDocumentLineCZP."Line No.";
            LineNo += 10000;

            CashDocumentLineCZP.Init();
            CashDocumentLineCZP."Cash Desk No." := "Cash Desk No.";
            CashDocumentLineCZP."Cash Document No." := "No.";
            CashDocumentLineCZP."Line No." := LineNo;
            CashDocumentLineCZP.Validate("Account Type", CashDocumentLineCZP."Account Type"::"G/L Account");
            case "Document Type" of
                "Document Type"::Receipt:
                    if RoundedAmount < 0 then
                        CashDocumentLineCZP.Validate("Account No.", CashDeskCZP."Debit Rounding Account")
                    else
                        CashDocumentLineCZP.Validate("Account No.", CashDeskCZP."Credit Rounding Account");
                "Document Type"::Withdrawal:
                    if RoundedAmount > 0 then
                        CashDocumentLineCZP.Validate("Account No.", CashDeskCZP."Debit Rounding Account")
                    else
                        CashDocumentLineCZP.Validate("Account No.", CashDeskCZP."Credit Rounding Account");
            end;
            CashDocumentLineCZP.Validate("Currency Code", "Currency Code");
            if "Amounts Including VAT" then
                CashDocumentLineCZP.Validate(Amount, RoundedAmount)
            else begin
                CashDocumentLineCZP.Validate("Amount Including VAT", RoundedAmount);
                CashDocumentLineCZP.Amount := CashDocumentLineCZP."VAT Base Amount";
                CashDocumentLineCZP."Amount (LCY)" := Round(CashDocumentLineCZP.Amount);
                if "Currency Code" <> '' then
                    CashDocumentLineCZP."Amount (LCY)" :=
                      Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY("Posting Date", "Currency Code", CashDocumentLineCZP.Amount, "Currency Factor"));
            end;
            CashDocumentLineCZP."System-Created Entry" := true;
            CashDocumentLineCZP.Insert(true);
        end;
    end;

    procedure GetPartnerTableNo(): Integer
    begin
        case "Partner Type" of
            "Partner Type"::Customer:
                exit(Database::Customer);
            "Partner Type"::Vendor:
                exit(Database::Vendor);
            "Partner Type"::Contact:
                exit(Database::Contact);
            "Partner Type"::"Salesperson/Purchaser":
                exit(Database::"Salesperson/Purchaser");
            "Partner Type"::Employee:
                exit(Database::Employee);
            else
                exit(0);
        end;
    end;

    procedure CashDocLinesExist(): Boolean
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        CashDocumentLineCZP.SetRange("Cash Desk No.", "Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", "No.");
        exit(not CashDocumentLineCZP.IsEmpty());
    end;

    procedure PrintRecords(ShowRequestForm: Boolean)
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDeskRepSelectionsCZP: Record "Cash Desk Rep. Selections CZP";
    begin
        TestField("Document Type");
        CashDocumentHeaderCZP.Copy(Rec);
        case CashDocumentHeaderCZP."Document Type" of
            CashDocumentHeaderCZP."Document Type"::Receipt:
                CashDeskRepSelectionsCZP.SetRange(Usage, CashDeskRepSelectionsCZP.Usage::"Cash Receipt");
            CashDocumentHeaderCZP."Document Type"::Withdrawal:
                CashDeskRepSelectionsCZP.SetRange(Usage, CashDeskRepSelectionsCZP.Usage::"Cash Withdrawal");
        end;
        CashDeskRepSelectionsCZP.SetFilter("Report ID", '<>0');
        CashDeskRepSelectionsCZP.FindSet();
        repeat
            Report.RunModal(CashDeskRepSelectionsCZP."Report ID", ShowRequestForm, false, CashDocumentHeaderCZP);
        until CashDeskRepSelectionsCZP.Next() = 0;
    end;

    procedure PrintToDocumentAttachment()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDeskRepSelectionsCZP: Record "Cash Desk Rep. Selections CZP";
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentMgmt: Codeunit "Document Attachment Mgmt";
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        DummyInStream: InStream;
        ReportOutStream: OutStream;
        DocumentInStream: InStream;
        FileName: Text[250];
        DocumentAttachmentFileNameLbl: Label '%1 %2', Comment = '%1 = Usage, %2 = Cash Document No.';
    begin
        TestField(Status, Status::Released);
        CashDocumentHeaderCZP := Rec;
        CashDocumentHeaderCZP.SetRecFilter();
        RecordRef.GetTable(CashDocumentHeaderCZP);
        if not RecordRef.FindFirst() then
            exit;

        case CashDocumentHeaderCZP."Document Type" of
            CashDocumentHeaderCZP."Document Type"::Receipt:
                CashDeskRepSelectionsCZP.SetRange(Usage, CashDeskRepSelectionsCZP.Usage::"Cash Receipt");
            CashDocumentHeaderCZP."Document Type"::Withdrawal:
                CashDeskRepSelectionsCZP.SetRange(Usage, CashDeskRepSelectionsCZP.Usage::"Cash Withdrawal");
        end;
        CashDeskRepSelectionsCZP.SetFilter("Report ID", '<>0');
        CashDeskRepSelectionsCZP.FindSet();
        repeat
            if not Report.RdlcLayout(CashDeskRepSelectionsCZP."Report ID", DummyInStream) then
                exit;

            Clear(TempBlob);
            TempBlob.CreateOutStream(ReportOutStream);
            Report.SaveAs(CashDeskRepSelectionsCZP."Report ID", '',
                        ReportFormat::Pdf, ReportOutStream, RecordRef);

            Clear(DocumentAttachment);
            DocumentAttachment.InitFieldsFromRecRef(RecordRef);
            FileName := DocumentAttachment.FindUniqueFileName(
                        StrSubstNo(DocumentAttachmentFileNameLbl, CashDeskRepSelectionsCZP.Usage, CashDocumentHeaderCZP."No."), 'pdf');
            TempBlob.CreateInStream(DocumentInStream);
            DocumentAttachment.SaveAttachmentFromStream(DocumentInStream, RecordRef, FileName);
        until CashDeskRepSelectionsCZP.Next() = 0;
        DocumentAttachmentMgmt.ShowNotification(RecordRef, CashDeskRepSelectionsCZP.Count(), true);
    end;

    procedure SetSkipLineNoToUpdateLine(LineNo: Integer)
    begin
        SkipLineNo := LineNo;
    end;

    procedure SignAmount(): Integer
    begin
        if "Document Type" = "Document Type"::Receipt then
            exit(-1);
        exit(1);
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure GetHideValidationDialog(): Boolean
    begin
        exit(HideValidationDialog);
    end;

    local procedure IsApprovedForPosting(): Boolean
    var
        CashDocumentApprovMgtCZP: Codeunit "Cash Document Approv. Mgt. CZP";
    begin
        if CashDocumentApprovMgtCZP.PrePostApprovalCheckCashDoc(Rec) then
            exit(true);
    end;

    procedure SendToPosting(PostingCodeunitID: Integer)
    begin
        if not IsApprovedForPosting() then
            exit;
        Codeunit.Run(PostingCodeunitID, Rec);
    end;

    procedure CopyFromSalesInvoiceHeader(SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        Validate("Posting Date", SalesInvoiceHeader."Posting Date");
        Validate("Responsibility Center", SalesInvoiceHeader."Responsibility Center");
        "Currency Factor" := SalesInvoiceHeader."Currency Factor";
        "Shortcut Dimension 1 Code" := SalesInvoiceHeader."Shortcut Dimension 1 Code";
        "Shortcut Dimension 2 Code" := SalesInvoiceHeader."Shortcut Dimension 2 Code";
        "Dimension Set ID" := SalesInvoiceHeader."Dimension Set ID";
        "Payment Purpose" := StrSubstNo(PaymentTxt, SalesInvoiceHeader."No.");
        "Partner Type" := "Partner Type"::Customer;
        Validate("Partner No.", SalesInvoiceHeader."Bill-to Customer No.");
        OnAfterCopyCashDocumentHeaderFromSalesInvHeader(SalesInvoiceHeader, Rec);
    end;

    procedure CopyFromSalesCrMemoHeader(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        Validate("Posting Date", SalesCrMemoHeader."Posting Date");
        Validate("Responsibility Center", SalesCrMemoHeader."Responsibility Center");
        "Currency Factor" := SalesCrMemoHeader."Currency Factor";
        "Shortcut Dimension 1 Code" := SalesCrMemoHeader."Shortcut Dimension 1 Code";
        "Shortcut Dimension 2 Code" := SalesCrMemoHeader."Shortcut Dimension 2 Code";
        "Dimension Set ID" := SalesCrMemoHeader."Dimension Set ID";
        "Payment Purpose" := StrSubstNo(RefundTxt, SalesCrMemoHeader."No.");
        "Partner Type" := "Partner Type"::Customer;
        Validate("Partner No.", SalesCrMemoHeader."Bill-to Customer No.");
        OnAfterCopyCashDocumentHeaderFromSalesCrMemoHeader(SalesCrMemoHeader, Rec);
    end;

    procedure CopyFromPurchInvHeader(PurchInvHeader: Record "Purch. Inv. Header")
    begin
        Validate("Posting Date", PurchInvHeader."Posting Date");
        Validate("Responsibility Center", PurchInvHeader."Responsibility Center");
        "Currency Factor" := PurchInvHeader."Currency Factor";
        "Shortcut Dimension 1 Code" := PurchInvHeader."Shortcut Dimension 1 Code";
        "Shortcut Dimension 2 Code" := PurchInvHeader."Shortcut Dimension 2 Code";
        "Dimension Set ID" := PurchInvHeader."Dimension Set ID";
        "Payment Purpose" := StrSubstNo(RefundTxt, PurchInvHeader."No.");
        "Partner Type" := "Partner Type"::Vendor;
        Validate("Partner No.", PurchInvHeader."Buy-from Vendor No.");
        OnAfterCopyCashDocumentHeaderFromPurchInvHeader(PurchInvHeader, Rec);
    end;

    procedure CopyFromPurchCrMemoHeader(PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    begin
        Validate("Posting Date", PurchCrMemoHdr."Posting Date");
        Validate("Responsibility Center", PurchCrMemoHdr."Responsibility Center");
        "Currency Factor" := PurchCrMemoHdr."Currency Factor";
        "Shortcut Dimension 1 Code" := PurchCrMemoHdr."Shortcut Dimension 1 Code";
        "Shortcut Dimension 2 Code" := PurchCrMemoHdr."Shortcut Dimension 2 Code";
        "Dimension Set ID" := PurchCrMemoHdr."Dimension Set ID";
        "Payment Purpose" := StrSubstNo(PaymentTxt, PurchCrMemoHdr."No.");
        "Partner Type" := "Partner Type"::Vendor;
        Validate("Partner No.", PurchCrMemoHdr."Buy-from Vendor No.");
        OnAfterCopyCashDocumentHeaderFromPurchCrMemoHdr(PurchCrMemoHdr, Rec);
    end;

    procedure CopyFromServiceInvoiceHeader(ServiceInvoiceHeader: Record "Service Invoice Header")
    begin
        Validate("Posting Date", ServiceInvoiceHeader."Posting Date");
        Validate("Responsibility Center", ServiceInvoiceHeader."Responsibility Center");
        "Currency Factor" := ServiceInvoiceHeader."Currency Factor";
        "Shortcut Dimension 1 Code" := ServiceInvoiceHeader."Shortcut Dimension 1 Code";
        "Shortcut Dimension 2 Code" := ServiceInvoiceHeader."Shortcut Dimension 2 Code";
        "Dimension Set ID" := ServiceInvoiceHeader."Dimension Set ID";
        "Payment Purpose" := StrSubstNo(PaymentTxt, ServiceInvoiceHeader."No.");
        "Partner Type" := "Partner Type"::Customer;
        Validate("Partner No.", ServiceInvoiceHeader."Bill-to Customer No.");
        OnAfterCopyCashDocumentHeaderFromServiceInvoiceHeader(ServiceInvoiceHeader, Rec);
    end;

    procedure CopyFromServiceCrMemoHeader(ServiceCrMemoHeader: Record "Service Cr.Memo Header")
    begin
        Validate("Posting Date", ServiceCrMemoHeader."Posting Date");
        Validate("Responsibility Center", ServiceCrMemoHeader."Responsibility Center");
        "Currency Factor" := ServiceCrMemoHeader."Currency Factor";
        "Shortcut Dimension 1 Code" := ServiceCrMemoHeader."Shortcut Dimension 1 Code";
        "Shortcut Dimension 2 Code" := ServiceCrMemoHeader."Shortcut Dimension 2 Code";
        "Dimension Set ID" := ServiceCrMemoHeader."Dimension Set ID";
        "Payment Purpose" := StrSubstNo(RefundTxt, ServiceCrMemoHeader."No.");
        "Partner Type" := "Partner Type"::Customer;
        Validate("Partner No.", ServiceCrMemoHeader."Bill-to Customer No.");
        OnAfterCopyCashDocumentHeaderFromServiceCrMemoHeader(ServiceCrMemoHeader, Rec);
    end;

    local procedure GetCashDeskCZP(CashDeskNo: Code[20])
    begin
        if CashDeskNo <> CashDeskCZP."No." then
            CashDeskCZP.Get(CashDeskNo);
    end;

    procedure FindEETCashRegister(var EETCashRegisterCZL: Record "EET Cash Register CZL"): Boolean
    begin
        exit(EETCashRegisterCZL.FindByCashRegisterNo("EET Cash Register Type CZL"::"Cash Desk", "Cash Desk No."));
    end;

    procedure IsEETCashRegister(): Boolean
    begin
        CalcFields("EET Cash Register");
        exit("EET Cash Register");
    end;

    procedure TestNotEETCashRegister()
    begin
        if IsEETCashRegister() then
            FieldError("EET Cash Register");
    end;

    procedure IsEETTransaction(): Boolean
    begin
        CalcFields("EET Transaction");
        exit("EET Transaction");
    end;

    procedure CheckCashDocReleaseRestrictions()
    var
        CashDocumentApprovMgtCZP: Codeunit "Cash Document Approv. Mgt. CZP";
    begin
#if not CLEAN19
#pragma warning disable AL0432
#endif
        OnCheckCashDocReleaseRestrictions();
#if not CLEAN19
#pragma warning restore AL0432
#endif
        CashDocumentApprovMgtCZP.PrePostApprovalCheckCashDoc(Rec)
    end;

    procedure CheckCashDocPostRestrictions()
    begin
#if not CLEAN19
#pragma warning disable AL0432
#endif
        OnCheckCashDocPostRestrictions();
#if not CLEAN19
#pragma warning restore AL0432
#endif
    end;

    local procedure DeleteRecordInApprovalRequest()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeDeleteRecordInApprovalRequest(Rec, IsHandled);
        if IsHandled then
            exit;

        ApprovalsMgmt.OnDeleteRecordInApprovalRequest(RecordId);
    end;

    [IntegrationEvent(true, false)]
#if not CLEAN19
    [Obsolete('The event will be changed to local. Use the CheckCashDocReleaseRestrictions function instead.', '19.0')]
    procedure OnCheckCashDocReleaseRestrictions()
#else
    local procedure OnCheckCashDocReleaseRestrictions()
#endif
    begin
    end;

    [IntegrationEvent(true, false)]
#if not CLEAN19
    [Obsolete('The event will be changed to local. Use the CheckCashDocPostRestrictions function instead.', '19.0')]
    procedure OnCheckCashDocPostRestrictions()
#else
    local procedure OnCheckCashDocPostRestrictions()
#endif
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeDeleteRecordInApprovalRequest(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateCashDocumentLinesByFieldNo(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; ChangedFieldNo: Integer; var AskQuestion: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowDocDim(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; xCashDocumentHeaderCZP: Record "Cash Document Header CZP"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShowDocDimOnBeforeUpdateCashDocumentLines(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; xCashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateAllLineDim(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; NewParentDimSetID: Integer; OldParentDimSetID: Integer; var IsHandled: Boolean; xCashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyCashDocumentHeaderFromSalesInvHeader(SalesInvoiceHeader: Record "Sales Invoice Header"; var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyCashDocumentHeaderFromSalesCrMemoHeader(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyCashDocumentHeaderFromPurchInvHeader(PurchInvHeader: Record "Purch. Inv. Header"; var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyCashDocumentHeaderFromPurchCrMemoHdr(PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyCashDocumentHeaderFromServiceInvoiceHeader(ServiceInvoiceHeader: Record "Service Invoice Header"; var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyCashDocumentHeaderFromServiceCrMemoHeader(ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;
}
