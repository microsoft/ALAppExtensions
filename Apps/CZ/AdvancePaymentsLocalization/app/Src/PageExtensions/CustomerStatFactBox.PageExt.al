// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.Customer;

pageextension 31199 "Customer Stat. FactBox CZZ" extends "Customer Statistics FactBox"
{
    layout
    {
        addlast(content)
        {
            field("Advances"; AdvancesCZZ)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advances';
                ToolTip = 'Specifies the number of opened advance letters.';

                trigger OnDrillDown()
                var
                    SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                    SalesAdvanceLettersCZZ: Page "Sales Advance Letters CZZ";
                begin
                    SalesAdvLetterHeaderCZZ.SetRange("Bill-to Customer No.", Rec."No.");
                    SalesAdvLetterHeaderCZZ.SetFilter(Status, '%1|%2', SalesAdvLetterHeaderCZZ.Status::"To Pay", SalesAdvLetterHeaderCZZ.Status::"To Use");
                    SalesAdvanceLettersCZZ.SetTableView(SalesAdvLetterHeaderCZZ);
                    SalesAdvanceLettersCZZ.Run();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        CustomerNo: Code[20];
        CustomerNoFilter: Text;
    begin
        Rec.FilterGroup(4);
        // Get the customer number and set the current customer number
        CustomerNoFilter := Rec.GetFilter("No.");
        if CustomerNoFilter = '' then begin
            Rec.FilterGroup(0);
            CustomerNoFilter := Rec.GetFilter("No.");
        end;

        CustomerNo := CopyStr(CustomerNoFilter, 1, MaxStrLen(CustomerNo));
        if CustomerNo <> CurrCustomerNoCZZ then begin
            CurrCustomerNoCZZ := CustomerNo;
            CalculateFieldValuesCZZ(CurrCustomerNoCZZ);
        end;
    end;

    var
        CurrCustomerNoCZZ: Code[20];
        AdvancesCZZ: Integer;
        TaskIdCalculateCueCZZ: Integer;

    procedure CalculateFieldValuesCZZ(CustomerNo: Code[20])
    var
        CalculateCustomerStatsCZZ: Codeunit "Calculate Customer Stats. CZZ";
        Args: Dictionary of [Text, Text];
    begin
        if (TaskIdCalculateCueCZZ <> 0) then
            CurrPage.CancelBackgroundTask(TaskIdCalculateCueCZZ);

        Clear(AdvancesCZZ);

        if CustomerNo = '' then
            exit;

        Args.Add(CalculateCustomerStatsCZZ.GetCustomerNoLabel(), CustomerNo);
        CurrPage.EnqueueBackgroundTask(TaskIdCalculateCueCZZ, Codeunit::"Calculate Customer Stats. CZZ", Args);
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        CalculateCustomerStatsCZZ: Codeunit "Calculate Customer Stats. CZZ";
        DictionaryValue: Text;
    begin
        if TaskId = TaskIdCalculateCueCZZ then begin
            if Results.Count() = 0 then
                exit;

            if TryGetDictionaryValueFromKey(Results, CalculateCustomerStatsCZZ.GetAdvancesLabel(), DictionaryValue) then
                Evaluate(AdvancesCZZ, DictionaryValue);
        end;
    end;

    [TryFunction]
    local procedure TryGetDictionaryValueFromKey(var DictionaryToLookIn: Dictionary of [Text, Text]; KeyToSearchFor: Text; var ReturnValue: Text)
    begin
        ReturnValue := DictionaryToLookIn.Get(KeyToSearchFor);
    end;
}
