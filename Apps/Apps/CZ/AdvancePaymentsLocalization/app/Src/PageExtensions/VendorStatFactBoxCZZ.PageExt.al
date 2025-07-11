// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Vendor;

pageextension 31200 "Vendor Stat. FactBox CZZ" extends "Vendor Statistics FactBox"
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
                    PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
                    PurchAdvanceLettersCZZ: Page "Purch. Advance Letters CZZ";
                begin
                    PurchAdvLetterHeaderCZZ.SetRange("Pay-to Vendor No.", Rec."No.");
                    PurchAdvLetterHeaderCZZ.SetFilter(Status, '%1|%2', PurchAdvLetterHeaderCZZ.Status::"To Pay", PurchAdvLetterHeaderCZZ.Status::"To Use");
                    PurchAdvanceLettersCZZ.SetTableView(PurchAdvLetterHeaderCZZ);
                    PurchAdvanceLettersCZZ.Run();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        VendorNo: Code[20];
        VendorNoFilter: Text;
    begin
        Rec.FilterGroup(4);
        // Get the vendor number and set the current vendor number
        VendorNoFilter := Rec.GetFilter("No.");
        if VendorNoFilter = '' then begin
            Rec.FilterGroup(0);
            VendorNoFilter := Rec.GetFilter("No.");
        end;

        VendorNo := CopyStr(VendorNoFilter, 1, MaxStrLen(VendorNo));
        if VendorNo <> CurrVendorNoCZZ then begin
            CurrVendorNoCZZ := VendorNo;
            CalculateFieldValuesCZZ(CurrVendorNoCZZ);
        end;
    end;

    var
        CurrVendorNoCZZ: Code[20];
        AdvancesCZZ: Integer;
        TaskIdCalculateCueCZZ: Integer;

    procedure CalculateFieldValuesCZZ(VendorNo: Code[20])
    var
        CalculateVendorStatsCZZ: Codeunit "Calculate Vendor Stats. CZZ";
        Args: Dictionary of [Text, Text];
    begin
        if (TaskIdCalculateCueCZZ <> 0) then
            CurrPage.CancelBackgroundTask(TaskIdCalculateCueCZZ);

        Clear(AdvancesCZZ);

        if VendorNo = '' then
            exit;

        Args.Add(CalculateVendorStatsCZZ.GetVendorNoLabel(), VendorNo);
        CurrPage.EnqueueBackgroundTask(TaskIdCalculateCueCZZ, Codeunit::"Calculate Vendor Stats. CZZ", Args);
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        CalculateVendorStatsCZZ: Codeunit "Calculate Vendor Stats. CZZ";
        DictionaryValue: Text;
    begin
        if TaskId = TaskIdCalculateCueCZZ then begin
            if Results.Count() = 0 then
                exit;

            if TryGetDictionaryValueFromKey(Results, CalculateVendorStatsCZZ.GetAdvancesLabel(), DictionaryValue) then
                Evaluate(AdvancesCZZ, DictionaryValue);
        end;
    end;

    [TryFunction]
    local procedure TryGetDictionaryValueFromKey(var DictionaryToLookIn: Dictionary of [Text, Text]; KeyToSearchFor: Text; var ReturnValue: Text)
    begin
        ReturnValue := DictionaryToLookIn.Get(KeyToSearchFor);
    end;
}
