page 4014 "Intelligent Edge KPIs"
{
    PageType = CardPart;

    layout
    {
        area(Content)
        {
            cuegroup(Kpis)
            {
                ShowCaption = false;

                field(CashAvailable; "Cash Available")
                {
                    ApplicationArea = All;
                    Caption = 'Cash Available';
                    AutoFormatExpression = FormatAmount();
                    AutoFormatType = 11;
                    ToolTip = 'Specifies the value of the Cash GL Account';
                    trigger OnDrillDown()
                    var
                    begin
                        PAGE.RUN(PAGE::"G/L Account Categories");
                    end;
                }
                field(SalesProfitability; "Sales Profitability")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Profitability';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<precision, 1:1><standard format,0>%';
                    ToolTip = 'Specifies the profitibilty as a percentage of sales';
                    trigger OnDrillDown()
                    var
                    begin
                        PAGE.RUN(PAGE::"G/L Account Categories");
                    end;
                }
                field(NetIncome; "Net Income")
                {
                    ApplicationArea = All;
                    Caption = 'Net Income';
                    AutoFormatExpression = FormatAmount();
                    AutoFormatType = 11;
                    ToolTip = 'Specifies the Net Income';
                    trigger OnDrillDown()
                    var
                    begin
                        PAGE.RUN(PAGE::"G/L Account Categories");
                    end;
                }
                field(InventoryValue; "Inventory Value")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Value';
                    AutoFormatExpression = FormatAmount();
                    AutoFormatType = 11;
                    ToolTip = 'Specifies the value of the Inventory GL Account';
                    trigger OnDrillDown()
                    var
                    begin
                        PAGE.RUN(PAGE::"G/L Account Categories");
                    end;
                }
            }
        }
    }

    var
        "Cash Available": Decimal;
        "Sales Profitability": Decimal;
        "Net Income": Decimal;
        "Inventory Value": Decimal;

    trigger OnOpenPage()
    var
        CalculateAmounts: Codeunit CalculateAmounts;
    begin
        "Cash Available" := CalculateAmounts.CashAvailable();
        "Sales Profitability" := CalculateAmounts.SalesProfitability("Net Income");
        "Inventory Value" := CalculateAmounts.InventoryValue();
    end;

    procedure FormatAmount(): Text
    var
        GeneralLedgerSetup: record "General Ledger Setup";
        UserPersonalization: Record "User Personalization";
        CurrencySymbol: text[10];
    begin
        if not UserPersonalization.Get(UserSecurityId()) then
            exit;

        GeneralLedgerSetup.Get();
        CurrencySymbol := GeneralLedgerSetup.GetCurrencySymbol();

        CASE UserPersonalization."Locale ID" OF
            1030, // da-DK
            1053, // sv-Se
            1044: // no-no
                EXIT('<Precision,0:0><Standard Format,0>' + CurrencySymbol);
            2057, // en-gb
            1033, // en-us
            4108, // fr-ch
            1031, // de-de
            2055, // de-ch
            1040, // it-it
            2064, // it-ch
            1043, // nl-nl
            2067, // nl-be
            2060, // fr-be
            3079, // de-at
            1035, // fi
            1034: // es-es
                EXIT(CurrencySymbol + '<Precision,0:0><Standard Format,0>');
            ELSE
                EXIT('<Precision,0:0><Standard Format,0>');
        END
    end;
}