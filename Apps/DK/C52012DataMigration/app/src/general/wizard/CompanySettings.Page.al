// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1904 "C5 Company Settings"
{
    Caption=' ';
    PageType=NavigatePage;

    layout
    {
        area(content)
        {
            label(Title)
            {
                Caption='Some information is missing.';
                Style=StrongAccent;
                ApplicationArea=All;
            }
            
            label(Line1)
            {
                Caption='The company that you are importing data to is missing some information. Without it, the migration will contain errors that you will have to fix later.';
                Style=Subordinate;
                ApplicationArea=All;
            }
            field(CurrentPeriod;CurrentPeriodValue)
            {
                ApplicationArea=All;
                Caption='Current Period';
                ToolTip='Specifies the start date of the current accounting period. Transactions after this date are migrated individually. Transactions before this date are aggregated per account, and migrated as a single amount.';
            }
            field(LocalCurrencyCode;LocalCurrencyCodeValue)
            {
                ApplicationArea=All;
                Caption='Local Currency Code';
                Visible=IsLocalCurrencyFieldVisible;
                ToolTip='Specifies the currency code for your company.';
            }
        }
    }
    
    actions
    {
        area(Navigation)
        {
            action(OK)
            {
                InFooterBar=true;
                Image=NextRecord;
                ApplicationArea=All;
                trigger OnAction();
                begin
                    SaveCurrentPeriod();
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        CurrentPeriodValue: Date;
        LocalCurrencyCodeValue: Code[3];
        IsLocalCurrencyFieldVisible: Boolean;

    trigger OnOpenPage();
    var
        AccountingPeriod: Record "Accounting Period";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."LCY Code" = '' then
            IsLocalCurrencyFieldVisible := true;
        
        AccountingPeriod.SetRange("New Fiscal Year", true);
        AccountingPeriod.SetFilter("Starting Date", '<=%1', WorkDate());
        AccountingPeriod.SetAscending("Starting Date", true);
        if AccountingPeriod.FindLast() then
           CurrentPeriodValue := AccountingPeriod."Starting Date"
        else
           CurrentPeriodValue := CalcDate('<CY-1Y+1D>', WorkDate());
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean;
    begin
        SaveCurrentPeriod();
        SaveLocalCurrency();
        exit(true);
    end;
    
    local procedure SaveCurrentPeriod()
    var
        C5SchemaParameters: Record "C5 Schema Parameters";
    begin
        C5SchemaParameters.GetSingleInstance();
        C5SchemaParameters.Validate(CurrentPeriod, CurrentPeriodValue);
        C5SchemaParameters.Modify();
    end;

    local procedure SaveLocalCurrency()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if LocalCurrencyCodeValue = '' then
            exit;

        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("LCY Code", LocalCurrencyCodeValue);
        GeneralLedgerSetup.Modify(true);
    end;
}

