// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.GeneralLedger.Setup;

report 11726 "Cash Desk Inventory CZP"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/CashDeskInventory.rdl';
    PreviewMode = PrintLayout;
    ApplicationArea = Basic, Suite;
    Caption = 'Cash Desk Inventory';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(CashDeskCZP; "Cash Desk CZP")
        {
            DataItemTableView = sorting("No.");
            column(System_CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(PrintCurrCode; PrintCurrCode)
            {
            }
            column(ReportFilter; StrSubstNo(ReportFilterTxt, CashDeskCZP.Name, PrintCurrCode, Format(InventoryDate)))
            {
            }
            column(Balance; CashDeskBalance)
            {
            }
            column(ShowBalance; ShowBalance)
            {
            }
            dataitem(CurrencyNominalValueCZP; "Currency Nominal Value CZP")
            {
                DataItemTableView = sorting("Currency Code", "Nominal Value") order(descending);
                DataItemLink = "Currency Code" = field("Currency Code");

                column(NominalValue; "Nominal Value")
                {
                    IncludeCaption = true;
                }
                column(Qty; Qty)
                {
                }
                column(Total; Total)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    i += 1;
                    Qty := NominalValueQty[i];
                    Total := Qty * NominalValue[i];
                end;
            }
            trigger OnPreDataItem()
            begin
                if CashDeskNo = '' then
                    Error(EmptyCashDeskNoErr);
                if InventoryDate = 0D then
                    Error(EmptyDateErr);
                SetRange("No.", CashDeskNo);
            end;

            trigger OnAfterGetRecord()
            var
                GLSetup: Record "General Ledger Setup";
            begin
                Clear(Total);
                if "Currency Code" = '' then begin
                    GLSetup.Get();
                    PrintCurrCode := GLSetup."LCY Code"
                end else
                    PrintCurrCode := "Currency Code";
                if ShowBalance then begin
                    SetFilter("Date Filter", '..%1', InventoryDate);
                    CashDeskBalance := CalcBalance();
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(General)
                {
                    Caption = 'General';
                    field(CashDeskNoCZP; CashDeskNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cash Desk No.';
                        TableRelation = "Cash Desk CZP";
                        ToolTip = 'Specifies number of cash desk.';

                        trigger OnValidate()
                        begin
                            CheckCashDeskNo(CashDeskNo);
                            RefreshNominalValues();
                        end;
                    }
                    field(DateCZP; InventoryDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Date';
                        ToolTip = 'Specifies the date of cash inventory.';
                    }
                    field(ShowBalanceCZP; ShowBalance)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Statistics';
                        ToolTip = 'Specifies when the statistics is to be show';
                    }
                }
                group(Denominators)
                {
                    Caption = 'Denominators';
                    grid(Control7)
                    {
                        GridLayout = Columns;
                        ShowCaption = false;
                        group(Control6)
                        {
                            ShowCaption = false;
                            field(NominalValue1; NominalValue[1])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue2; NominalValue[2])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue3; NominalValue[3])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue4; NominalValue[4])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue5; NominalValue[5])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue6; NominalValue[6])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue7; NominalValue[7])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue8; NominalValue[8])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue9; NominalValue[9])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue10; NominalValue[10])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                        }
                        group(Control13)
                        {
                            ShowCaption = false;
                            field(NominalValueQty1; NominalValueQty[1])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 1;
                                ToolTip = 'Specifies quantity by value';
                            }
                            field(NominalValueQty2; NominalValueQty[2])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 2;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                            field(NominalValueQty3; NominalValueQty[3])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 3;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                            field(NominalValueQty4; NominalValueQty[4])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 4;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                            field(NominalValueQty5; NominalValueQty[5])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 5;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                            field(NominalValueQty6; NominalValueQty[6])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 6;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                            field(NominalValueQty7; NominalValueQty[7])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 7;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                            field(NominalValueQty8; NominalValueQty[8])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 8;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                            field(NominalValueQty9; NominalValueQty[9])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 9;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                            field(NominalValueQty10; NominalValueQty[10])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 10;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                        }
                        group(Control30)
                        {
                            ShowCaption = false;
                            field(NominalValue11; NominalValue[11])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue12; NominalValue[12])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue13; NominalValue[13])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue14; NominalValue[14])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue15; NominalValue[15])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue16; NominalValue[16])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue17; NominalValue[17])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue18; NominalValue[18])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue19; NominalValue[19])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                            field(NominalValue20; NominalValue[20])
                            {
                                Caption = 'Value';
                                ApplicationArea = Basic, Suite;
                                BlankZero = true;
                                Editable = false;
                                ToolTip = 'Specifies usable value for currency.';
                            }
                        }
                        group(Control24)
                        {
                            ShowCaption = false;
                            field(NominalValueQty11; NominalValueQty[11])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 11;
                                ToolTip = 'Specifies quantity by value';
                            }
                            field(NominalValueQty12; NominalValueQty[12])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 12;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                            field(NominalValueQty13; NominalValueQty[13])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 13;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                            field(NominalValueQty14; NominalValueQty[14])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 14;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                            field(NominalValueQty15; NominalValueQty[15])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 15;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                            field(NominalValueQty16; NominalValueQty[16])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 16;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                            field(NominalValueQty17; NominalValueQty[17])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 17;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                            field(NominalValueQty18; NominalValueQty[18])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 18;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                            field(NominalValueQty19; NominalValueQty[19])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 19;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                            field(NominalValueQty20; NominalValueQty[20])
                            {
                                Caption = 'Quantity';
                                ApplicationArea = Basic, Suite;
                                Editable = FieldsNo >= 20;
                                ToolTip = 'Specifies the quantity of specified nominal value.';
                            }
                        }
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            InventoryDate := WorkDate();
            if CashDeskCZP.GetFilter("No.") <> '' then
                CashDeskNo := CashDeskCZP.GetRangeMin("No.");
            CheckCashDeskNo(CashDeskNo);
            RefreshNominalValues();
        end;
    }

    labels
    {
        ReportNameLbl = 'Cash Desk Inventory';
        PageLbl = 'Page';
        QtyLbl = 'Quantity';
        TotalLbl = 'Amount';
        CommissionLbl = 'Comission:';
        DateLbl = 'Date:';
        CashBalanceLbl = 'CASH BALANCE';
        AccountStatisticsLbl = 'ACCOUNT STATISTICS';
        CashDeficiencyLbl = 'CASH DEFICIENCY';
        CashSurplusLbl = 'CASH OVER';
    }

    var
        InventoryDate: Date;
        Total: Decimal;
        NominalValue: array[20] of Decimal;
        NominalValueQty: array[20] of Integer;
        i: Integer;
        Qty: Integer;
        PrintCurrCode: Code[10];
        ShowBalance: Boolean;
        CashDeskBalance: Decimal;
        CashDeskNo: Code[20];
        FieldsNo: Integer;
        ReportFilterTxt: Label '%1, %2 to %3', Comment = '%1 = Cash Desk Name, %2 = Cash Desk Currency Code", %3 = Date';
        EmptyCashDeskNoErr: Label 'Cash Desk No. cannot be empty.';
        EmptyDateErr: Label 'Date cannot be empty.';

    procedure RefreshNominalValues()
    var
        CurrencyNominalValueCZP: Record "Currency Nominal Value CZP";
        CurrencyCashDeskCZP: Record "Cash Desk CZP";
    begin
        Clear(NominalValue);
        Clear(NominalValueQty);
        if CashDeskNo = '' then
            exit;

        FieldsNo := 1;
        CurrencyCashDeskCZP.Get(CashDeskNo);
        CurrencyNominalValueCZP.Ascending(false);
        CurrencyNominalValueCZP.SetRange("Currency Code", CurrencyCashDeskCZP."Currency Code");
        CurrencyNominalValueCZP.FindSet();
        repeat
            NominalValue[FieldsNo] := CurrencyNominalValueCZP."Nominal Value";
            NominalValueQty[FieldsNo] := 0;
            FieldsNo += 1;
        until (CurrencyNominalValueCZP.Next() = 0) or (FieldsNo > 20);
        FieldsNo -= 1;
    end;

    local procedure CheckCashDeskNo(CashDeskNo2: Code[20])
    var
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";
    begin
        CashDeskManagementCZP.CheckCashDesk(CashDeskNo2);
    end;
}
